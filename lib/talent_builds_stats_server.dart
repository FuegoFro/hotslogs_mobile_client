import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:hotslogs_mobile_client/heroes_data.dart';
import 'package:hotslogs_mobile_client/talent_builds_common.dart';
import 'package:http/http.dart' as http;

// TODO - Replace this with the real URL once the server is up and running
final _URL_PREFIX = "http://10.0.2.2:5000/top_builds/";

String _talent_url(String talentIconName) => "https://raw.githubusercontent.com/heroespatchnotes/heroes-talents/master/images/talents/${talentIconName}";

Future<List<TalentBuild>> getBuildsForHeroFromStatsServer(
    String heroName) async {
  final talentsForHero = await _loadTalentsForHero(heroName);
  final response = await http.get(_URL_PREFIX + heroName);
  // TODO - Look into using an automatic serialization library
  final jsonData = json.decode(response.body) as Map<String, dynamic>;
  final buildsList = jsonData['top_builds'] as List<dynamic>;

  final talentBuilds = <TalentBuild>[];
  for (final buildPartsUntyped in buildsList) {
    final buildParts = buildPartsUntyped as List<dynamic>;
    assert(buildParts.length == 3);
    final talentsMap = buildParts[0] as Map<String, dynamic>;
    final gameCounts = buildParts[1] as Map<String, dynamic>;
    final pValue = buildParts[2] as double;

    talentBuilds.add(TalentBuild(
      -log(pValue).toInt(),
      (gameCounts['wins'] as int).toDouble() /
          (gameCounts['total_games'] as int).toDouble() *
          100.0,
      _makeTalentFromName(talentsForHero, talentsMap['talent1'] as String),
      _makeTalentFromName(talentsForHero, talentsMap['talent4'] as String),
      _makeTalentFromName(talentsForHero, talentsMap['talent7'] as String),
      _makeTalentFromName(talentsForHero, talentsMap['talent10'] as String),
      _makeTalentFromName(talentsForHero, talentsMap['talent13'] as String),
      _makeTalentFromName(talentsForHero, talentsMap['talent16'] as String),
      _makeTalentFromName(talentsForHero, talentsMap['talent20'] as String),
    ));
  }
  return talentBuilds.reversed.toList();
}

Future<Map<String, Talent>> _loadTalentsForHero(String heroName) async {
  final talentsMap = Map<String, Talent>();

  final shortName = heroShortNameFromName(heroName);
  final talentDataUrl =
      "https://raw.githubusercontent.com/heroespatchnotes/heroes-talents/master/hero/${shortName}.json";
  final response = await http.get(talentDataUrl);
  final jsonData = json.decode(response.body) as Map<String, dynamic>;
  final talents = jsonData['talents'] as Map<String, dynamic>;
  for (final talentLevel in talents.keys) {
    final talentsAtLevel = talents[talentLevel] as List<dynamic>;
    for (final talentUntyped in talentsAtLevel) {
      final talent = talentUntyped as Map<String, dynamic>;
      talentsMap[talent['talentTreeId'] as String] = Talent(
        talent['name'] as String,
        talent['description'] as String,
        _talent_url(talent['icon'] as String),
      );
    }
  }
  return talentsMap;
}

Talent _makeTalentFromName(Map<String, Talent> talentsForHero, String talentName) {
  if (talentName == null) {
    return null;
  }
  if (!talentsForHero.containsKey(talentName)) {
    throw FetchTalentBuildException("Missing talent information", "Could not find info for talent '${talentName}' in map ${talentsForHero}");
  }
  return talentsForHero[talentName];
}
