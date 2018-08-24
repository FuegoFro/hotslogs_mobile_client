import 'package:cached_network_image/cached_network_image.dart';
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

  Widget _buildHeroFilter() => Container(
        color: Colors.black45,
        child: Column(
          children: <Widget>[
            VertSpace(),
            // Role filters
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: HeroRole.values
                  .map((role) => IconButton(
                        iconSize: 36.0,
                        icon: getHeroRoleIcon(
                            role, _selectedRolls.contains(role)),
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
                        iconSize: 36.0,
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
            VertSpace(),
          ],
        ),
      );

  Widget _buildHeroListView(BuildContext context) => GridView.builder(
        gridDelegate:
            SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 100.0),
        itemBuilder: (BuildContext context, int index) =>
            _buildHeroTile(context, _selectedHeroes[index]),
        itemCount: _selectedHeroes.length,
      );

  Widget _buildHeroTile(BuildContext context, HeroInfo hero) {
    assert(debugCheckHasMaterial(context));
    return GridTile(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Material(
          shape: CircleBorder(
            side: BorderSide(color: Theme.of(context).dividerColor, width: 2.0),
          ),
          color: Colors.transparent,
          child: Ink.image(
            fit: BoxFit.cover,
            image: CachedNetworkImageProvider(_heroImageUrl(hero)),
            child: InkWell(
              onTap: () {
                _tappedHeroDetails(context, hero.name);
              },
            ),
          ),
        ),
      ),
    );
  }

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

  String _heroImageUrl(HeroInfo hero) {
    // Special case Lucio
    String sanitizedName;
    if (hero.name == "Lúcio") {
      sanitizedName = "lucio";
    } else {
      sanitizedName = hero.name.toLowerCase().replaceAll(RegExp("[^a-z]"), "");
    }
    return "https://raw.githubusercontent.com/heroespatchnotes/heroes-talents/master/images/heroes/$sanitizedName.png";
  }
}
