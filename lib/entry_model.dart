import 'dart:async';
import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;

class Entry {
  final String id;
  final String title;
  final String link;

  Entry({this.id, this.title, this.link});

  factory Entry.fromMap(Map<String, dynamic> map) {
    return Entry(
      id: map['id'],
      title: map['title'],
      link: map['link'],
    );
  }

  factory Entry.fromAtom(AtomItem atom) {
    return Entry(
      id: atom.id,
      title: atom.title,
      link: atom.links.first.href,
    );
  }
}

Future<List<Entry>> fetch(String url) async {
  final response = await http.get(url);
  var atomFeed = new AtomFeed.parse(response.body);
  if (response.statusCode == 200) {
    final posts = atomFeed.items.map((i) => Entry.fromAtom(i)).toList();
    return posts;
  } else {
    throw Exception('Failed to load v2ex');
  }
}
