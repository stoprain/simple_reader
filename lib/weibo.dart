import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:simple_reader/auth.dart';
import 'package:simple_reader/model.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'comment.dart';

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

  void _onRefresh() async {
    print('_onRefresh');
    await Future.delayed(Duration(milliseconds: 1000));
    if (mounted) {
      String dataURL =
          "https://api.weibo.com/2/statuses/home_timeline.json?access_token=" +
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

  ListView getListView() => ListView.builder(
      itemCount: widgets.length,
      itemBuilder: (BuildContext context, int positon) {
        return getRow(positon);
      });

  Widget getRow(int i) {
    return ListTile(
      leading: Image.network(widgets[i]["user"]["profile_image_url"]),
      title: new Column(
        children: <Widget>[
          (widgets[i]["retweeted_status"] != null)
              ? RetweetedStatusCell(widgets[i])
              : StatusCell(widgets[i])
          // Text("retweeted"), // if (widgets[i]["retweeted_status"]) {
          //   Text("retweeted");
          // } else {
          //   ;
          //   }
        ],
      ),
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //       builder: (context) => CommentPage(widgets[i]["id"])), //
        // );
      },
      // if "${widgets[i]["text"]}"
      // subtitle: Text("${widgets[i]["user"]["name"]}")
    );
    // return Padding(
    //     padding: EdgeInsets.all(10.0),
    //     child: Text("Row ${widgets[i]["text"]}"));
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
        print('row insert $insert');
      } else {
        print('row exist');
      }
    }
    final allRows = await dbHelper.queryAllRows();
    List nwidgets = [];
    for (var row in allRows) {
      nwidgets.add(json.decode(row[DatabaseHelper.columnRaw]));
    }
    setState(() {
      widgets = nwidgets;
    });
  }

  @override
  Widget build(BuildContext context) {
    // return getBody();
    return Scaffold(
      body: SmartRefresher(
        enablePullDown: true,
        header: WaterDropHeader(),
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: getBody(),
      ),
    );
  }
}

class StatusCell extends StatelessWidget {
  final Map status;

  const StatusCell(this.status);

  @override
  Widget build(BuildContext context) {
    return Text(status["text"]);
  }
}

class RetweetedStatusCell extends StatelessWidget {
  final Map status;

  const RetweetedStatusCell(this.status);

  @override
  Widget build(BuildContext context) {
    return Text("RetweetedStatusCell" + status["retweeted_status"]["text"]);
  }
}
