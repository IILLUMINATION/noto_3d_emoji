# noto_3d_emoji

Google Noto 3D Color Emoji for Flutter.

Downloads and caches the vector Noto Color Emoji font (142 MB full, **5 MB
first-load**) from your server, then renders emoji with the 3D look using
category-based lazy loading.

## Quick start

```dart
import 'package:noto_3d_emoji/noto_3d_emoji.dart';

await NotoEmoji.initialize(
  baseUrl: 'https://your-server.com/cdn',
  preloadCategories: ['base'],
);

EmojiText('Hello 🌍! This 🔥 is amazing 🎉')
```

First download is ~5 MB (base category with TOP-100 emoji). Other categories
load on demand via `NotoEmoji.loadCategory('smileys')` — or let the widget load
them automatically.

## How it works (v2.0)

1. The 142 MB COLRv1 font is split into **10 category subsets** (base, smileys,
   gestures, animals, food, travel, activities, objects, symbols, flags).
2. `base` includes ASCII/Latin-1 + TOP-100 emoji — covers 90% of chat use cases
   in 5 MB.
3. `NotoEmoji.initialize()` preloads selected categories; subsequent calls to
   `loadCategory()` lazy-load others.
4. `EmojiText` segments text per-rune and assigns the correct per-category font
   family. As categories load, glyphs seamlessly upgrade from system emoji to
   3D.
5. All category fonts include ZWJ (U+200D), VS-16 (U+FE0F), and skin-tone
   modifiers (U+1F3FB-1F3FF) via `pyftsubset --layout-features="*"` — composite
   emoji ligatures work correctly.

## API

### `NotoEmoji.initialize()`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `baseUrl` | `String?` | `'https://meander.sbs/cdn'` | CDN base URL |
| `preloadCategories` | `List<String>` | `['base']` | Categories to preload |
| `fontFamily` | `String` | `'NotoEmoji3D'` | Base font family name |

### `NotoEmoji.loadCategory(String category)`
Lazy-loads one category (async). Multiple calls are deduplicated.

### `NotoEmoji.loadedCategories`
`ValueNotifier<Set<String>>` — react to category loading progress:
```dart
NotoEmoji.loadedCategories.addListener(() {
  setState(() {});
});
```

### `NotoEmoji.initializeLegacy()`
Original v1 API for monolithic TTF download (142 MB):
```dart
await NotoEmoji.initializeLegacy(
  url: 'https://your-server.com/NotoColorEmoji_vector.ttf',
  onProgress: (r, t) => print('$r/$t'),
);
```

### Categories

| File | Size | Content |
|------|------|---------|
| `noto_base.ttf` | ~5 MB | ASCII + Latin-1 + TOP-100 emoji + skin tones |
| `noto_smileys.ttf` | ~5 MB | Emoticons, misc symbols, dingbats |
| `noto_gestures.ttf` | ~3 MB | Hand gestures, skin-tone variants |
| `noto_animals.ttf` | ~8 MB | Animals & nature |
| `noto_food.ttf` | ~2 MB | Food & drink |
| `noto_travel.ttf` | ~7 MB | Transport, weather, places |
| `noto_activities.ttf` | ~5 MB | Sports, games, entertainment |
| `noto_objects.ttf` | ~8 MB | Objects, tech, office |
| `noto_symbols.ttf` | ~0.3 MB | Hearts, stars, arrows |
| `noto_flags.ttf` | ~0.05 MB | Flags |
| **Total** | **~42 MB** | **(vs 142 MB full)** |

## Platform support

| Platform | COLR font support |
|----------|-------------------|
| Android 13+ | Full color |
| Android 8–12 | Limited (may render outline) |
| Web (Chrome 98+, Firefox 107+, Safari 15.4+) | Full color |
| Linux | Full color (with modern freetype) |
| macOS / iOS | ⚠️ No COLR — emoji render as outlines |

## License

Code: MIT  
Font: SIL Open Font License 1.1 (Google Noto Emoji)
