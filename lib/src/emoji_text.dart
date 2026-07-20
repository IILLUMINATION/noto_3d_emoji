import 'package:flutter/material.dart';

import 'noto_emoji.dart';

bool _isEmojiRune(int codePoint) {
  if (codePoint >= 0x1F000) return true;
  if (codePoint >= 0x2600 && codePoint <= 0x27BF) return true;
  if (codePoint >= 0x2300 && codePoint <= 0x23FF) return true;
  if (codePoint >= 0x2194 && codePoint <= 0x2199) return true;
  if (codePoint >= 0x21A9 && codePoint <= 0x21AA) return true;
  if (codePoint >= 0x2934 && codePoint <= 0x2935) return true;
  if (codePoint >= 0x2B05 && codePoint <= 0x2B07) return true;
  if (codePoint >= 0x2B1B && codePoint <= 0x2B1C) return true;
  if (codePoint >= 0x1F1E6 && codePoint <= 0x1F1FF) return true;
  if (codePoint >= 0x23E9 && codePoint <= 0x23F3) return true;
  if (codePoint >= 0x23F8 && codePoint <= 0x23FA) return true;
  if (codePoint >= 0x25FB && codePoint <= 0x25FE) return true;
  if (codePoint >= 0xFE00 && codePoint <= 0xFE0F) return true;
  if (codePoint == 0x00A9 || codePoint == 0x00AE) return true;
  if (codePoint == 0x203C || codePoint == 0x2049) return true;
  if (codePoint == 0x2122 || codePoint == 0x2139) return true;
  if (codePoint == 0x200D || codePoint == 0x20E3) return true;
  if (codePoint == 0x231A || codePoint == 0x231B) return true;
  if (codePoint == 0x2328 || codePoint == 0x23CF) return true;
  if (codePoint == 0x24C2) return true;
  if (codePoint == 0x25AA || codePoint == 0x25AB) return true;
  if (codePoint == 0x25B6 || codePoint == 0x25C0) return true;
  if (codePoint == 0x2B50 || codePoint == 0x2B55) return true;
  if (codePoint == 0x3030 || codePoint == 0x303D) return true;
  if (codePoint == 0x3297 || codePoint == 0x3299) return true;
  return false;
}

List<TextSpan> _buildSpans(String text, TextStyle style, TextStyle baseEmojiStyle) {
  if (text.isEmpty) return [];

  final List<TextSpan> spans = [];
  final StringBuffer nonEmojiBuf = StringBuffer();

  void flushNonEmoji() {
    if (nonEmojiBuf.isNotEmpty) {
      spans.add(TextSpan(text: nonEmojiBuf.toString(), style: style));
      nonEmojiBuf.clear();
    }
  }

  for (final String cluster in text.characters) {
    int? firstEmojiRune;
    for (final int rune in cluster.runes) {
      if (_isEmojiRune(rune)) {
        firstEmojiRune = rune;
        break;
      }
    }

    if (firstEmojiRune != null) {
      flushNonEmoji();
      final family = NotoEmoji.getFontFamilyForRune(firstEmojiRune);
      spans.add(TextSpan(
        text: cluster,
        style: family.isNotEmpty
            ? baseEmojiStyle.copyWith(fontFamily: family)
            : baseEmojiStyle,
      ));
    } else {
      nonEmojiBuf.write(cluster);
    }
  }

  flushNonEmoji();
  return spans;
}

class _EmojiTextState extends State<EmojiText> {
  @override
  void initState() {
    super.initState();
    NotoEmoji.loadedCategories.addListener(_onCategoriesChanged);
  }

  @override
  void dispose() {
    NotoEmoji.loadedCategories.removeListener(_onCategoriesChanged);
    super.dispose();
  }

  void _onCategoriesChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget._build(context);
  }
}

class EmojiText extends StatefulWidget {
  const EmojiText(
    this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  });

  final String data;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  @override
  State<EmojiText> createState() => _EmojiTextState();

  Widget _build(BuildContext context) {
    final TextStyle base = DefaultTextStyle.of(context).style;
    final TextStyle merged = base.merge(style);

    if (!NotoEmoji.isInitialized) {
      return Text(
        data,
        style: merged,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        textScaleFactor: textScaleFactor,
        maxLines: maxLines,
        semanticsLabel: semanticsLabel,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
      );
    }

    final List<TextSpan> spans = _buildSpans(data, merged, merged);

    if (spans.length == 1 && spans.first.style == merged) {
      return Text(
        data,
        style: merged,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        textScaleFactor: textScaleFactor,
        maxLines: maxLines,
        semanticsLabel: semanticsLabel,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
      );
    }

    return Text.rich(
      TextSpan(children: spans),
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }
}

class EmojiTextRich extends StatefulWidget {
  const EmojiTextRich(
    this.textSpan, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  });

  final TextSpan textSpan;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  @override
  State<EmojiTextRich> createState() => _EmojiTextRichState();

  Widget _build(BuildContext context) {
    final TextStyle base = DefaultTextStyle.of(context).style;
    final TextStyle merged = base.merge(style);

    if (!NotoEmoji.isInitialized) {
      return Text.rich(
        textSpan,
        style: merged,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        textScaleFactor: textScaleFactor,
        maxLines: maxLines,
        semanticsLabel: semanticsLabel,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
      );
    }

    return Text.rich(
      _applyEmojiToSpan(textSpan, merged, merged),
      style: merged,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }

  TextSpan _applyEmojiToSpan(TextSpan span, TextStyle baseStyle, TextStyle emojiStyle) {
    final TextStyle resolvedStyle = baseStyle.merge(span.style);
    final List<InlineSpan>? originalChildren = span.children;
    final List<InlineSpan> newChildren = originalChildren != null
        ? originalChildren.map((child) {
            if (child is TextSpan) {
              return _applyEmojiToSpan(child, resolvedStyle, emojiStyle);
            }
            return child;
          }).toList()
        : [];

    if (span.text == null || span.text!.isEmpty) {
      return TextSpan(
        text: span.text,
        style: span.style,
        children: newChildren.isNotEmpty ? newChildren : null,
      );
    }

    final List<TextSpan> segmented = _buildSpans(
      span.text!,
      resolvedStyle,
      emojiStyle,
    );

    if (newChildren.isNotEmpty) {
      segmented.addAll(newChildren.cast<TextSpan>());
    }

    return TextSpan(
      style: span.style,
      children: segmented,
    );
  }
}

class _EmojiTextRichState extends State<EmojiTextRich> {
  @override
  void initState() {
    super.initState();
    NotoEmoji.loadedCategories.addListener(_onCategoriesChanged);
  }

  @override
  void dispose() {
    NotoEmoji.loadedCategories.removeListener(_onCategoriesChanged);
    super.dispose();
  }

  void _onCategoriesChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget._build(context);
  }
}
