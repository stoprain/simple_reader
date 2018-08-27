import 'dart:async';

import 'package:flutter/material.dart';
import "package:pull_to_refresh/pull_to_refresh.dart";

import 'post_model.dart';
import 'newsstand_screen.dart';
import 'detail_screen.dart';

class PostScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SampleAppPage(),
        appBar: AppBar(
          title: Text('simple_reader'),
          actions: <Widget>[
            IconButton(
              icon: new Icon(Icons.list),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => NewsstandScreen()));
              },
            ),
          ],
        ));
  }
}

class SampleAppPage extends StatefulWidget {
  SampleAppPage({Key key}) : super(key: key);

  @override
  _SampleAppPageState createState() => _SampleAppPageState();
}

class _SampleAppPageState extends State<SampleAppPage> {
  RefreshController _refreshController;

  List<Post> posts = new List<Post>();
  void _reloadList(int order, bool up) async {
    final temp = await fetchV2ex(order);
    setState(() {
      if (order == 0) {
        posts = temp;
      } else {
        posts = new List.from(posts)..addAll(temp);
      }
      print("_reloadList setState $order ${posts.length}");
    });
    if (up) {
      _refreshController
          .scrollTo(_refreshController.scrollController.offset + 50);
    }
    _refreshController.sendBack(up, RefreshStatus.idle);
  }

  @override
  Widget build(BuildContext context) {
    _refreshController = new RefreshController();
    return Center(
      child: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: true,
        onRefresh: (up) {
          new Future.delayed(const Duration(milliseconds: 1000)).then((val) {
            if (up) {
              _reloadList(0, up);
            } else {
              if (posts.length > 0) {
                _reloadList(posts.last.order, up);
              } else {
                _reloadList(0, up);
              }
            }
          });
        },
        child: new ListView.builder(
            itemCount: posts.length,
            padding: const EdgeInsets.all(6.0),
            itemBuilder: (context, i) {
              return new GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(url: posts[i].link),
                    ),
                  );
                },
                child: ListTile(
                  title: Text("${posts[i].title.replaceAll('\n', '')}"),
                ),
              );
            }),
      ),
    );
  }
}
