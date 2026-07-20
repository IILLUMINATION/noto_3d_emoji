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

List<TextSpan> _buildSpans(String text, TextStyle style, TextStyle? emojiStyle) {
  if (text.isEmpty) return [];

  final List<TextSpan> spans = [];
  final StringBuffer buf = StringBuffer();
  final int len = text.length;

  void flush() {
    if (buf.isNotEmpty) {
      spans.add(TextSpan(text: buf.toString(), style: style));
      buf.clear();
    }
  }

  int i = 0;
  while (i < len) {
    final int codePoint = text.codeUnitAt(i);
    final bool isHighSurrogate = codePoint >= 0xD800 && codePoint <= 0xDBFF;

    if (isHighSurrogate && i + 1 < len) {
      final int low = text.codeUnitAt(i + 1);
      if (low >= 0xDC00 && low <= 0xDFFF) {
        final int rune = 0x10000 + (codePoint - 0xD800) * 0x400 + (low - 0xDC00);
        if (_isEmojiRune(rune)) {
          flush();
          spans.add(TextSpan(
            text: String.fromCharCodes([codePoint, low]),
            style: emojiStyle,
          ));
          i += 2;
          continue;
        }
        buf.writeCharCode(codePoint);
        buf.writeCharCode(low);
        i += 2;
        continue;
      }
    }

    if (_isEmojiRune(codePoint)) {
      flush();
      spans.add(TextSpan(
        text: String.fromCharCode(codePoint),
        style: emojiStyle,
      ));
    } else {
      buf.writeCharCode(codePoint);
    }
    i++;
  }

  flush();
  return spans;
}

/// A [Text] replacement that applies the Noto Emoji font to emoji glyphs.
///
/// Regular (non-emoji) text uses the default [style]. Emoji codepoints are
/// rendered with the font loaded by [NotoEmoji.initialize].
/// Accepts the same parameters as Flutter's [Text] widget.
class EmojiText extends StatelessWidget {
  /// Creates a widget that displays [data] with automatic emoji font.
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

  /// The text to display. Emoji within this string use the Noto font.
  final String data;

  /// {@macro flutter.widgets.Text.style}
  final TextStyle? style;

  /// {@macro flutter.widgets.Text.strutStyle}
  final StrutStyle? strutStyle;

  /// {@macro flutter.widgets.Text.textAlign}
  final TextAlign? textAlign;

  /// {@macro flutter.widgets.Text.textDirection}
  final TextDirection? textDirection;

  /// {@macro flutter.widgets.Text.locale}
  final Locale? locale;

  /// {@macro flutter.widgets.Text.softWrap}
  final bool? softWrap;

  /// {@macro flutter.widgets.Text.overflow}
  final TextOverflow? overflow;

  /// {@macro flutter.widgets.Text.textScaleFactor}
  final double? textScaleFactor;

  /// {@macro flutter.widgets.Text.maxLines}
  final int? maxLines;

  /// {@macro flutter.widgets.Text.semanticsLabel}
  final String? semanticsLabel;

  /// {@macro flutter.widgets.Text.textWidthBasis}
  final TextWidthBasis? textWidthBasis;

  /// {@macro flutter.widgets.Text.textHeightBehavior}
  final TextHeightBehavior? textHeightBehavior;

  /// {@macro flutter.widgets.Text.selectionColor}
  final Color? selectionColor;

  @override
  Widget build(BuildContext context) {
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

    final TextStyle emojiStyle = merged.copyWith(
      fontFamily: NotoEmoji.fontFamily,
    );

    final List<TextSpan> spans = _buildSpans(data, merged, emojiStyle);

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

/// A [Text.rich] replacement that applies the Noto Emoji font inside a
/// [TextSpan] tree. Same API as Flutter's [Text.rich].
class EmojiTextRich extends StatelessWidget {
  /// Creates a rich-text widget with automatic emoji font resolution.
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

  /// The root [TextSpan] to display. Descendant emoji use the Noto font.
  final TextSpan textSpan;

  /// {@macro flutter.widgets.Text.style}
  final TextStyle? style;

  /// {@macro flutter.widgets.Text.strutStyle}
  final StrutStyle? strutStyle;

  /// {@macro flutter.widgets.Text.textAlign}
  final TextAlign? textAlign;

  /// {@macro flutter.widgets.Text.textDirection}
  final TextDirection? textDirection;

  /// {@macro flutter.widgets.Text.locale}
  final Locale? locale;

  /// {@macro flutter.widgets.Text.softWrap}
  final bool? softWrap;

  /// {@macro flutter.widgets.Text.overflow}
  final TextOverflow? overflow;

  /// {@macro flutter.widgets.Text.textScaleFactor}
  final double? textScaleFactor;

  /// {@macro flutter.widgets.Text.maxLines}
  final int? maxLines;

  /// {@macro flutter.widgets.Text.semanticsLabel}
  final String? semanticsLabel;

  /// {@macro flutter.widgets.Text.textWidthBasis}
  final TextWidthBasis? textWidthBasis;

  /// {@macro flutter.widgets.Text.textHeightBehavior}
  final TextHeightBehavior? textHeightBehavior;

  /// {@macro flutter.widgets.Text.selectionColor}
  final Color? selectionColor;

  @override
  Widget build(BuildContext context) {
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

    final TextStyle emojiStyle = merged.copyWith(
      fontFamily: NotoEmoji.fontFamily,
    );

    return Text.rich(
      _applyEmojiToSpan(textSpan, merged, emojiStyle),
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
