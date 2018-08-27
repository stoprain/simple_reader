import 'dart:async';
import 'dart:convert';
import 'package:webfeed/webfeed.dart';

import 'package:http/http.dart' as http;

Future<List<Post>> fetchReadhub(int order) async {
  String url = 'https://api.readhub.cn/topic?pageSize=20';
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
    throw Exception('Failed to load readhub');
  }
}

Future<List<Post>> fetchV2ex(int order) async {
  final response = await http.get('https://www.v2ex.com/feed/tab/tech.xml');
  var atomFeed = new AtomFeed.parse(response.body);
  if (response.statusCode == 200) {
    final posts = atomFeed.items.map((i) => Post.fromAtom(i)).toList();
    return posts;
  } else {
    throw Exception('Failed to load v2ex');
  }
}

class Post {
  final String id;
  final String title;
  final String summary;
  final int order;
  final String link;

  Post({this.id, this.title, this.summary, this.order, this.link});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
        id: json['id'],
        title: json['title'],
        summary: json['summary'],
        order: json['order'],
        link: 'https://readhub.cn/topic/${json['id']}');
  }

  factory Post.fromAtom(AtomItem atom) {
    return Post(
      id: atom.id,
      title: atom.title,
      summary: atom.content,
      order: 0,
      link: atom.links.first.href,
    );
  }
}
