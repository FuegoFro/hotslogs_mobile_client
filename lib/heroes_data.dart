import 'package:flutter/material.dart';

enum HeroRole {
  WARRIOR,
  ASSASSIN,
  SUPPORT,
  SPECIALIST,
}
enum HeroUniverse {
  WARCRAFT,
  STARCRAFT,
  DIABLO,
  RETRO,
  OVERWATCH,
}

const _CODE_POINTS_BY_ROLE = {
  HeroRole.WARRIOR: 0xe603,
  HeroRole.SUPPORT: 0xe604,
  HeroRole.SPECIALIST: 0xe605,
  HeroRole.ASSASSIN: 0xe606,
};
const _CODE_POINTS_BY_UNIVERSE = {
  HeroUniverse.WARCRAFT: 0xe600,
  HeroUniverse.STARCRAFT: 0xe601,
  HeroUniverse.DIABLO: 0xe602,
  HeroUniverse.RETRO: 0xe607,
  HeroUniverse.OVERWATCH: 0xe608,
};

const _SELECTED_COLORS_BY_ROLE = {
  HeroRole.WARRIOR: Color.fromARGB(255, 76, 160, 255),
  HeroRole.ASSASSIN: Color.fromARGB(255, 255, 141, 163),
  HeroRole.SUPPORT: Color.fromARGB(255, 2, 233, 217),
  HeroRole.SPECIALIST: Color.fromARGB(255, 197, 113, 255),
};
const _SELECTED_COLORS_BY_UNIVERSE = {
  HeroUniverse.STARCRAFT: Color.fromARGB(255, 76, 160, 255),
  HeroUniverse.DIABLO: Color.fromARGB(255, 255, 141, 163),
  HeroUniverse.WARCRAFT: Color.fromARGB(255, 255, 224, 164),
  HeroUniverse.RETRO: Color.fromARGB(255, 6, 172, 249),
  HeroUniverse.OVERWATCH: Color.fromARGB(255, 178, 178, 178),
};

const _UNSELECTED_COLOR = Color.fromARGB(255, 118, 106, 165);

Icon getHeroRoleIcon(HeroRole role, bool isSelected) => Icon(
      IconData(_CODE_POINTS_BY_ROLE[role], fontFamily: 'heroes-icon'),
      color: isSelected ? _SELECTED_COLORS_BY_ROLE[role] : _UNSELECTED_COLOR,
    );

Icon getHeroUniverseIcon(HeroUniverse universe, bool isSelected) => Icon(
      IconData(_CODE_POINTS_BY_UNIVERSE[universe], fontFamily: 'heroes-icon'),
      color: isSelected
          ? _SELECTED_COLORS_BY_UNIVERSE[universe]
          : _UNSELECTED_COLOR,
    );

String heroShortNameFromName(String heroName) {
  // Special case Lucio
  if (heroName == "Lúcio") {
    return "lucio";
  }

  return heroName.toLowerCase().replaceAll(RegExp("[^a-z]"), "");
}

class HeroInfo {
  final String name;
  final List<HeroRole> roles;
  final HeroUniverse universe;

  const HeroInfo(this.name, this.roles, this.universe);
}

const HEROES = <HeroInfo>[
  HeroInfo(
    "Abathur",
    [HeroRole.SPECIALIST],
    HeroUniverse.STARCRAFT,
  ),
  HeroInfo(
    "Alarak",
    [HeroRole.ASSASSIN],
    HeroUniverse.STARCRAFT,
  ),
  HeroInfo(
    "Alexstrasza",
    [HeroRole.SUPPORT],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Ana",
    [HeroRole.SUPPORT],
    HeroUniverse.OVERWATCH,
  ),
  HeroInfo(
    "Anub'arak",
    [HeroRole.WARRIOR],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Artanis",
    [HeroRole.WARRIOR],
    HeroUniverse.STARCRAFT,
  ),
  HeroInfo(
    "Arthas",
    [HeroRole.WARRIOR],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Auriel",
    [HeroRole.SUPPORT],
    HeroUniverse.DIABLO,
  ),
  HeroInfo(
    "Azmodan",
    [HeroRole.SPECIALIST],
    HeroUniverse.DIABLO,
  ),
  HeroInfo(
    "Blaze",
    [HeroRole.WARRIOR],
    HeroUniverse.STARCRAFT,
  ),
  HeroInfo(
    "Brightwing",
    [HeroRole.SUPPORT],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Cassia",
    [HeroRole.ASSASSIN],
    HeroUniverse.DIABLO,
  ),
  HeroInfo(
    "Chen",
    [HeroRole.WARRIOR],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Cho",
    [HeroRole.WARRIOR],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Chromie",
    [HeroRole.ASSASSIN],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "D.Va",
    [HeroRole.WARRIOR],
    HeroUniverse.OVERWATCH,
  ),
  HeroInfo(
    "Deckard",
    [HeroRole.SUPPORT],
    HeroUniverse.DIABLO,
  ),
  HeroInfo(
    "Dehaka",
    [HeroRole.WARRIOR],
    HeroUniverse.STARCRAFT,
  ),
  HeroInfo(
    "Diablo",
    [HeroRole.WARRIOR],
    HeroUniverse.DIABLO,
  ),
  HeroInfo(
    "E.T.C.",
    [HeroRole.WARRIOR],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Falstad",
    [HeroRole.ASSASSIN],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Fenix",
    [HeroRole.ASSASSIN],
    HeroUniverse.STARCRAFT,
  ),
  HeroInfo(
    "Gall",
    [HeroRole.ASSASSIN],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Garrosh",
    [HeroRole.WARRIOR],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Gazlowe",
    [HeroRole.SPECIALIST],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Genji",
    [HeroRole.ASSASSIN],
    HeroUniverse.OVERWATCH,
  ),
  HeroInfo(
    "Greymane",
    [HeroRole.ASSASSIN],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Gul'dan",
    [HeroRole.ASSASSIN],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Hanzo",
    [HeroRole.ASSASSIN],
    HeroUniverse.OVERWATCH,
  ),
  HeroInfo(
    "Illidan",
    [HeroRole.ASSASSIN],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Jaina",
    [HeroRole.ASSASSIN],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Johanna",
    [HeroRole.WARRIOR],
    HeroUniverse.DIABLO,
  ),
  HeroInfo(
    "Junkrat",
    [HeroRole.ASSASSIN],
    HeroUniverse.OVERWATCH,
  ),
  HeroInfo(
    "Kael'thas",
    [HeroRole.ASSASSIN],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Kel'Thuzad",
    [HeroRole.ASSASSIN],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Kerrigan",
    [HeroRole.ASSASSIN],
    HeroUniverse.STARCRAFT,
  ),
  HeroInfo(
    "Kharazim",
    [HeroRole.SUPPORT],
    HeroUniverse.DIABLO,
  ),
  HeroInfo(
    "Leoric",
    [HeroRole.WARRIOR],
    HeroUniverse.DIABLO,
  ),
  HeroInfo(
    "Li Li",
    [HeroRole.SUPPORT],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Li-Ming",
    [HeroRole.ASSASSIN],
    HeroUniverse.DIABLO,
  ),
  HeroInfo(
    "Lt. Morales",
    [HeroRole.SUPPORT],
    HeroUniverse.STARCRAFT,
  ),
  HeroInfo(
    "Lunara",
    [HeroRole.ASSASSIN],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Lúcio",
    [HeroRole.SUPPORT],
    HeroUniverse.OVERWATCH,
  ),
  HeroInfo(
    "Maiev",
    [HeroRole.ASSASSIN],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Malfurion",
    [HeroRole.SUPPORT],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Malthael",
    [HeroRole.ASSASSIN],
    HeroUniverse.DIABLO,
  ),
  HeroInfo(
    "Medivh",
    [HeroRole.SPECIALIST],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Muradin",
    [HeroRole.WARRIOR],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Murky",
    [HeroRole.SPECIALIST],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Nazeebo",
    [HeroRole.SPECIALIST],
    HeroUniverse.DIABLO,
  ),
  HeroInfo(
    "Nova",
    [HeroRole.ASSASSIN],
    HeroUniverse.STARCRAFT,
  ),
  HeroInfo(
    "Probius",
    [HeroRole.SPECIALIST],
    HeroUniverse.STARCRAFT,
  ),
  HeroInfo(
    "Ragnaros",
    [HeroRole.ASSASSIN],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Raynor",
    [HeroRole.ASSASSIN],
    HeroUniverse.STARCRAFT,
  ),
  HeroInfo(
    "Rehgar",
    [HeroRole.SUPPORT],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Rexxar",
    [HeroRole.WARRIOR],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Samuro",
    [HeroRole.ASSASSIN],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Sgt. Hammer",
    [HeroRole.SPECIALIST],
    HeroUniverse.STARCRAFT,
  ),
  HeroInfo(
    "Sonya",
    [HeroRole.WARRIOR],
    HeroUniverse.DIABLO,
  ),
  HeroInfo(
    "Stitches",
    [HeroRole.WARRIOR],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Stukov",
    [HeroRole.SUPPORT],
    HeroUniverse.STARCRAFT,
  ),
  HeroInfo(
    "Sylvanas",
    [HeroRole.SPECIALIST],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Tassadar",
    [HeroRole.SUPPORT],
    HeroUniverse.STARCRAFT,
  ),
  HeroInfo(
    "The Butcher",
    [HeroRole.ASSASSIN],
    HeroUniverse.DIABLO,
  ),
  HeroInfo(
    "The Lost Vikings",
    [HeroRole.SPECIALIST],
    HeroUniverse.RETRO,
  ),
  HeroInfo(
    "Thrall",
    [HeroRole.ASSASSIN],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Tracer",
    [HeroRole.ASSASSIN],
    HeroUniverse.OVERWATCH,
  ),
  HeroInfo(
    "Tychus",
    [HeroRole.ASSASSIN],
    HeroUniverse.STARCRAFT,
  ),
  HeroInfo(
    "Tyrael",
    [HeroRole.WARRIOR],
    HeroUniverse.DIABLO,
  ),
  HeroInfo(
    "Tyrande",
    [HeroRole.SUPPORT],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Uther",
    [HeroRole.SUPPORT],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Valeera",
    [HeroRole.ASSASSIN],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Valla",
    [HeroRole.ASSASSIN],
    HeroUniverse.DIABLO,
  ),
  HeroInfo(
    "Varian",
    [HeroRole.ASSASSIN, HeroRole.WARRIOR],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Whitemane",
    [HeroRole.SUPPORT],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Xul",
    [HeroRole.SPECIALIST],
    HeroUniverse.DIABLO,
  ),
  HeroInfo(
    "Yrel",
    [HeroRole.WARRIOR],
    HeroUniverse.WARCRAFT,
  ),
  HeroInfo(
    "Zagara",
    [HeroRole.SPECIALIST],
    HeroUniverse.STARCRAFT,
  ),
  HeroInfo(
    "Zarya",
    [HeroRole.WARRIOR],
    HeroUniverse.OVERWATCH,
  ),
  HeroInfo(
    "Zeratul",
    [HeroRole.ASSASSIN],
    HeroUniverse.STARCRAFT,
  ),
  HeroInfo(
    "Zul'jin",
    [HeroRole.ASSASSIN],
    HeroUniverse.WARCRAFT,
  ),
];
