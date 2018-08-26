import 'package:flutter/material.dart';

class NewsstandScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Newsstand'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Test'),
          onPressed: () {},
        ),
      ),
    );
  }
}
