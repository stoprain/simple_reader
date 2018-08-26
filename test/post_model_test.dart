import 'package:test/test.dart';
import 'package:simple_reader/post_model.dart';

void main() {
  test('test fetchPost 0', () async {
    var posts = await fetchPost(0);
    expect(posts.length, 20);
  });
}
