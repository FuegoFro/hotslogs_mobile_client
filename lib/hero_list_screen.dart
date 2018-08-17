import 'package:flutter/material.dart';
import 'package:hotslogs_mobile_client/hero_details_screen.dart';
import 'package:hotslogs_mobile_client/heroes_data.dart';

class HeroList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HeroListState();
}

class HeroListState extends State<HeroList> {
  final Set<HeroRole> _selectedRolls = Set();
  final Set<HeroUniverse> _selectedUniverses = Set();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Heroes list"),
      ),
      body: Column(
        children: <Widget>[
          _buildHeroFilter(),
          Expanded(
            child: _buildHeroListView(context),
          ),
        ],
      ),
    );
  }

  ListView _buildHeroListView(BuildContext context) => ListView(
        children: ListTile
            .divideTiles(
              context: context,
              tiles: HEROES
                  .where((hero) =>
                      (_selectedUniverses.length == 0 ||
                          _selectedUniverses.contains(hero.universe)) &&
                      (_selectedRolls.length == 0 ||
                          hero.roles.any(_selectedRolls.contains)))
                  .map((hero) {
                return _buildHeroTile(context, hero);
              }),
            )
            .toList(),
      );

  Widget _buildHeroFilter() {
    return Column(
      children: <Widget>[
        // Role filters
        /*Expanded(
          child:*/
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: HeroRole.values
              .map((role) => IconButton(
                    icon: getHeroRoleIcon(role, _selectedRolls.contains(role)),
                    onPressed: () {
                      setState(() {
                        if (_selectedRolls.contains(role)) {
                          _selectedRolls.remove(role);
                        } else {
                          _selectedRolls.add(role);
                        }
                      });
                    },
                  ))
              .toList(),
        ),
//        ),
        Divider(),
        // Universe filters
        /*Expanded(
          child:*/
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: HeroUniverse.values
              .map((universe) => IconButton(
                    icon: getHeroUniverseIcon(
                        universe, _selectedUniverses.contains(universe)),
                    onPressed: () {
                      setState(() {
                        if (_selectedUniverses.contains(universe)) {
                          _selectedUniverses.remove(universe);
                        } else {
                          _selectedUniverses.add(universe);
                        }
                      });
                    },
                  ))
              .toList(),
        ),
//        ),
      ],
    );
  }

  Widget _buildHeroTile(BuildContext context, HeroInfo hero) => ListTile(
        title: Text(hero.name),
        onTap: () {
          _tappedHeroDetails(context, hero.name);
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
