import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

Future<List<Post>> fetchPost(int order) async {
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
    throw Exception('Failed to load post');
  }
}

class Post {
  final String id;
  final String title;
  final String summary;
  final int order;

  Post({this.id, this.title, this.summary, this.order});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      summary: json['summary'],
      order: json['order'],
    );
  }
}
