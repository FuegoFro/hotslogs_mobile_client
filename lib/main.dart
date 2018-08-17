import 'package:flutter/material.dart';
import 'package:hotslogs_mobile_client/hero_list_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: HeroList(),
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color.fromARGB(255, 118, 106, 165),
        accentColor: Color.fromARGB(255, 0, 34, 204),
        backgroundColor: Color.fromARGB(255, 13, 1, 25),
      ),
    );
  }
}
