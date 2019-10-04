import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List widgets = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    var s = await DefaultAssetBundle.of(context)
        .loadString('assets/favorites.json');
    setState(() {
      widgets = json.decode(s)["favorites"];
    });
  }

  ListView getListView() => ListView.builder(
      itemCount: widgets.length,
      itemBuilder: (BuildContext context, int positon) {
        return getRow(positon);
      });

  Widget getRow(int i) {
    return ListTile(
        leading: (widgets[i]["status"]["user"] != null)
            ? Image.network(widgets[i]["status"]["user"]["profile_image_url"])
            : null,
        title: new Column(
          children: <Widget>[Text(widgets[i]["status"]["text"])],
        ),
        subtitle: (widgets[i]["status"]["user"] != null)
            ? Text("${widgets[i]["status"]["user"]["name"]}")
            : null);
  }

  getBody() {
    return getListView();
  }

  @override
  Widget build(BuildContext context) {
    return getBody();
  }
}