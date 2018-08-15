import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:hotslogs_mobile_client/random_names_list.dart';

class SavedWords extends StatelessWidget {
  SavedWords(this._words);

  final Set<WordPair> _words;

  @override
  Widget build(BuildContext context) {
    final Iterable<ListTile> tiles = _words.map(
      (pair) => ListTile(
            title: Text(
              pair.asPascalCase,
              style: biggerFont,
            ),
          ),
    );
    final List<Widget> divided =
        ListTile.divideTiles(tiles: tiles, context: context).toList();

    return Scaffold(
      appBar: AppBar(title: Text("Saved Suggestions")),
      body: ListView(children: divided),
    );
  }
}
