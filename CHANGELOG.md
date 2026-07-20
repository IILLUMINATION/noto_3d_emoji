## 2.0.0

- **Font split into 10 category subsets** (base, smileys, gestures, animals, food, travel, activities, objects, symbols, flags)
- First download only **5 MB** (base), down from 142 MB
- `NotoEmoji.initialize()` with `baseUrl` + `preloadCategories` params
- Lazy loading via `NotoEmoji.loadCategory()` / `loadCategories()`
- `ValueNotifier<Set<String>> loadedCategories` for reactive UI
- Per-rune font family resolution in `EmojiText` / `EmojiTextRich`
- All widgets auto-redraw when categories load
- Legacy mode preserved via `initializeLegacy()` for monolithic TTF

## 1.0.0

- Download and cache Noto Color Emoji font from a custom server
- EmojiText widget with automatic font fallback
- Cache versioning
