import 'dart:async';
import 'package:flutter/material.dart';
import 'database.dart';
import 'feed_model.dart';

class FeedListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed'),
      ),
      body: Center(
        child: FeedList(),
      ),
    );
  }
}

class FeedList extends StatefulWidget {
  @override
  FeedListState createState() {
    return FeedListState();
  }
}

class FeedListState extends State<FeedList> {
  var db = new DatabaseHelper();
  Future<List<Feed>> response;
  @override
  void initState() {
    super.initState();
    response = db.getAllFeeds();
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<List<Feed>>(
      future: response,
      builder: (BuildContext context, AsyncSnapshot<List<Feed>> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, i) {
              return Text("${snapshot.data[i].title}");
            },
          );
        } else {
          return Text('empty');
        }
      },
    );
    // var feeds = await db.getAllFeeds();
    // return ListView.builder(
    //   itemCount: feeds.len,
    // );
    // return new ListView.builder(
    // itemCount: posts.length,
    // padding: const EdgeInsets.all(6.0),
    // itemBuilder: (context, i) {
    //   return new GestureDetector(
    //     onTap: () {
    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //           builder: (context) => DetailScreen(url: posts[i].link),
    //         ),
    //       );
    //     },
    //     child: ListTile(
    //       title: Text("${posts[i].title.replaceAll('\n', '')}"),
    //     ),
    //   );
    // }),
  }
}
