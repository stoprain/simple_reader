import 'dart:async';
import 'package:flutter/material.dart';
import 'database.dart';
import 'feed_model.dart';
import 'feed_screen.dart';
import 'post_screen.dart';
import 'package:progress_hud/progress_hud.dart';
import 'entry_model.dart';

class FeedListScreen extends StatelessWidget {
  final GlobalKey<FeedListState> feedListStateKey = GlobalKey<FeedListState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feeds'),
        actions: <Widget>[
          IconButton(
            icon: new Icon(Icons.sync),
            onPressed: () async {
              feedListStateKey.currentState.dismissProgressHUD();
              final db = new DatabaseHelper();
              List<Feed> feeds = await db.getAllFeeds();
              for (var feed in feeds) {
                List<Entry> entries = await fetch(feed.link);
                for (var entry in entries) {
                  print('update entry ${entry.id}');
                  db.updateEntry(entry);
                }
              }
              feedListStateKey.currentState.dismissProgressHUD();
            },
          ),
          IconButton(
            icon: new Icon(Icons.add),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => FeedScreen()));
            },
          ),
        ],
      ),
      body: Center(
        child: FeedList(
          key: feedListStateKey,
        ),
      ),
    );
  }
}

class FeedList extends StatefulWidget {
  FeedList({Key key}) : super(key: key);
  @override
  FeedListState createState() {
    return FeedListState();
  }
}

class FeedListState extends State<FeedList> {
  ProgressHUD _progressHUD = new ProgressHUD(
    loading: false,
    backgroundColor: Colors.black12,
    color: Colors.white,
    containerColor: Colors.blue,
    borderRadius: 5.0,
    text: 'Loading...',
  );
  bool _loading = false;

  var db = new DatabaseHelper();
  Future<List<Feed>> response;

  @override
  void initState() {
    super.initState();
    response = db.getAllFeeds();
  }

  void dismissProgressHUD() {
    setState(() {
      if (_loading) {
        _progressHUD.state.dismiss();
      } else {
        _progressHUD.state.show();
      }
      _loading = !_loading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<List<Feed>>(
      future: response,
      builder: (BuildContext context, AsyncSnapshot<List<Feed>> snapshot) {
        if (snapshot.hasData) {
          return Stack(
            children: <Widget>[
              ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, i) {
                  return new GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PostScreen(title: snapshot.data[i].title),
                        ),
                      );
                    },
                    child: ListTile(
                      title: Text('${snapshot.data[i].title}'),
                      subtitle: Text('${snapshot.data[i].link}'),
                    ),
                  );
                },
              ),
              _progressHUD,
              // new Positioned(
              //     child: new FlatButton(
              //         onPressed: dismissProgressHUD,
              //         child: new Text(_loading ? "Dismiss" : "Show")),
              //     bottom: 30.0,
              //     right: 10.0),
            ],
          );
        } else {
          return Text('empty');
        }
      },
    );
  }
}
