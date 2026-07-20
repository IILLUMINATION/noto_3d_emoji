import 'package:flutter_test/flutter_test.dart';
import 'package:noto_3d_emoji/noto_3d_emoji.dart';

void main() {
  test('NotoEmoji constants are accessible', () {
    expect(NotoEmoji.isInitialized, false);
    expect(NotoEmoji.fontFamily, 'NotoEmoji3D');
    expect(NotoEmoji.categories.length, 10);
    expect(NotoEmoji.categories.first, 'base');
    expect(NotoEmoji.loadedCategories.value, isEmpty);
  });

  test('_categoryForRune maps codepoints correctly', () {
    expect(NotoEmoji.getCategoryForRune(0x1F600), 'smileys');
    expect(NotoEmoji.getCategoryForRune(0x1F44B), 'gestures');
    expect(NotoEmoji.getCategoryForRune(0x1F400), 'animals');
    expect(NotoEmoji.getCategoryForRune(0x1F354), 'food');
    expect(NotoEmoji.getCategoryForRune(0x1F680), 'travel');
    expect(NotoEmoji.getCategoryForRune(0x1F3A0), 'activities');
    expect(NotoEmoji.getCategoryForRune(0x1F4A0), 'objects');
    expect(NotoEmoji.getCategoryForRune(0x2764), 'symbols');
    expect(NotoEmoji.getCategoryForRune(0x1F3F3), 'flags');
  });
}
