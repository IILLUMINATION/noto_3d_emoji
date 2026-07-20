import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class NotoEmoji {
  NotoEmoji._();

  static const _defaultBaseUrl = 'https://meander.sbs/cdn';
  static const _defaultFontFamily = 'NotoEmoji3D';
  static const _cacheVersion = 3;

  static const categories = [
    'base',
    'smileys',
    'gestures',
    'animals',
    'food',
    'travel',
    'activities',
    'objects',
    'symbols',
    'flags',
  ];

  // Codepoints included in the base subset (from subset.sh TOP_EMOJI + Fitzpatrick).
  // Used for fallback — if a codepoint is in the base font, apply it even when
  // the specific category hasn't loaded yet.
  static const Set<int> _baseEmojis = {
    0x1F600, 0x1F603, 0x1F604, 0x1F60A, 0x1F60D, 0x1F618, 0x1F602, 0x1F923,
    0x1F60E, 0x1F60F, 0x1F612, 0x1F61E, 0x1F622, 0x1F62D, 0x1F629, 0x1F62B,
    0x1F4AA, 0x1F44D, 0x1F44B, 0x1F44F, 0x1F64C, 0x1F64F, 0x1F91D,
    0x1F44C, 0x270C, 0x270A, 0x270B,
    0x2764, 0x1F49C, 0x1F49B, 0x1F49A, 0x1F499, 0x1F9E1, 0x1F5A4,
    0x1F525, 0x2728, 0x2B50, 0x1F31F, 0x2600, 0x1F308, 0x1F389, 0x1F381,
    0x1F680, 0x1F697, 0x2708, 0x1F30D, 0x1F30E, 0x1F30F,
    0x1F4F1, 0x1F4BB, 0x1F4AC, 0x1F4AF, 0x1F4A1, 0x1F4A3,
    0x1F354, 0x1F355, 0x1F37A, 0x1F37B, 0x2615, 0x1F363, 0x1F366,
    0x1F436, 0x1F431, 0x1F434, 0x1F437, 0x1F438, 0x1F41B, 0x1F41E,
    0x1F3AE, 0x1F3C0, 0x1F3C6, 0x26BD, 0x1F3B5, 0x1F3B9,
    0x2665, 0x2666, 0x2660, 0x2663, 0x267B, 0x2139, 0x24C2, 0x3297, 0x3299,
    0x2640, 0x2642, 0x2695, 0x2696, 0x2697, 0x2699, 0x269B, 0x269C,
    0x23F0, 0x23F3, 0x231A, 0x231B, 0x23F1, 0x23F2,
    0x1F3FB, 0x1F3FC, 0x1F3FD, 0x1F3FE, 0x1F3FF,
  };

  static String _baseUrl = _defaultBaseUrl;
  static String _fontFamily = _defaultFontFamily;
  static bool _legacyMode = false;

  static final ValueNotifier<Set<String>> loadedCategories =
      ValueNotifier<Set<String>>({});

  static String get baseUrl => _baseUrl;
  static String get fontFamily => _fontFamily;
  static bool get isInitialized => _legacyMode || loadedCategories.value.isNotEmpty;
  static bool get isLegacyMode => _legacyMode;

  static Future<void> initialize({
    String? baseUrl,
    List<String> preloadCategories = const ['base'],
    String fontFamily = _defaultFontFamily,
  }) async {
    _fontFamily = fontFamily;
    _legacyMode = false;

    if (baseUrl != null) {
      _baseUrl = baseUrl;
    }

    await loadCategories(preloadCategories);
  }

  static Future<void> initializeLegacy({
    required String url,
    String fontFamily = _defaultFontFamily,
    void Function(int received, int total)? onProgress,
    String? Function()? cacheDirProvider,
  }) async {
    if (isInitialized && _fontFamily == fontFamily) return;

    _fontFamily = fontFamily;
    _legacyMode = true;

    final String dir = cacheDirProvider?.call() ?? (await _defaultCacheDir());
    final File file = File('$dir/$fontFamily.ttf');
    final File versionFile = File('$dir/$fontFamily.version');

    final bool needsDownload = !await file.exists() ||
        await _cacheVersionMismatch(versionFile);

    if (needsDownload) {
      await _downloadFile(url, file, onProgress: onProgress);
      await versionFile.writeAsString('$_cacheVersion\n$url');
    }

    final Uint8List bytes = await file.readAsBytes();
    final ByteData data = ByteData.sublistView(bytes);

    final FontLoader fontLoader = FontLoader(fontFamily);
    fontLoader.addFont(Future.value(data));
    await fontLoader.load();

    loadedCategories.value = {...categories};
  }

  static Future<void> loadCategory(String category) async {
    if (!categories.contains(category)) {
      throw ArgumentError('Unknown category: $category. '
          'Valid categories: ${categories.join(', ')}');
    }
    if (loadedCategories.value.contains(category)) return;

    final family = _familyForCategory(category);
    final url = '$_baseUrl/noto_$category.ttf';
    final String dir = await _defaultCacheDir();
    final File file = File('$dir/$family.ttf');
    final File versionFile = File('$dir/$family.version');

    final bool needsDownload = !await file.exists() ||
        await _cacheVersionMismatch(versionFile);

    if (needsDownload) {
      await _downloadFile(url, file);
      await versionFile.writeAsString('$_cacheVersion\n$url');
    }

    final Uint8List bytes = await file.readAsBytes();
    final ByteData data = ByteData.sublistView(bytes);

    final FontLoader fontLoader = FontLoader(family);
    fontLoader.addFont(Future.value(data));
    await fontLoader.load();

    loadedCategories.value = {...loadedCategories.value, category};
  }

  static Future<void> loadCategories(List<String> cats) async {
    for (final cat in cats) {
      await loadCategory(cat);
    }
  }

  static bool hasCategory(String category) =>
      _legacyMode || loadedCategories.value.contains(category);

  static String getFontFamilyForRune(int codePoint) {
    if (_legacyMode) return _fontFamily;

    final cat = _categoryForRune(codePoint);
    if (cat != null && loadedCategories.value.contains(cat)) {
      return _familyForCategory(cat);
    }

    // Fall back to base font for popular emoji that are in the base subset
    if (loadedCategories.value.contains('base') &&
        _baseEmojis.contains(codePoint)) {
      return _familyForCategory('base');
    }

    return '';
  }

  static String? getCategoryForRune(int codePoint) {
    return _categoryForRune(codePoint);
  }

  static String _familyForCategory(String category) => '${_fontFamily}_$category';

  static String? _categoryForRune(int codePoint) {
    // food — narrow ranges before broader travel
    if (codePoint >= 0x1F344 && codePoint <= 0x1F37F ||
        codePoint == 0x2615) {
      return 'food';
    }
    // flags — overlaps with activities (1F3F3-1F3F4)
    if (codePoint >= 0x1F1E6 && codePoint <= 0x1F1FF ||
        codePoint >= 0x1F3F3 && codePoint <= 0x1F3F4) {
      return 'flags';
    }
    // activities — narrow ranges before broader travel
    if (codePoint >= 0x1F3A0 && codePoint <= 0x1F3FF ||
        codePoint >= 0x26BD && codePoint <= 0x26BE) {
      return 'activities';
    }
    // symbols — specific overlaps with dingbats/broad ranges
    if (codePoint == 0x2764 ||
        codePoint == 0x2B50 ||
        codePoint >= 0x2930 && codePoint <= 0x2935 ||
        codePoint >= 0x2B05 && codePoint <= 0x2B07 ||
        codePoint == 0x2B55 ||
        codePoint == 0x3030 ||
        codePoint == 0x303D ||
        codePoint == 0x3297 ||
        codePoint == 0x3299) {
      return 'symbols';
    }
    // gesture overlaps with smileys dingbats — 0x270A-0x270D
    if (codePoint >= 0x1F44B && codePoint <= 0x1F450 ||
        codePoint >= 0x1F590 && codePoint <= 0x1F5A3 ||
        codePoint >= 0x270A && codePoint <= 0x270D) {
      return 'gestures';
    }
    // travel — includes 0x2708,0x270F which overlap with smileys dingbats
    if (codePoint >= 0x1F680 && codePoint <= 0x1F6FF ||
        codePoint >= 0x2600 && codePoint <= 0x26FF ||
        codePoint == 0x2708 || codePoint == 0x270F) {
      return 'travel';
    }
    // smileys — broad dingbats range
    if (codePoint >= 0x1F600 && codePoint <= 0x1F64F ||
        codePoint >= 0x2639 && codePoint <= 0x267F ||
        codePoint >= 0x2702 && codePoint <= 0x27B0) {
      return 'smileys';
    }
    // animals
    if (codePoint >= 0x1F400 && codePoint <= 0x1F43F ||
        codePoint >= 0x1F980 && codePoint <= 0x1F9FF) {
      return 'animals';
    }
    // objects
    if (codePoint >= 0x1F4A0 && codePoint <= 0x1F4FF ||
        codePoint >= 0x1F500 && codePoint <= 0x1F5FF) {
      return 'objects';
    }
    // flags
    if (codePoint >= 0x1F1E6 && codePoint <= 0x1F1FF ||
        codePoint >= 0x1F3F3 && codePoint <= 0x1F3F4) {
      return 'flags';
    }
    return null;
  }

  static Future<bool> _cacheVersionMismatch(File versionFile) async {
    try {
      final String content = await versionFile.readAsString();
      final List<String> parts = LineSplitter.split(content).toList();
      if (parts.isEmpty) return true;
      final int? version = int.tryParse(parts.first);
      return version != _cacheVersion;
    } catch (_) {
      return true;
    }
  }

  static Future<String> _defaultCacheDir() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  static Future<void> _downloadFile(
    String url,
    File file, {
    void Function(int received, int total)? onProgress,
  }) async {
    final HttpClient client = HttpClient();
    try {
      final HttpClientRequest request = await client.getUrl(Uri.parse(url));
      final HttpClientResponse response = await request.close();

      if (response.statusCode != 200) {
        throw HttpException(
          'Failed to download font: HTTP ${response.statusCode}',
          uri: Uri.parse(url),
        );
      }

      final int total = response.contentLength;
      await file.create(recursive: true);
      final IOSink sink = file.openWrite();

      int received = 0;
      await for (final List<int> chunk in response) {
        received += chunk.length;
        sink.add(chunk);
        if (onProgress != null) {
          onProgress(received, total);
        }
      }

      await sink.flush();
      await sink.close();
    } finally {
      client.close();
    }
  }

  static Future<void> clearCache({
    String fontFamily = _defaultFontFamily,
  }) async {
    if (_legacyMode) {
      final String dir = await _defaultCacheDir();
      final File file = File('$dir/$fontFamily.ttf');
      final File versionFile = File('$dir/$fontFamily.version');
      if (await file.exists()) await file.delete();
      if (await versionFile.exists()) await versionFile.delete();
      _legacyMode = false;
      loadedCategories.value = {};
      return;
    }

    for (final cat in categories) {
      final family = _familyForCategory(cat);
      final String dir = await _defaultCacheDir();
      final File file = File('$dir/$family.ttf');
      final File versionFile = File('$dir/$family.version');
      if (await file.exists()) await file.delete();
      if (await versionFile.exists()) await versionFile.delete();
    }
    loadedCategories.value = {};
  }
}
