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
  int lastOrder = 0;
  Future<List<Post>> future = fetchPost(0);
  List<Post> posts = new List<Post>();
  void _reloadList() {
    print("_reloadList $lastOrder");
    setState(() {
      future = fetchPost(0);
    });
  }
  void _loadMore() {
    print("_loadMore $lastOrder");
    setState(() {
      future = fetchPost(lastOrder);
    });
  }
  @override
  Widget build(BuildContext context) {
    _refreshController = new RefreshController();
    return Center(
          child: FutureBuilder<List<Post>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (lastOrder == 0) {
                  posts = snapshot.data;
                } else {
                  posts = new List.from(posts)..addAll(snapshot.data);
                }
                print("post${posts.length}");
                return new SmartRefresher(
                  controller: _refreshController,
                  enablePullDown: true,
                  enablePullUp: true,
                  onRefresh: (up) {
                    _refreshController.sendBack(up, RefreshStatus.completed);
                    if (up) {
                      print('up');
                      lastOrder = 0;
                      _reloadList();
                    } else {
                      print('down');
                      lastOrder = posts.last.order;
                      _loadMore();
                    }
                  },
                  child: new ListView.builder(
                    itemCount: posts.length,
                    padding: const EdgeInsets.all(16.0),
                    itemBuilder: (context, i) {
                      // print("${snapshot.data.length}-${i}");
                      return Text("##$i##${posts[i].summary}");
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

Future<List<Post>> fetchPost(int order) async {
  String url = 'https://api.readhub.cn/topic?pageSize=10';
  if (order > 0) {
    url = url + "&lastCursor=$order";
  }
  print(url);
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final temp = json.decode(response.body)['data'];
    final posts = (temp as List).map((i) => Post.fromJson(i)).toList();
    return posts;
  } else {
    throw Exception('Failed to load post');
  }
}

class Post {
  final String id;
  final String summary;
  final int order;

  Post({this.id, this.summary, this.order});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      summary: json['summary'],
      order: json['order'],
      );
  }
}
