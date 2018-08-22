import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import "package:pull_to_refresh/pull_to_refresh.dart";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'simple_reader',
      home: Scaffold(
        appBar: AppBar(
          title: Text('simple_reader'),
        ),
        body: SampleAppPage(),
      ),
    );
  }
}

class SampleAppPage extends StatefulWidget {
  SampleAppPage({Key key}) : super(key: key);

  @override
  _SampleAppPageState createState() => _SampleAppPageState();
}

class _SampleAppPageState extends State<SampleAppPage> {
  RefreshController _refreshController;

  void _reloadList() {
    setState(() {

    });
  }
  @override
  Widget build(BuildContext context) {
    _refreshController = new RefreshController();
    return Center(
          child: FutureBuilder<List<Post>>(
            future: fetchPost(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return new SmartRefresher(
                  controller: _refreshController,
                  enablePullDown: true,
                  onRefresh: (up) {
                    _refreshController.sendBack(up, RefreshStatus.completed);
                    _reloadList();
                  },
                  child: new ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemBuilder: (context, i) {
                    return Text(snapshot.data[i].summary);
                  }
                  ),
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return CircularProgressIndicator();
            }),
          );
  }
}

Future<List<Post>> fetchPost() async {
  final response = await http.get('https://api.readhub.cn/topic');
  if (response.statusCode == 200) {
    final temp = json.decode(response.body)['data'];
    final posts = (temp as List).map((i) => Post.fromJson(i)).toList();
    print(posts.length);
    return posts;
  } else {
    throw Exception('Failed to load post');
  }
}

class Post {
  final String id;
  final String summary;

  Post({this.id, this.summary});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      summary: json['summary'],
      );
  }
}