import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class FeedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed'),
      ),
      body: Center(
        child: MyCustomForm(),
      ),
    );
  }
}

final String tableFeed = "feed";
final String columnId = "_id";
final String columnUrl = "url";

class Feed {
  int id;
  String url;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{columnUrl: url};
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }
}

class FeedProvider {
  Database db;

  Future open(String path) async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
      create table $tableFeed (
        $columnId integer primary key autoincrement,
        $columnUrl text not null)
      ''');
    });
  }

  Future<Feed> insert(Feed feed) async {
    feed.id = await db.insert(tableFeed, feed.toMap());
    return feed;
  }

  Future<int> delete(int id) async {
    return await db.delete(tableFeed, where: "$columnId = ?", whereArgs: [id]);
  }

  Future<int> update(Feed feed) async {
    return await db.update(tableFeed, feed.toMap(),
        where: "$columnId = ?", whereArgs: [feed.id]);
  }

  Future close() async => db.close();
}

class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey we created above
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              onPressed: () async {
                // Validate will return true if the form is valid, or false if
                // the form is invalid.
                if (_formKey.currentState.validate()) {
                  // If the form is valid, we want to show a Snackbar
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text('Processing Data')));
                }

                var feed = Feed();
                feed.url = "test";
                var d = FeedProvider();
                var databasesPath = await getDatabasesPath();
                await d.open(databasesPath + "/test.db");
                var f = d.insert(feed);
                print(f);
                d.close();
              },
              child: Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
