import 'package:flutter/material.dart';
import 'feedlist_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Basics',
      home: FeedListScreen(),
    );
  }
}
