import 'dart:async';

import 'package:hotslogs_mobile_client/talent_builds_common.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

const _URL_PREFIX = "https://www.hotslogs.com/Sitewide/HeroDetails?Hero=";

const _HEADERS = {
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

const _DATA = {
  'ctl00\$ctl31': 'ctl00\$ctl31|ctl00\$MainContent\$ComboBoxReplayDateTime',
  'ctl00_MainContent_ComboBoxReplayDateTime_ClientState':
      '{"logEntries":[],"value":"","text":"5 items checked","enabled":true,"checkedIndices":['
      '0,1,2,3,4],"checkedItemsTextOverflows":true}',
};

final _POPULAR_TALENT_GRID_RE = RegExp(
    "updatePanel\\|ctl00_MainContent_ctl00_MainContent_RadGridPopularTalentBuildsPanel\\|([^|]+)\\|");

final _VIEWSTATE_RE = RegExp(
    r'<input type="hidden" name="__VIEWSTATE" id="__VIEWSTATE" value="([^"]+)"');

class MissingTalentInBuildError implements Exception {}

Future<String> _getInitialViewstate(String url) async {
  final response = await http.get(url);

  final match = _VIEWSTATE_RE.firstMatch(response.body);
  if (match == null) {
    throw FetchTalentBuildException(
        "Unable to find VIEWSTATE in inital page", response.body);
  }

  return match.group(1);
}

Future<String> _getPopularTalentsGridHtml(String url, String viewstate) async {
  final dataWithViewstate = Map.from<String, String>(_DATA);
  dataWithViewstate["__VIEWSTATE"] = viewstate;
  final response =
      await http.post(url, headers: _HEADERS, body: dataWithViewstate);

  final match = _POPULAR_TALENT_GRID_RE.firstMatch(response.body);
  if (match == null) {
    throw FetchTalentBuildException(
        "Unable to find talent grid in ajax response", response.body);
  }
  return match.group(1);
}

List<TalentBuild> _getBuildsFromHtml(String buildsHtml) {
  final document = parse(buildsHtml);
  // Throw away the first row, it's the header row.
  var trTags = document.getElementsByTagName('tr');
  if (trTags.length == 0) {
    return [];
  }
  final rows = trTags.sublist(1);
  final builds = <TalentBuild>[];
  for (final row in rows) {
    try {
      builds.add(_parseRow(row));
    } on MissingTalentInBuildError {
      // Ignore this row.
    }
  }
  return builds;
}

TalentBuild _parseRow(Element row) {
  // Super hacky, at least for now
  final elements = row.children.where((e) => e is Element).toList();
  if (elements.length != 16) {
    throw FetchTalentBuildException(
        "Unexpected talent build row contents", row.toString());
  }
  final winPercentStr = elements[1].text;
  return TalentBuild(
    int.parse(elements[0].text.replaceAll(",", "")),
    double.parse(winPercentStr.substring(0, winPercentStr.length - 2)),
    _parseTalentCell(elements[2]),
    _parseTalentCell(elements[3]),
    _parseTalentCell(elements[4]),
    _parseTalentCell(elements[5]),
    _parseTalentCell(elements[6]),
    _parseTalentCell(elements[7]),
    null,
  );
}

Talent _parseTalentCell(Element cell) {
  if (cell.children.length == 0) {
    // Some talent builds just are missing talents for a tier. Dunno why, but
    // those builds aren't useful.
    throw MissingTalentInBuildError();
  }

  if (cell.children.length != 1) {
    throw FetchTalentBuildException(
        "Unexpected talent cell contents", cell.toString());
  }
  final img = cell.children[0];
  if (img.localName != 'img') {
    throw FetchTalentBuildException(
        'Unexpected talent cell contents', cell.toString());
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
    throw FetchTalentBuildException("Unexpected talent image url format", src);
  }

  return Talent(
    name,
    desc,
    'https:' + src,
  );
}

Future<List<TalentBuild>> getBuildsForHeroFromHotslogs(String heroName) async {
  final url = _URL_PREFIX + heroName;
  final viewstate = await _getInitialViewstate(url);
  final buildsHtml = await _getPopularTalentsGridHtml(url, viewstate);
  return _getBuildsFromHtml(buildsHtml);
}
