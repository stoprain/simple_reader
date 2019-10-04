import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simple_reader/comment.dart';
import 'package:simple_reader/model.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:simple_reader/rich_text_view.dart';
import 'package:simple_reader/scrollable_positioned_list/src/item_positions_listener.dart';

import 'dart:async';

import 'package:simple_reader/scrollable_positioned_list/src/scrollable_positioned_list.dart';

class WeiboPage extends StatefulWidget {
  WeiboPage({Key key}) : super(key: key);
  @override
  _WeiboPageState createState() => _WeiboPageState();
}

class _WeiboPageState extends State<WeiboPage> {
  List widgets = [];
  final dbHelper = DatabaseHelper.instance;
  final df = new DateFormat("EEE MMM dd HH:mm:ss yyyy");
  Map<int, GlobalKey> _keys = {};

  @override
  void initState() {
    super.initState();
    loadData();
  }

  var controller = new ScrollController();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionListener =
      ItemPositionsListener.create();

  ListView getListView() => ListView.builder(
        itemCount: widgets.length,
        controller: controller,
        itemBuilder: (BuildContext context, int positon) {
          return getRow(positon);
        },
      );

  Widget getRow(int i) {
    _keys[i] = new GlobalKey();
    return Container(
      child: ListTile(
        key: _keys[i],
        title: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Image.network(
                  widgets[i]["user"]["profile_image_url"],
                  width: 36,
                  height: 36,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Text(
                        widgets[i]["user"]["name"],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Text(
                        widgets[i]["created_at"],
                      ),
                    ),
                  ],
                )
              ],
            ),
            StatusCell(widgets[i])
          ],
        ),
        subtitle: (widgets[i]["retweeted_status"] != null)
            ? RetweetedStatusCell(widgets[i])
            : null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CommentPage(widgets[i]["id"])), //
          );
        },
      ),
      decoration:
          new BoxDecoration(border: new Border(bottom: new BorderSide())),
    );
  }

  getBody() {
    return getListView();
  }

  loadData() async {
    var s = await DefaultAssetBundle.of(context)
        .loadString('assets/home_timeline.json');
    List statuses = json.decode(s)["statuses"];
    reloadStatuses(statuses);
  }

  double currentHeight = 0;
  int increase = 0;

  final snackBar = SnackBar(content: Text('new weibo'));

  reloadStatuses(List statuses) async {
    for (var status in statuses) {
      final row = await dbHelper.queryRow(status['idstr']);
      if (row == null) {
        Map<String, dynamic> nrow = {
          DatabaseHelper.columnId: status['idstr'],
          DatabaseHelper.columnRaw: jsonEncode(status),
          DatabaseHelper.columnCreatedAt: df
              .parse(status['created_at'].replaceFirst(' +0800', ''))
              .millisecondsSinceEpoch
        };
        int insert = await dbHelper.insert(nrow);
        // print('row insert $insert');
      } else {
        // print('row exist');
      }
    }
    final allRows = await dbHelper.queryAllRows();
    List nwidgets = [];
    for (var row in allRows) {
      nwidgets.add(json.decode(row[DatabaseHelper.columnRaw]));
    }
    setState(() {
      if (widgets.length != 0 && nwidgets.length > widgets.length) {
        increase = nwidgets.length - widgets.length;
        currentHeight = 0;
      }
      widgets = nwidgets;
      print("setstate widgets.length ${widgets.length}");
      if (increase > 0) {
        Scaffold.of(context).showSnackBar(snackBar);
      }
    });
    if (increase > 0) {
      // delayScroll();
      itemScrollController.jumpTo(index: increase);
      increase = 0;
      currentHeight = 0;
    }
  }

  void delayScroll() {
    // Future.delayed(const Duration(milliseconds: 20), () {
    print("jump to $currentHeight");
    var h = currentHeight;
    controller.jumpTo(currentHeight);
    Future.delayed(const Duration(milliseconds: 20), () {
      print("jump result $h $currentHeight");
      if (h != currentHeight) {
        delayScroll();
      } else {
        increase = 0;
        currentHeight = 0;
      }
    });
    // });
  }

  Future<Null> _refreshLocalGallery() async {
    await Future.delayed(Duration(milliseconds: 1000));
    if (mounted) {
      String dataURL =
          "https://api.weibo.com/2/statuses/home_timeline.json?count=100&access_token=" +
              DatabaseHelper.accessToken;
      http.Response response = await http.get(dataURL);
      List statuses = json.decode(response.body)["statuses"];
      reloadStatuses(statuses);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshLocalGallery,
        child: ScrollablePositionedList.builder(
          itemCount: widgets.length,
          itemBuilder: (context, index) {
            return getRow(index);
          },
          itemScrollController: itemScrollController,
          // itemPositionListener: itemPositionListener,
        ),
      ),
    );
  }
}

class StatusCell extends StatelessWidget {
  final Map status;

  const StatusCell(this.status);

  @override
  Widget build(BuildContext context) {
    List pic_urls = status["pic_urls"];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichTextView(
          text: status["text"],
        ),
        for (var dict in pic_urls) Image.network(dict["thumbnail_pic"]),
      ],
    );
  }
}

class RetweetedStatusCell extends StatelessWidget {
  final Map status;

  const RetweetedStatusCell(this.status);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(color: Colors.grey[300]),
      child: RichTextView(
        text:
            "${status["retweeted_status"]["user"]["name"]} > ${status["retweeted_status"]["text"]}",
      ),
    );
  }
}
