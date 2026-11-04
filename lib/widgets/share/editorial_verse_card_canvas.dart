import 'package:flutter/material.dart';

import '../../theme/bible_theme.dart';

/// Available editorial card visual themes.
enum EditorialCardStyle {
  ivory('Marfil Códice'),
  sepia('Pergamino Sepia'),
  night('Vigilia Nocturna');

  const EditorialCardStyle(this.label);
  final String label;
}

/// A beautifully crafted tipographic postcard for biblical verses following
/// the Contemporary Editorial Codex design language.
class EditorialVerseCardCanvas extends StatelessWidget {
  const EditorialVerseCardCanvas({
    super.key,
    required this.verseText,
    required this.reference,
    this.translationLabel,
    this.style = EditorialCardStyle.ivory,
    this.showWatermark = true,
  });

  final String verseText;
  final String reference;
  final String? translationLabel;
  final EditorialCardStyle style;
  final bool showWatermark;

  /// Dynamically computes comfortable font size depending on text length
  /// to ensure long verses (like Ester 8:9) never overflow.
  double _computeFontSize(int length) {
    if (length < 80) return 20.0;
    if (length < 160) return 17.0;
    if (length < 260) return 14.5;
    return 12.5;
  }

  double _computeLineHeight(int length) {
    if (length < 80) return 1.55;
    if (length < 160) return 1.45;
    return 1.35;
  }

  @override
  Widget build(BuildContext context) {
    final (
      Color backgroundColor,
      Color textColor,
      Color accentColor,
      Color borderColor,
      Color watermarkColor,
    ) = switch (style) {
      EditorialCardStyle.ivory => (
          ReadingPalette.cream,
          ReadingPalette.charcoal,
          ReadingPalette.amber,
          ReadingPalette.amberDivider,
          const Color(0xFF8A8279),
        ),
      EditorialCardStyle.sepia => (
          ReadingPalette.sepiaSurface,
          ReadingPalette.sepiaText,
          const Color(0xFFB87818),
          ReadingPalette.amberDividerSepia,
          const Color(0xFF7A6B5B),
        ),
      EditorialCardStyle.night => (
          ReadingPalette.charcoalSurface,
          ReadingPalette.charcoalPaper,
          ReadingPalette.amberLight,
          ReadingPalette.amberDividerDark,
          const Color(0xFF9E9484),
        ),
    };

    final fontSize = _computeFontSize(verseText.length);
    final lineHeight = _computeLineHeight(verseText.length);

    return Container(
      width: 320,
      constraints: const BoxConstraints(minHeight: 300),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Top decorative opening quote
          Text(
            '“',
            style: TextStyle(
              fontFamily: 'Lora',
              fontSize: 34,
              height: 0.8,
              fontWeight: FontWeight.bold,
              color: accentColor.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 8),

          // Biblical text in Lora
          Text(
            verseText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Lora',
              fontSize: fontSize,
              height: lineHeight,
              fontStyle: FontStyle.italic,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),

          // Subtle hairline divider
          Container(
            width: 42,
            height: 1.5,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 12),

          // Reference & Translation
          Text(
            reference,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Lora',
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
              color: textColor,
            ),
          ),
          if (translationLabel != null && translationLabel!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              translationLabel!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10.5,
                color: watermarkColor,
              ),
            ),
          ],

          // Optional discrete watermark
          if (showWatermark) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 11,
                  color: watermarkColor.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'bible_app · Un capítulo al día',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: watermarkColor.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
