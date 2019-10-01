import 'dart:convert';
import 'package:flutter/material.dart';

class CommentPage extends StatelessWidget {
  final int statusId;
  CommentPage(this.statusId);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Comment"),
      ),
      body: CommentListView(statusId),
    );
  }
}

class CommentListView extends StatefulWidget {
  final int statusId;
  const CommentListView(this.statusId);
  @override
  _CommentListViewState createState() => _CommentListViewState();
}

class _CommentListViewState extends State<CommentListView> {
  List widgets = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    var s = await DefaultAssetBundle.of(context).loadString('assets/show.json');
    setState(() {
      widgets = json.decode(s)["comments"];
    });
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
            Text(widgets[i]["text"])
            // Text("retweeted"), // if (widgets[i]["retweeted_status"]) {
            //   Text("retweeted");
            // } else {
            //   ;
            //   }
          ],
        ),
        // if "${widgets[i]["text"]}"
        subtitle: Text("${widgets[i]["user"]["name"]}"));
    // return Padding(
    //     padding: EdgeInsets.all(10.0),
    //     child: Text("Row ${widgets[i]["text"]}"));
  }

  getBody() {
    return getListView();
  }

  @override
  Widget build(BuildContext context) {
    return getBody();
  }
}
