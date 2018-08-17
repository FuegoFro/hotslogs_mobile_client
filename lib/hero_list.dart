import 'package:flutter/material.dart';
import 'package:hotslogs_mobile_client/hero_details.dart';

const HEROES = <String>[
  "Abathur",
  "Alarak",
  "Alexstrasza",
  "Ana",
  "Anub'arak",
  "Artanis",
  "Arthas",
  "Auriel",
  "Azmodan",
  "Blaze",
  "Brightwing",
  "Cassia",
  "Chen",
  "Cho",
  "Chromie",
  "D.Va",
  "Deckard",
  "Dehaka",
  "Diablo",
  "E.T.C.",
  "Falstad",
  "Fenix",
  "Gall",
  "Garrosh",
  "Gazlowe",
  "Genji",
  "Greymane",
  "Gul'dan",
  "Hanzo",
  "Illidan",
  "Jaina",
  "Johanna",
  "Junkrat",
  "Kael'thas",
  "Kel'Thuzad",
  "Kerrigan",
  "Kharazim",
  "Leoric",
  "Li Li",
  "Li-Ming",
  "Lt. Morales",
  "Lúcio",
  "Lunara",
  "Maiev",
  "Malfurion",
  "Malthael",
  "Medivh",
  "Muradin",
  "Murky",
  "Nazeebo",
  "Nova",
  "Probius",
  "Ragnaros",
  "Raynor",
  "Rehgar",
  "Rexxar",
  "Samuro",
  "Sgt. Hammer",
  "Sonya",
  "Stitches",
  "Stukov",
  "Sylvanas",
  "Tassadar",
  "The Butcher",
  "The Lost Vikings",
  "Thrall",
  "Tracer",
  "Tychus",
  "Tyrael",
  "Tyrande",
  "Uther",
  "Valeera",
  "Valla",
  "Varian",
  "Whitemane",
  "Xul",
  "Yrel",
  "Zagara",
  "Zarya",
  "Zeratul",
  "Zul'jin",
];

class HeroList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Heroes list"),
      ),
      body: ListView(
        children: ListTile
            .divideTiles(
              context: context,
              tiles: HEROES.map((e) {
                return _buildHeroTile(context, e);
              }),
            )
            .toList(),
      ),
    );
  }

  Widget _buildHeroTile(BuildContext context, String heroName) => ListTile(
        title: Text(heroName),
        onTap: () {
          _tappedHeroDetails(context, heroName);
        },
      );

  void _tappedHeroDetails(BuildContext context, String heroName) {
    Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => HeroDetails(heroName),
          ),
        );
  }
}
