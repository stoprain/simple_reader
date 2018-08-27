import 'package:test/test.dart';
import 'package:simple_reader/post_model.dart';

void main() {
  test('test fetchPost 0', () async {
    var posts = await fetchReadhub(0);
    expect(posts.length, 20);
  });

  test('test testv2ex', () async {
    await fetchV2ex(0);
    expect(true, true);
  });
}
