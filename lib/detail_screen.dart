import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class DetailScreen extends StatelessWidget {
  final String url;

  DetailScreen({Key key, @required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new WebviewScaffold(
      url: url,
      appBar: AppBar(
        title: Text('Detail'),
      ),
    );
  }
}
