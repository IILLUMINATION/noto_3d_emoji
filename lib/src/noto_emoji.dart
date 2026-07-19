import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class NotoEmoji {
  NotoEmoji._();

  static bool _initialized = false;
  static String? _fontFamily;

  static const _defaultFontFamily = 'NotoEmoji3D';
  static const _cacheVersion = 2;

  static bool get isInitialized => _initialized;
  static String? get fontFamily => _fontFamily;

  static Future<void> initialize({
    required String url,
    String fontFamily = _defaultFontFamily,
    void Function(int received, int total)? onProgress,
    String? Function()? cacheDirProvider,
  }) async {
    if (_initialized && _fontFamily == fontFamily) return;

    _fontFamily = fontFamily;

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

    _initialized = true;
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
    final String dir = await _defaultCacheDir();
    final File file = File('$dir/$fontFamily.ttf');
    final File versionFile = File('$dir/$fontFamily.version');
    if (await file.exists()) await file.delete();
    if (await versionFile.exists()) await versionFile.delete();
    _initialized = false;
    _fontFamily = null;
  }
}
