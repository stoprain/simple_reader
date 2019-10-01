import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'comment.dart';

class WeiboPage extends StatefulWidget {
  WeiboPage({Key key}) : super(key: key);
  @override
  _WeiboPageState createState() => _WeiboPageState();
}

class _WeiboPageState extends State<WeiboPage> {
  List widgets = [];

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
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CommentPage(widgets[i]["id"])), //
        );
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
    setState(() {
      widgets = json.decode(s)["statuses"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return getBody();
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
