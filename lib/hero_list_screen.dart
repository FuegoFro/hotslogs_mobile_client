import 'package:flutter/material.dart';
import 'package:hotslogs_mobile_client/hero_details_screen.dart';
import 'package:hotslogs_mobile_client/heroes_data.dart';
import 'package:hotslogs_mobile_client/list_utils.dart';

class HeroList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HeroListState();
}

class HeroListState extends State<HeroList> {
  final Set<HeroRole> _selectedRolls = Set();
  final Set<HeroUniverse> _selectedUniverses = Set();
  List<HeroInfo> _selectedHeroes = HEROES;

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

  ListView _buildHeroListView(BuildContext context) => ListView.builder(
        itemBuilder: listBuilderWithDividers((context, index) =>
            _buildHeroTile(context, _selectedHeroes[index])),
      );

  Widget _buildHeroFilter() {
    return Column(
      children: <Widget>[
        // Role filters
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: HeroRole.values
              .map((role) => IconButton(
                    icon: getHeroRoleIcon(role, _selectedRolls.contains(role)),
                    onPressed: () {
                      setState(() {
                        _toggleInSet(_selectedRolls, role);
                        _updateSelectedHeroes();
                      });
                    },
                  ))
              .toList(),
        ),
        Divider(),
        // Universe filters
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: HeroUniverse.values
              .map((universe) => IconButton(
                    icon: getHeroUniverseIcon(
                        universe, _selectedUniverses.contains(universe)),
                    onPressed: () {
                      setState(() {
                        _toggleInSet(_selectedUniverses, universe);
                        _updateSelectedHeroes();
                      });
                    },
                  ))
              .toList(),
        ),
        Divider(),
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

  void _toggleInSet<T>(Set<T> set, T t) {
    if (set.contains(t)) {
      set.remove(t);
    } else {
      set.add(t);
    }
  }

  bool _isHeroSelected(HeroInfo hero) =>
      (_selectedUniverses.length == 0 ||
          _selectedUniverses.contains(hero.universe)) &&
      (_selectedRolls.length == 0 || hero.roles.any(_selectedRolls.contains));

  void _updateSelectedHeroes() {
    setState(() {
      _selectedHeroes = HEROES.where(_isHeroSelected).toList();
    });
  }
}
