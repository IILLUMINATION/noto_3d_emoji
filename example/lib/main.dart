import 'package:flutter/material.dart';
import 'package:noto_3d_emoji/noto_3d_emoji.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Noto 3D Emoji',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const EmojiScreen(),
    );
  }
}

class EmojiScreen extends StatefulWidget {
  const EmojiScreen({super.key});

  @override
  State<EmojiScreen> createState() => _EmojiScreenState();
}

class _EmojiScreenState extends State<EmojiScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  bool _ready = false;
  double _progress = 0;
  String? _error;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadFont();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFont() async {
    setState(() {
      _loading = true;
      _error = null;
      _progress = 0;
    });
    try {
      await NotoEmoji.initialize(
        url: 'https://meander.sbs/cdn/NotoColorEmoji_vector.ttf',
        onProgress: (int received, int total) {
          final double pct = total > 0 ? received / total : 0.0;
          setState(() => _progress = pct);
        },
      );
      setState(() {
        _ready = true;
        _loading = false;
      });
      _fadeCtrl.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: _buildBody(cs),
    );
  }

  Widget _buildBody(ColorScheme cs) {
    if (_loading) {
      return _buildLoadingScreen(cs);
    }
    if (_error != null) {
      return _buildErrorScreen(cs);
    }
    if (!_ready) {
      return const Center(child: Text('Not initialized'));
    }
    return _buildShowcase(cs);
  }

  Widget _buildLoadingScreen(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Noto 3D Emoji',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: _progress > 0 ? _progress : null,
                      strokeWidth: 6,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    _progress > 0
                        ? '${(_progress * 100).toStringAsFixed(0)}%'
                        : '...',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Downloading 142 MB font...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'One-time download, cached forever',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 72, color: cs.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load font',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () async {
                await NotoEmoji.clearCache();
                _loadFont();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Clear cache & retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShowcase(ColorScheme cs) {
    return FadeTransition(
      opacity: _fadeIn,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Noto 3D Emoji'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Reload font',
              onPressed: () async {
                await NotoEmoji.clearCache();
                setState(() {
                  _ready = false;
                  _progress = 0;
                });
                _loadFont();
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _HeroSection(cs: cs),
            const SizedBox(height: 16),
            _InlineDemo(cs: cs),
            const SizedBox(height: 16),
            _GiantEmojiGrid(cs: cs),
            const SizedBox(height: 16),
            ..._buildCategorySections(cs),
            const SizedBox(height: 16),
            _SampleTexts(cs: cs),
            const SizedBox(height: 16),
            _UsageApi(cs: cs),
          ],
        ),
      ),
    );
  }
}

// ─── HERO ────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final ColorScheme cs;
  const _HeroSection({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cs.primaryContainer.withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Noto 3D Emoji',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimaryContainer,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Google Noto Color Emoji — 3D vector style',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 20),
            EmojiText(
              '\u{1F44B}\u{1F3FB} \u{1F308} \u{2728} \u{1F31F} \u{1F389} \u{1F3C6}',
              style: TextStyle(fontSize: 48, color: cs.onPrimaryContainer),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            EmojiText(
              '\u{1F525} \u{1F680} \u{2764}\u{FE0F} \u{1F60D} \u{1F4AF} \u{1F3B5}',
              style: TextStyle(fontSize: 36, color: cs.onPrimaryContainer),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── INLINE TEXT DEMO ────────────────────────────────────────────────────────

class _InlineDemo extends StatelessWidget {
  final ColorScheme cs;
  const _InlineDemo({required this.cs});

  @override
  Widget build(BuildContext context) {
    final body = Theme.of(context).textTheme.bodyLarge;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('Inline with regular text'),
            const SizedBox(height: 8),
            EmojiText(
              'Notifications: You have 3 new messages \u{1F4E8} and 2 friend requests \u{1F91D}. '
              'Check your inbox \u{1F4EC} for details.',
              style: body,
            ),
            const Divider(height: 24),
            EmojiText(
              'Weather: \u{2600}\u{FE0F} 24\u{00B0}C with a chance of \u{26C8}\u{FE0F} '
              'in the evening. Don\'t forget your \u{2602}\u{FE0F}!',
              style: body,
            ),
            const Divider(height: 24),
            EmojiText(
              'Leaderboard \u{1F3C6}: 1st \u{1F947} 2nd \u{1F948} 3rd \u{1F949} '
              '\u{2022} Your rank: #42 \u{1F4AA}\u{1F3FB}',
              style: body,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── GIANT EMOJI GRID ────────────────────────────────────────────────────────

class _GiantEmojiGrid extends StatelessWidget {
  final ColorScheme cs;
  const _GiantEmojiGrid({required this.cs});

  static const _items = <(String, String)>[
    ('Grinning', '\u{1F600}'),
    ('Joy', '\u{1F602}'),
    ('Heart Eyes', '\u{1F60D}'),
    ('Fire', '\u{1F525}'),
    ('Rocket', '\u{1F680}'),
    ('100', '\u{1F4AF}'),
    ('Party', '\u{1F389}'),
    ('Skull', '\u{1F480}'),
    ('Alien', '\u{1F47D}'),
    ('Unicorn', '\u{1F984}'),
    ('Dragon', '\u{1F409}'),
    ('Pizza', '\u{1F355}'),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('Large format'),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.85,
              children: _items.map((e) {
                return Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      EmojiText(
                        e.$2,
                        style: const TextStyle(fontSize: 42),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        e.$1,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── CATEGORIES ──────────────────────────────────────────────────────────────

List<Widget> _buildCategorySections(ColorScheme cs) {
  return _categories.map((cat) {
    final chunks = _splitIntoChunks(cat.$2, 8);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(cat.$1),
            const SizedBox(height: 8),
            ...chunks.map((chunk) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: EmojiText(
                    chunk,
                    style: const TextStyle(fontSize: 32),
                  ),
                )),
          ],
        ),
      ),
    );
  }).toList();
}

List<String> _splitIntoChunks(String s, int n) {
  final runes = s.runes.toList();
  final chunks = <String>[];
  for (int i = 0; i < runes.length; i += n) {
    chunks.add(String.fromCharCodes(
      runes.sublist(i, i + n > runes.length ? runes.length : i + n),
    ));
  }
  return chunks;
}

const _categories = <(String, String)>[
  ('Smileys',
      '\u{1F600}\u{1F603}\u{1F604}\u{1F601}\u{1F606}\u{1F605}\u{1F923}\u{1F602}'
      '\u{1F642}\u{1F643}\u{1F609}\u{1F60A}\u{1F607}\u{1F60B}\u{1F60C}\u{1F60D}'
      '\u{1F618}\u{1F617}\u{1F61A}\u{1F619}\u{1F61C}\u{1F61D}\u{1F61B}\u{1F911}'
      '\u{1F914}\u{1F912}\u{1F610}\u{1F611}\u{1F636}\u{1F644}\u{1F60F}\u{1F623}'
      '\u{1F625}\u{1F62E}\u{1F62D}\u{1F622}\u{1F62B}\u{1F624}\u{1F620}\u{1F621}'
      '\u{1F92C}\u{1F92F}\u{1F633}\u{1F631}\u{1F628}\u{1F630}\u{1F640}\u{1F648}'
      '\u{1F649}\u{1F64A}\u{1F48B}\u{1F48C}\u{1F498}\u{1F49D}\u{1F496}\u{1F497}'
      '\u{1F493}\u{1F49E}\u{1F495}\u{1F49F}\u{2763}\u{1F494}\u{1F49A}\u{1F499}'
      '\u{1F49C}\u{1F49B}\u{1F5A4}\u{1F90D}\u{1F90E}\u{1F90C}'),
  ('Gestures & People',
      '\u{1F44B}\u{1F44B}\u{1F3FB}\u{1F44B}\u{1F3FC}\u{1F44B}\u{1F3FD}\u{1F44B}\u{1F3FE}\u{1F44B}\u{1F3FF}'
      '\u{270C}\u{FE0F}\u{270C}\u{1F3FB}\u{270C}\u{1F3FC}\u{270C}\u{1F3FD}\u{270C}\u{1F3FE}\u{270C}\u{1F3FF}'
      '\u{1F44D}\u{1F44E}\u{270A}\u{1F44A}\u{1F44F}\u{1F64C}\u{1F918}\u{1F919}'
      '\u{1F590}\u{1F596}\u{1F91E}\u{1F91F}\u{1F90F}\u{1F91D}'
      '\u{1F3C3}\u{1F3C4}\u{1F3CA}\u{1F6B4}\u{1F6B5}\u{1F6B6}'),
  ('Animals & Nature',
      '\u{1F436}\u{1F431}\u{1F434}\u{1F439}\u{1F430}\u{1F43B}\u{1F43C}\u{1F428}'
      '\u{1F42F}\u{1F427}\u{1F426}\u{1F425}\u{1F989}\u{1F986}\u{1F985}\u{1F984}'
      '\u{1F98D}\u{1F98A}\u{1F99D}\u{1F99E}\u{1F99F}\u{1F99C}\u{1F99B}\u{1F42E}'
      '\u{1F402}\u{1F437}\u{1F43E}\u{1F438}\u{1F435}\u{1F419}\u{1F41B}\u{1F41E}'
      '\u{1F40C}\u{1F41D}\u{1F41F}\u{1F420}\u{1F421}\u{1F433}\u{1F42B}\u{1F404}'),
  ('Food & Drink',
      '\u{1F34E}\u{1F34C}\u{1F34A}\u{1F34B}\u{1F34F}\u{1F34D}\u{1F349}\u{1F347}'
      '\u{1F348}\u{1F352}\u{1F351}\u{1F350}\u{1F353}\u{1F345}\u{1F346}\u{1F33D}'
      '\u{1F336}\u{1F33E}\u{1F344}\u{1F33F}\u{1F354}\u{1F355}\u{1F357}\u{1F356}'
      '\u{1F359}\u{1F35A}\u{1F35B}\u{1F35C}\u{1F35D}\u{1F35E}\u{1F35F}\u{1F360}'
      '\u{1F362}\u{1F363}\u{1F364}\u{1F365}\u{1F366}\u{1F367}\u{1F368}\u{1F369}'
      '\u{1F36A}\u{1F36B}\u{1F36C}\u{1F36D}\u{1F36E}\u{1F36F}\u{1F370}\u{1F371}'
      '\u{2615}\u{1F375}\u{1F376}\u{1F37E}\u{1F377}\u{1F378}\u{1F379}\u{1F37A}'),
  ('Travel & Places',
      '\u{1F30D}\u{1F30E}\u{1F30F}\u{1F310}\u{1F5FA}\u{1F5FE}\u{1F9ED}\u{1F3D4}'
      '\u{26F0}\u{1F30B}\u{1F5FB}\u{1F3D5}\u{1F3D6}\u{1F3DC}\u{1F3DD}\u{1F3DE}'
      '\u{1F3DF}\u{1F3DB}\u{1F3D7}\u{1F3D8}\u{1F3D9}\u{1F3DA}\u{1F3E0}\u{1F3E1}'
      '\u{1F3E2}\u{1F3E3}\u{1F3E4}\u{1F3E5}\u{1F3E6}\u{1F3E8}\u{1F3EA}\u{1F3EB}'
      '\u{1F3EC}\u{1F3ED}\u{1F3EF}\u{1F3F0}\u{1F492}\u{1F5FC}\u{1F5FD}\u{1F5FE}'
      '\u{2708}\u{1F6EB}\u{1F6EC}\u{1F6F3}\u{1F680}\u{1F6F0}\u{1F4BA}\u{1F681}'
      '\u{1F682}\u{1F683}\u{1F684}\u{1F685}\u{1F686}\u{1F687}\u{1F688}\u{1F689}'
      '\u{1F68A}\u{1F68B}\u{1F68C}\u{1F68D}\u{1F68E}\u{1F68F}\u{1F690}\u{1F691}'
      '\u{1F692}\u{1F693}\u{1F694}\u{1F695}\u{1F696}\u{1F697}\u{1F698}\u{1F699}'),
  ('Activities & Sports',
      '\u{1F3AE}\u{1F3AF}\u{1F3B0}\u{1F3B1}\u{1F3B2}\u{1F3B3}\u{1F3B4}\u{1F3B5}'
      '\u{1F3B6}\u{1F3B7}\u{1F3B8}\u{1F3B9}\u{1F3BA}\u{1F3BB}\u{1F3BC}\u{1F3BD}'
      '\u{1F3BE}\u{1F3BF}\u{1F3C0}\u{1F3C1}\u{1F3C2}\u{1F3C3}\u{1F3C4}\u{1F3C5}'
      '\u{1F3C6}\u{1F3C7}\u{1F3C8}\u{1F3C9}\u{1F3CA}\u{1F3CB}\u{1F3CC}\u{1F6F9}'
      '\u{26BD}\u{26BE}\u{1F94E}\u{1F94F}\u{1F94A}\u{1F94B}\u{1F94C}\u{1F94D}'),
  ('Objects & Symbols',
      '\u{1F4A1}\u{1F526}\u{1F4A3}\u{1F4A5}\u{1F4A6}\u{1F4A7}\u{1F4A8}\u{1F4A9}'
      '\u{1F4AA}\u{1F4AB}\u{1F4AC}\u{1F4AD}\u{1F4AE}\u{1F4AF}\u{1F4B0}\u{1F4B1}'
      '\u{1F4B2}\u{1F4B3}\u{1F4B4}\u{1F4B5}\u{1F4B8}\u{1F4BC}\u{1F4C0}\u{1F4C1}'
      '\u{1F4C2}\u{1F4C3}\u{1F4C4}\u{1F4C5}\u{1F4C6}\u{1F4C7}\u{1F4C8}\u{1F4C9}'
      '\u{1F4CA}\u{1F4CB}\u{1F4CC}\u{1F4CD}\u{1F4CE}\u{1F4CF}\u{1F4D0}\u{1F64B}'
      '\u{1F64D}\u{1F64E}\u{1F645}\u{1F646}\u{1F481}\u{1F64B}\u{1F9CF}\u{1F9D6}'),
  ('Flags',
      '\u{1F1E6}\u{1F1FA}\u{1F1E8}\u{1F1F3}\u{1F1E9}\u{1F1EA}\u{1F1EB}\u{1F1F7}'
      '\u{1F1EC}\u{1F1E7}\u{1F1EE}\u{1F1F9}\u{1F1EF}\u{1F1F5}\u{1F1F0}\u{1F1F7}'
      '\u{1F1F1}\u{1F1FB}\u{1F1F2}\u{1F1F4}\u{1F1F3}\u{1F1F1}\u{1F1F5}\u{1F1F9}'
      '\u{1F1F7}\u{1F1FA}\u{1F1F8}\u{1F1EC}\u{1F1F7}\u{1F1FA}\u{1F1F8}'
      '\u{1F3F4}\u{1F3F3}\u{FE0F}\u{1F3F4}\u{200D}\u{2620}\u{FE0F}'),
];

// ─── SAMPLE TEXTS ────────────────────────────────────────────────────────────

class _SampleTexts extends StatelessWidget {
  final ColorScheme cs;
  const _SampleTexts({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('Sample use cases'),
            const SizedBox(height: 8),
            _sampleRow(context, 'Rating:', '\u{2B50}\u{2B50}\u{2B50}\u{2B50}\u{2B50}'),
            const Divider(height: 16),
            _sampleRow(context, 'Status:', '\u{2705} Completed \u{26A0}\u{FE0F} Pending \u{274C} Failed'),
            const Divider(height: 16),
            _sampleRow(context, 'Reaction:', '\u{2764}\u{FE0F} 42 \u{1F44D} 18 \u{1F44E} 3 \u{1F602} 27'),
            const Divider(height: 16),
            _sampleRow(context, 'Stack:', 'Flutter \u{1F3AE} + Dart \u{1F426} = \u{2764}\u{FE0F}'),
            const Divider(height: 16),
            _sampleRow(context, 'Hero:', '\u{1F44B} Welcome to the party! \u{1F389} \u{1F37B}'),
          ],
        ),
      ),
    );
  }

  Widget _sampleRow(BuildContext context, String label, String emojiText) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
          ),
        ),
        Expanded(child: EmojiText(emojiText, style: Theme.of(context).textTheme.bodyLarge)),
      ],
    );
  }
}

// ─── USAGE / API ─────────────────────────────────────────────────────────────

class _UsageApi extends StatelessWidget {
  final ColorScheme cs;
  const _UsageApi({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('How to use'),
            const SizedBox(height: 8),
            Text(
              'Add to your app:',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "import 'package:noto_3d_emoji/noto_3d_emoji.dart';\n\n"
                "await NotoEmoji.initialize(\n"
                "  url: 'https://your-server.com/NotoColorEmoji.ttf',\n"
                ');\n\n'
                "EmojiText('Hello \u{1F30D}!')  // auto-magic",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: cs.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── COMMON ──────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
