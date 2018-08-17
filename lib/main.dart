import 'package:flutter/material.dart';
import 'package:hotslogs_mobile_client/hero_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: HeroList(),
    );
  }
}
