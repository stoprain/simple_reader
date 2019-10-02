import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'model.dart';

class WebPage extends StatefulWidget {
  @override
  _WebPageState createState() => new _WebPageState();
}

class _WebPageState extends State<WebPage> {
  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url:
          "https://api.weibo.com/oauth2/authorize?client_id=2772135167&redirect_uri=https%3A%2F%2Fttss.stoprain.net%2Fv1%2Fuser&response_type=code&forcelogin=true",
      appBar: new AppBar(
        title: new Text("Widget webview"),
      ),
    );
  }

  final flutterWebviewPlugin = new FlutterWebviewPlugin();
  StreamSubscription<String> _onUrlChanged;

  @override
  void dispose() {
    _onUrlChanged.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    flutterWebviewPlugin.close();

    _onUrlChanged = flutterWebviewPlugin.onUrlChanged.listen((String url) {
      String from = "https://ttss.stoprain.net/?access_token=";
      if (mounted && url.contains(from)) {
        DatabaseHelper.accessToken = url.replaceFirst(from, "");
        Future<SharedPreferences> prefs = SharedPreferences.getInstance();
        prefs.then((value) {
          value.setString('access_token', DatabaseHelper.accessToken);
        });
      }
    });
  }
}
