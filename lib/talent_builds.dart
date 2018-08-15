import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

const URL_PREFIX = "https://www.hotslogs.com/Sitewide/HeroDetails?Hero=";

const HEADERS = {
  'Pragma': 'no-cache',
  'Origin': 'https://www.hotslogs.com',
  'Accept-Encoding': 'gzip, deflate, br',
  'Accept-Language': 'en-US,en;q=0.9',
  'User-Agent':
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko)'
      ' Chrome/68.0.3440.106 Safari/537.36',
  'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
  'Accept': '*/*',
  'Cache-Control': 'no-cache',
  'X-Requested-With': 'XMLHttpRequest',
  'Connection': 'keep-alive',
  'X-MicrosoftAjax': 'Delta=true',
};

const DATA = {
  'ctl00\$ctl31': 'ctl00\$ctl31|ctl00\$MainContent\$ComboBoxReplayDateTime',
  'ctl00_MainContent_ComboBoxReplayDateTime_ClientState':
      '{"logEntries":[],"value":"","text":"5 items checked","enabled":true,"checkedIndices":['
      '0,1,2,3,4],"checkedItemsTextOverflows":true}',
};

final POPULAR_TALENT_GRID_RE = RegExp(
    "updatePanel\\|ctl00_MainContent_ctl00_MainContent_RadGridPopularTalentBuildsPanel\\|([^|]+)\\|");

final VIEWSTATE_RE = RegExp(
    r'<input type="hidden" name="__VIEWSTATE" id="__VIEWSTATE" value="([^"]+)"');

class Talent {
  final String name;
  final String description;
  final String imageUrl;

  Talent(this.name, this.description, this.imageUrl);

  @override
  String toString() {
    return 'Talent{name: $name, description: $description, imageUrl: $imageUrl}';
  }
}

class TalentBuild {
  final int gameCount;
  final double winPercent;
  final Talent tier1;
  final Talent tier2;
  final Talent tier3;
  final Talent tier4;
  final Talent tier5;
  final Talent tier6;

  // For some reason they don't ever include this data in HotS Logs
  // final Talent tier7;

  TalentBuild(this.gameCount, this.winPercent, this.tier1, this.tier2,
      this.tier3, this.tier4, this.tier5, this.tier6);

  @override
  String toString() {
    return 'TalentBuild{gameCount: $gameCount, winPercent: $winPercent, tier1: $tier1, tier2: $tier2, tier3: $tier3, tier4: $tier4, tier5: $tier5, tier6: $tier6}';
  }

  Iterable<Talent> iterTalents() sync* {
    yield tier1;
    yield tier2;
    yield tier3;
    yield tier4;
    yield tier5;
    yield tier6;
  }

  Iterable<T> mapTalents<T>(T f(Talent t)) => iterTalents().map(f);
}

class FetchTalentBuildException implements Exception {
  final String cause;

  FetchTalentBuildException(this.cause);
}

class MissingTalentInBuildError implements Exception {}

Future<String> getInitialViewstate(String url) async {
  final response = await http.get(url);

  final match = VIEWSTATE_RE.firstMatch(response.body);
  if (match == null) {
    throw FetchTalentBuildException("Unable to find VIEWSTATE in inital page");
  }

  return match.group(1);
}

Future<String> getPopularTalentsGridHtml(String url, String viewstate) async {
  final dataWithViewstate = Map.from(DATA);
  dataWithViewstate["__VIEWSTATE"] = viewstate;
  final response =
      await http.post(url, headers: HEADERS, body: dataWithViewstate);

  final match = POPULAR_TALENT_GRID_RE.firstMatch(response.body);
  if (match == null) {
    throw FetchTalentBuildException(
        "Unable to find talent grid in ajax response");
  }
  return match.group(1);
}

List<TalentBuild> getBuildsFromHtml(String buildsHtml) {
  final document = parse(buildsHtml);
  // Throw away the first row, it's the header row.
  final rows = document.getElementsByTagName('tr').sublist(1);
  final builds = <TalentBuild>[];
  for (final row in rows) {
    try {
      builds.add(parseRow(row));
    } on MissingTalentInBuildError {
      // Ignore this row.
    }
  }
  return builds;
}

TalentBuild parseRow(Element row) {
  // Super hacky, at least for now
  final elements = row.children.where((e) => e is Element).toList();
  if (elements.length != 16) {
    throw FetchTalentBuildException("Unexpected talent build row contents");
  }
  final winPercentStr = elements[1].text;
  return TalentBuild(
    int.parse(elements[0].text.replaceAll(",", "")),
    double.parse(winPercentStr.substring(0, winPercentStr.length - 2)),
    parseTalentCell(elements[2]),
    parseTalentCell(elements[3]),
    parseTalentCell(elements[4]),
    parseTalentCell(elements[5]),
    parseTalentCell(elements[6]),
    parseTalentCell(elements[7]),
  );
}

Talent parseTalentCell(Element cell) {
  if (cell.children.length == 0) {
    // Some talent builds just are missing talents for a tier. Dunno why, but
    // those builds aren't useful.
    throw MissingTalentInBuildError();
  }

  if (cell.children.length != 1) {
    throw FetchTalentBuildException("Unexpected talent cell contents");
  }
  final img = cell.children[0];
  if (img.localName != 'img') {
    throw FetchTalentBuildException('Unexpected talent cell contents');
  }

  final nameAndDescHtml = img.attributes['title'];
  // The .text property doesn't work on the parsed document, but it always has
  // exactly one child, and .text works on that.
  final nameAndDescStr = parse(nameAndDescHtml).firstChild.text;
  final splitIndex = nameAndDescStr.indexOf(': ');
  final name = nameAndDescStr.substring(0, splitIndex);
  final desc = nameAndDescStr.substring(splitIndex + 2);
  final src = img.attributes['src'];
  if (!src.startsWith('//')) {
    throw FetchTalentBuildException("Unexpected talent image url format");
  }

  return Talent(
    name,
    desc,
    'https:' + src,
  );
}

Future<List<TalentBuild>> getBuildsForHero(String heroName) async {
  final url = URL_PREFIX + heroName;
  final viewstate = await getInitialViewstate(url);
  final buildsHtml = await getPopularTalentsGridHtml(url, viewstate);
  return getBuildsFromHtml(buildsHtml);
}
