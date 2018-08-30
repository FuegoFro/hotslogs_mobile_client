import json
import math
from dataclasses import dataclass, field
from datetime import date, timedelta, datetime
from pathlib import Path
from typing import Dict, Iterator, Optional, Sequence, Tuple, List

from dataclasses_json import DataClassJsonMixin
from scipy.stats import fisher_exact

from data_utils import json_iter_raw_data, json_rollup_file, get_all_rollup_heroes, \
    json_top_builds_file
from json_utils import JsonMap, JsonThing

_ALLOWED_GAME_TYPES = {
    "QuickMatch",
    "HeroLeague",
    "UnrankedDraft",
    "TeamLeague",
}

_GAME_DATE_FORMAT = "%Y-%m-%d %H:%M:%S"


@dataclass(frozen=True)
class TalentBuild(DataClassJsonMixin):
    talent1: Optional[str]
    talent4: Optional[str]
    talent7: Optional[str]
    talent10: Optional[str]
    talent13: Optional[str]
    talent16: Optional[str]
    talent20: Optional[str]


@dataclass
class GameCounts:
    total_games: int = field(default=0)
    wins: int = field(default=0)


@dataclass
class HeroRollup(DataClassJsonMixin):
    hero: str
    total_games: int = field(default=0)
    wins: int = field(default=0)
    # Can't use default dict since it causes to_json to fail
    counts_by_talent_build: Dict[str, GameCounts] = field(default_factory=dict)


@dataclass
class TopBuildsList(DataClassJsonMixin):
    top_builds: List[Tuple[TalentBuild, GameCounts, float]]


def _iter_replay_json(path: Path) -> Iterator[JsonMap]:
    data = JsonThing.from_path(path).as_map()
    for replay in data['replays'].as_list():
        yield replay.as_map()


def _make_talent_build(talents: Sequence[Optional[str]]) -> str:
    return TalentBuild(*talents).to_json()


def calculate_rollups() -> None:
    fetch_date = date(year=2018, month=8, day=28)
    first_date = fetch_date - timedelta(weeks=5)
    print(f"First date is {first_date}")

    rollups: Dict[str, HeroRollup] = {}
    for path in json_iter_raw_data():
        for replay in _iter_replay_json(path):
            if replay['game_type'].is_none():
                print("Skipping None game_type:", repr(replay._data))
                continue
            game_type = replay['game_type'].as_str()
            game_date_str = replay['game_date'].as_str()
            # print(f"Game type: {game_type}")
            # print(f"Game date: {game_date_str}")
            game_date = datetime.strptime(game_date_str, _GAME_DATE_FORMAT)
            if game_date.date() < first_date or game_type not in _ALLOWED_GAME_TYPES:
                continue

            for player_thing in replay['players'].as_list():
                player = player_thing.as_map()

                talents: List[Optional[str]] = []
                for talent_thing in player['talents'].as_list():
                    talent = talent_thing.as_map()
                    talent_name = talent['name'].as_str()
                    # talent_level = talent['level'].as_int()
                    # print("        Talent name:", talent_name)
                    # print("        Talent level:", talent_level)
                    talents.append(talent_name)
                # Pad with None's and create the talent build
                talents += [None] * (7 - len(talents))
                talent_build = _make_talent_build(talents)

                win_count_change = 1 if player['winner'].as_bool() else 0
                if not player['hero'].is_none():
                    hero_name = player['hero'].as_map()['name'].as_str()
                else:
                    if all(t is None or t.startswith("Whitemane") for t in talents):
                        hero_name = "Whitemane"
                    else:
                        print("Skipping None hero:", repr(player._data))
                        continue
                # print(f"    Hero: {hero_name}")
                # print(f"    Won: {win_count_change}")

                if hero_name not in rollups:
                    rollups[hero_name] = HeroRollup(hero=hero_name)
                if talent_build not in rollups[hero_name].counts_by_talent_build:
                    rollups[hero_name].counts_by_talent_build[talent_build] = GameCounts()

                rollups[hero_name].total_games += 1
                rollups[hero_name].wins += win_count_change
                rollups[hero_name].counts_by_talent_build[talent_build].total_games += 1
                rollups[hero_name].counts_by_talent_build[talent_build].wins += win_count_change

    for hero, rollup in rollups.items():
        json_rollup_file(hero).write_text(rollup.to_json())


def get_p_values(hero_name: str) -> Tuple[HeroRollup, List[Tuple[TalentBuild, GameCounts, float]]]:
    path = json_rollup_file(hero_name)
    rollup: HeroRollup = HeroRollup.from_json(path.read_text())
    # TODO RIGHT NOW NORELEASE - This is a hack around the json library, fix the library
    rollup.counts_by_talent_build = {
        k: GameCounts(**v)  # type: ignore
        for k, v in rollup.counts_by_talent_build.items()
    }
    p_values = []
    for talents, counts in rollup.counts_by_talent_build.items():

        # Make a table like the following
        #                 -----------------
        #                 | wins | losses |
        #   -------------------------------
        #   | w/ build    | 5    | 2      |
        #   -------------------------------
        #   | w/out build | 7123 | 5456   |
        #   -------------------------------
        build_wins = counts.wins
        build_losses = counts.total_games - counts.wins
        total_wins = rollup.wins
        total_losses = rollup.total_games - rollup.wins

        # Filter out builds that have less than 0.1% frequency. The chi2_contingency test we do
        # below is recommended to not use data below 5%, but no single build is used that often.
        if counts.total_games / rollup.total_games < 0.001:
            continue

        contingency_table = [
            [build_wins, build_losses],
            [total_wins - build_wins, total_losses - build_losses],
        ]
        _, p_value = fisher_exact(contingency_table)

        # Decode talent build
        p_values.append((TalentBuild.from_json(talents), counts, p_value))

    return rollup, p_values


def get_top_builds(hero_name: str) -> TopBuildsList:
    rollup, p_values = get_p_values(hero_name)
    # Filter to the builds that win more than average
    win_threshold = rollup.wins / rollup.total_games
    p_values = [p for p in p_values if p[1].wins / p[1].total_games > win_threshold]
    # Sort by p-value
    p_values = sorted(p_values, key=lambda x: x[2])
    # Take the top p-value builds
    top_builds = p_values[:10]
    # Sort by win-rate
    top_builds = sorted(top_builds, key=lambda x: x[1].wins / x[1].total_games)
    return TopBuildsList(top_builds)


def calculate_all_top_builds() -> None:
    for hero_name in get_all_rollup_heroes():
        json_top_builds_file(hero_name).write_text(get_top_builds(hero_name).to_json())


def plot_p_values() -> None:
    import matplotlib
    matplotlib.use("TkAgg")
    import matplotlib.pyplot as plt
    plt.suptitle('Talent Build Performance')

    for i, hero in enumerate(("Cho", "Murky", "Gall", "Chen")):
        _, p_values = get_p_values(hero)
        xs = [p[1].wins / p[1].total_games for p in p_values]
        ys = [p[2] for p in p_values]
        ax = plt.subplot(2, 2, i + 1)
        ax.scatter(xs, ys)
        ax.set_yscale('log')
        ax.set_xlim(min(xs), max(xs))
        ax.set_ylim(min(ys), max(ys))
        ax.set_xlabel('Win Percent')
        ax.set_ylabel('P-Value')
        ax.set_title(hero)
        ax.grid(True)

    print("Showing graph...")
    plt.show()


def _deserialize_top_buidls_list(json_text: str) -> TopBuildsList:
    return TopBuildsList([
        (TalentBuild(**tb), GameCounts(**gc), p)
        for tb, gc, p in json.loads(json_text)['top_builds']
    ])


def print_top_builds(hero_name: str) -> None:
    # for (tb, c, p) in get_top_builds(hero_name).top_builds:
    for (tb, c, p) in _deserialize_top_buidls_list(
            json_top_builds_file(hero_name).read_text()).top_builds:
        p = -math.log(p)
        print(
            f"{c.wins / c.total_games:.2f}% ({c.wins: <4}/{c.total_games: <4}) p={p: <4.1f} - {tb}")


def main() -> None:
    # calculate_rollups()
    # plot_p_values()
    # calculate_all_top_builds()
    print_top_builds("Diablo")


if __name__ == '__main__':
    main()
