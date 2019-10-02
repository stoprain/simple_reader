import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  test('test date format', () async {
    print(DateTime.now().millisecondsSinceEpoch);
    //Sun Sep 29 14:30:10 +0800 2019
    String t = 'Sun Sep 29 14:30:10 +0800 2019'.replaceFirst(' +0800', '');
    final df = new DateFormat("EEE MMM dd HH:mm:ss yyyy");
    expect(t, df.format(df.parse(t)));
  });
}
