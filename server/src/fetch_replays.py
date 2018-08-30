import json
import pprint
from datetime import timedelta, date

import requests
import time

from data_utils import json_raw_data_file, get_last_json_file_num
from json_utils import JsonThing, JsonMap


def _get_next_id_from_date() -> int:
    today = date.today()
    five_weeks_ago = today - timedelta(weeks=5)
    start_date_str = five_weeks_ago.strftime("%Y-%m-%d")
    end_date_str = (five_weeks_ago + timedelta(days=1)).strftime("%Y-%m-%d")
    resp = requests.get(
        "http://hotsapi.net/api/v1/replays/paged",
        params={
            "start_date": start_date_str,
            "end_date": end_date_str,
            "page": "1",
        },
    )
    resp.raise_for_status()
    return (
        JsonThing(resp.json())
            .as_map()['replays']
            .as_list()[0]
            .as_map()['id']
            .as_int()
    )


def _get_next_id_from_json(last_file_num: int) -> int:
    data = JsonThing.from_path(json_raw_data_file(last_file_num))
    return _get_max_id(data.as_map()) + 1


def _get_max_id(data: JsonMap) -> int:
    replays = data['replays'].as_list()
    max_id = max(r.as_map()['id'].as_int() for r in replays)
    assert max_id == data['replays'].as_list()[-1].as_map()['id'].as_int()
    return max_id


def main() -> None:
    # Figure out where to resume from
    #   Read from database (file?) to get latest ID.
    #   If no ID (file?), do one request to starting ID for date, go from there.
    last_file_num = get_last_json_file_num()
    if last_file_num == -1:
        next_id = _get_next_id_from_date()
    else:
        next_id = _get_next_id_from_json(last_file_num)
    next_file_num = last_file_num + 1

    # While we get data back, request page of max_id_seen + 1
    #   Save off entire json response as a new json file
    while True:
        resp = requests.get(
            "http://hotsapi.net/api/v1/replays/paged",
            params={
                "with_players": True,
                "min_id": next_id,
                "page": 1,
            },
        )
        if resp.status_code == 429:
            sleep_secs = int(resp.headers['retry-after'])
            print(f"Too many requests, sleeping {sleep_secs} seconds...")
            time.sleep(sleep_secs)
            continue
        resp.raise_for_status()

        try:
            raw_data = resp.json()
        except json.JSONDecodeError:
            print("ERROR:")
            print(resp.status_code)
            print(resp.content)
            raise

        data = JsonThing(raw_data).as_map()
        replays = data['replays'].as_list()
        if len(replays) == 0:
            pprint.pprint(raw_data)
            break

        max_game_date = max(r.as_map()['game_date'].as_str() for r in replays if not r.as_map()['game_date'].is_none())
        print(time.asctime(), f"Fetched page starting with ID {next_id} - {len(replays)} items, Most recent game at {max_game_date}")
        json_raw_data_file(next_file_num).write_bytes(resp.content)
        next_file_num += 1
        next_id = _get_max_id(data) + 1


if __name__ == '__main__':
    main()
