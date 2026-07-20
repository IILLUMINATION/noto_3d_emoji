# noto_3d_emoji

Google Noto 3D Color Emoji for Flutter.

Downloads and caches the latest Noto Color Emoji font from your own server,
then renders emoji in your app with the 3D look.

![General emoji overview](https://raw.githubusercontent.com/IILLUMINATION/noto_3d_emoji/main/emoji-overview.png)

## Usage

```dart
import 'package:noto_3d_emoji/noto_3d_emoji.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotoEmoji.initialize(
    url: 'https://your-server.com/NotoColorEmoji_vector.ttf',
    onProgress: (received, total) {
      print('$received / $total');
    },
  );

  runApp(const MyApp());
}
```

Then use `EmojiText` anywhere:

```dart
EmojiText('Hello 🌍! This 🔥 is amazing 🎉')
```

![Emoji faces](https://raw.githubusercontent.com/IILLUMINATION/noto_3d_emoji/main/smiley-faces.png)

## How it works

1. The TTF file is downloaded once from your server and cached locally.
2. `NotoEmoji.initialize()` registers the font with Flutter's font system.
3. `EmojiText` uses `fontFamilyFallback` so only emoji glyphs use the 3D font,
   while regular text keeps your app's default look.

![Emoji grid by category](https://raw.githubusercontent.com/IILLUMINATION/noto_3d_emoji/main/emoji-categories-grid.png)

## API

### `NotoEmoji.initialize()`
Downloads and registers the font. Must be called before using `EmojiText`.

| Parameter | Type | Description |
|-----------|------|-------------|
| `url` | `String` | URL to the `.ttf` file |
| `fontFamily` | `String` | Font family name (default: `NotoEmoji3D`) |
| `onProgress` | `(int,int)?` | Download progress callback |
| `cacheDirProvider` | `String? Function()?` | Custom cache directory |

### `NotoEmoji.clearCache()`
Deletes the cached font file. Next `initialize()` call will re-download.

### `EmojiText`
A drop-in replacement for `Text` with emoji font fallback.

![Usage in UI](https://raw.githubusercontent.com/IILLUMINATION/noto_3d_emoji/main/emoji-in-ui.png)

### `EmojiTextRich`
A drop-in replacement for `Text.rich` with emoji font fallback.

![Emoji in text field](https://raw.githubusercontent.com/IILLUMINATION/noto_3d_emoji/main/emoji-in-text-field.png)

## Platform support

| Platform | COLR font support |
|----------|-------------------|
| Android 13+ | Full color |
| Android 8–12 | Limited (may render outline) |
| Web (Chrome 98+, Firefox 107+, Safari 15.4+) | Full color |
| Linux | Full color (with modern freetype) |
| macOS / iOS | ⚠️ No COLR support — emoji render as outlines |

## License

Code: MIT  
Font: SIL Open Font License 1.1 (Google Noto Emoji)
