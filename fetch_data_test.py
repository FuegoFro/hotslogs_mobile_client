#!python3
import pprint
import re
from typing import NamedTuple

import requests
import bs4

URL_TEMPLATE = "https://www.hotslogs.com/Sitewide/HeroDetails?Hero={}"

HEADERS = {
    'Pragma': 'no-cache',
    'Origin': 'https://www.hotslogs.com',
    'Accept-Encoding': 'gzip, deflate, br',
    'Accept-Language': 'en-US,en;q=0.9',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko)'
                  ' Chrome/68.0.3440.106 Safari/537.36',
    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
    'Accept': '*/*',
    'Cache-Control': 'no-cache',
    'X-Requested-With': 'XMLHttpRequest',
    'Connection': 'keep-alive',
    'X-MicrosoftAjax': 'Delta=true',
}

DATA = {
    'ctl00$ctl31': 'ctl00$ctl31|ctl00$MainContent$ComboBoxReplayDateTime',
    'ctl00_MainContent_ComboBoxReplayDateTime_ClientState':
        '{"logEntries":[],"value":"","text":"5 items checked","enabled":true,"checkedIndices":['
        '0,1,2,3,4],"checkedItemsTextOverflows":true}',
}


POPULAR_TALENT_GRID_RE = re.compile(
    "updatePanel\|ctl00_MainContent_ctl00_MainContent_RadGridPopularTalentBuildsPanel\|([^|]+)\|")

VIEWSTATE_RE = re.compile(
    r'<input type="hidden" name="__VIEWSTATE" id="__VIEWSTATE" value="([^"]+)"')


def get_inital_viewstate(url):
    resp = requests.get(url)
    resp.raise_for_status()
    content = resp.content.decode()
    match = VIEWSTATE_RE.search(content)
    assert match is not None, f"Unable to find VIEWSTATE in initial page: {repr(content)}"

    return match.group(1)


def get_popular_talents_grid_html(url, viewstate):
    data_with_viewstate = dict(DATA, __VIEWSTATE=viewstate)
    resp = requests.post(url, data=data_with_viewstate, headers=HEADERS)
    resp.raise_for_status()

    # content = resp.content.decode()
    content = resp.content.decode()
    match = POPULAR_TALENT_GRID_RE.search(content)
    assert match is not None, f"Unable to find talent grid in AJAX response: {content}"
    return match.group(1)


def get_build_data_from_html(builds_html):
    # soup = bs4.BeautifulSoup(builds_html, features="html5lib")
    soup = bs4.BeautifulSoup(builds_html, features="html.parser")
    rows = soup.find_all('tr')
    # Throw away the first row, it's the header row.
    rows = rows[1:]
    parsed_rows = []
    for r in rows:
        try:
            parsed_rows.append(parse_row(r))
        except MissingTalentInBuildError:
            pass
    return parsed_rows


class MissingTalentInBuildError(ValueError):
    pass


def parse_talent_td(td_soup):
    if len(td_soup.contents) == 0:
        # Some talent builds just are missing talents for a tier. Dunno why, but those builds
        # aren't useful.
        raise MissingTalentInBuildError()

    assert len(td_soup.contents) == 1, td_soup.contents
    img = td_soup.contents[0]
    assert img.name == "img", img

    name_and_desc_html = img.attrs['title']
    name_and_desc = bs4.BeautifulSoup(name_and_desc_html, features="html.parser").text
    name, desc = name_and_desc.split(': ', 1)
    src = img.attrs['src']
    assert src.startswith('//')
    src = 'https:' + src

    return Talent(
        name=name,
        description=desc,
        image_url=src,
    )


def parse_row(row_soup):
    # Super hacky, at least for now
    tags = [c for c in row_soup if isinstance(c, bs4.element.Tag)]
    assert len(tags) == 16
    return TalentBuild(
        game_count=int(tags[0].text.replace(",", "")),
        win_percent=float(tags[1].text[:-2]),
        tier1=parse_talent_td(tags[2]),
        tier2=parse_talent_td(tags[3]),
        tier3=parse_talent_td(tags[4]),
        tier4=parse_talent_td(tags[5]),
        tier5=parse_talent_td(tags[6]),
        tier6=parse_talent_td(tags[7]),
    )


class Talent(NamedTuple):
    name: str
    description: str
    image_url: str


class TalentBuild(NamedTuple):
    game_count: int
    win_percent: float
    tier1: Talent
    tier2: Talent
    tier3: Talent
    tier4: Talent
    tier5: Talent
    tier6: Talent
    # For some reason they don't ever include this data in HotS Logs
    # tier7: Talent


def tuples_to_dicts(o):
    if isinstance(o, list):
        return [tuples_to_dicts(i) for i in o]
    if isinstance(o, dict):
        return {tuples_to_dicts(k): tuples_to_dicts(v) for k, v in o.items()}
    if isinstance(o, tuple) and hasattr(o, '_asdict'):
        return o._asdict()
    return o


def main():
    url = URL_TEMPLATE.format("Garrosh")
    viewstate = get_inital_viewstate(url)
    builds_html = get_popular_talents_grid_html(url, viewstate)
    talent_builds = get_build_data_from_html(builds_html)
    print(type(talent_builds[0]))
    pprint.pprint(tuples_to_dicts(talent_builds))


if __name__ == '__main__':
    main()
