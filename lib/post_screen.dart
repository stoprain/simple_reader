import 'dart:async';

import 'package:flutter/material.dart';
import "package:pull_to_refresh/pull_to_refresh.dart";

import 'post_model.dart';
import 'feed_screen.dart';
import 'detail_screen.dart';
import 'database.dart';
import 'entry_model.dart';

class PostScreen extends StatelessWidget {
  final String title;

  PostScreen({Key key, @required this.title}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: EntryList(),
        appBar: AppBar(
          title: Text(title),
        ));
  }
}

class EntryList extends StatefulWidget {
  EntryList({Key key}) : super(key: key);

  @override
  EntryListState createState() => EntryListState();
}

class EntryListState extends State<EntryList> {
  var db = new DatabaseHelper();
  Future<List<Entry>> response;

  @override
  void initState() {
    super.initState();
    response = db.getAllEntries();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Entry>>(
      future: response,
      builder: (BuildContext context, AsyncSnapshot<List<Entry>> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, i) {
              return new GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailScreen(url: snapshot.data[i].link),
                    ),
                  );
                },
                child: ListTile(
                  title: Text('${snapshot.data[i].title}'),
                  subtitle: Text('${snapshot.data[i].link}'),
                ),
              );
            },
          );
        } else {
          return Text('empty');
        }
      },
    );
  }
}
