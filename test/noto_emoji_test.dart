import 'package:flutter_test/flutter_test.dart';
import 'package:noto_3d_emoji/noto_3d_emoji.dart';

void main() {
  test('NotoEmoji constants are accessible', () {
    expect(NotoEmoji.isInitialized, false);
    expect(NotoEmoji.fontFamily, isNull);
  });
}
