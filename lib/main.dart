import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:hotslogs_mobile_client/saved_words.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: RandomWords(),
    );
  }
}

final biggerFont = const TextStyle(fontSize: 18.0);

class RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _saved = Set<WordPair>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Flutter'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved)
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemBuilder: (context, index) {
          if (index.isOdd) {
            return Divider();
          }
          final suggestionIndex = index ~/ 2;
          while (index >= _suggestions.length) {
            print("Creating index $suggestionIndex");
            _suggestions.add(WordPair.random());
          }
          print("Building index $suggestionIndex");
          return _buildRow(_suggestions[suggestionIndex]);
        });
  }

  Widget _buildRow(WordPair wordPair) {
    final alreadySaved = _saved.contains(wordPair);
    return ListTile(
      title: Text(wordPair.asPascalCase, style: biggerFont),
      trailing: IconButton(
          icon: Icon(
            alreadySaved ? Icons.favorite : Icons.favorite_border,
            color: alreadySaved ? Colors.red : null,
          ),
          onPressed: () {
            setState(() {
              if (alreadySaved) {
                _saved.remove(wordPair);
              } else {
                _saved.add(wordPair);
              }
            });
          }),
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => SavedWords(_saved),
          ),
        );
  }
}

class RandomWords extends StatefulWidget {
  @override
  State createState() => RandomWordsState();
}
