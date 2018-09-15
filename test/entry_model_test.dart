import 'package:test/test.dart';
import 'package:simple_reader/post_model.dart';
import 'package:simple_reader/entry_model.dart';
import 'package:simple_reader/database.dart';

void main() {
  // test('test fetchPost 0', () async {
  //   var posts = await fetchReadhub(0);
  //   expect(posts.length, 20);
  // });

  // test('test testv2ex', () async {
  //   await fetchV2ex(0);
  //   expect(true, true);
  // });

  test('test fetch', () async {
    var entries = await fetch('https://www.v2ex.com/feed/tab/tech.xml');

    // var d = EntryProvider();
    // await d.open('test.db');
    // for (var entry in entries) {
    //   await d.updateEntry(entry);
    // }
    // await d.close();

    expect(entries.length > 0, true);
  });
}
