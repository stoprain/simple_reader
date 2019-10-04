import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:simple_reader/comment.dart';
import 'package:simple_reader/model.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'dart:async';

class WeiboPage extends StatefulWidget {
  WeiboPage({Key key}) : super(key: key);
  @override
  _WeiboPageState createState() => _WeiboPageState();
}

class _WeiboPageState extends State<WeiboPage> {
  List widgets = [];
  final dbHelper = DatabaseHelper.instance;
  final df = new DateFormat("EEE MMM dd HH:mm:ss yyyy");
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  Map<int, GlobalKey> _keys = {};

  void _onRefresh() async {
    print('_onRefresh');
    await Future.delayed(Duration(milliseconds: 1000));
    if (mounted) {
      String dataURL =
          "https://api.weibo.com/2/statuses/home_timeline.json?count=100&access_token=" +
              DatabaseHelper.accessToken;
      http.Response response = await http.get(dataURL);
      List statuses = json.decode(response.body)["statuses"];
      reloadStatuses(statuses);
    }
    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  var controller = new ScrollController();

  ListView getListView() => ListView.builder(
        itemCount: widgets.length,
        controller: controller,
        itemBuilder: (BuildContext context, int positon) {
          return getRow(positon);
        },
      );

  Widget getRow(int i) {
    print("getRow $i ${widgets[i]["idstr"]}");
    _afterLayout(_) {
      final RenderBox renderBoxRed = _keys[i].currentContext.findRenderObject();
      final sizeRed = renderBoxRed.size;
      print("SIZE of Red: $sizeRed");
      if (increase != 0 && i <= increase) {
        currentHeight += sizeRed.height;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    _keys[i] = new GlobalKey();
    return ListTile(
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
                children: <Widget>[
                  Text(
                    widgets[i]["user"]["name"],
                  ),
                  Text(
                    widgets[i]["created_at"],
                  ),
                ],
              )
            ],
          ),
          StatusCell(widgets[i])
        ],
      ),
      subtitle: new Column(
        children: <Widget>[
          // Text("retweeted")
          (widgets[i]["retweeted_status"] != null)
              ? RetweetedStatusCell(widgets[i])
              : null
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CommentPage(widgets[i]["id"])), //
        );
      },
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
      delayScroll();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        enablePullDown: true,
        header: WaterDropHeader(),
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: getListView(),
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
      children: <Widget>[
        Text(status["text"]),
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
    return Text(status["retweeted_status"]["text"]);
  }
}
