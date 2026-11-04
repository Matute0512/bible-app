import 'package:flutter/material.dart';

import '../../models/verse.dart';
import '../../models/verse_annotation.dart';
import '../../theme/bible_theme.dart';

/// Renders a single verse in the reading list with editorial typography,
/// an amber verse numeral, optional highlight background, favorite/note badges,
/// and staggered entrance animation.
class VerseListItem extends StatelessWidget {
  const VerseListItem({
    super.key,
    required this.verse,
    required this.index,
    required this.verseCount,
    required this.entranceAnimation,
    required this.fontSizeMultiplier,
    this.annotation,
    required this.onTap,
  });

  final Verse verse;
  final int index;
  final int verseCount;
  final Animation<double> entranceAnimation;
  final double fontSizeMultiplier;
  final VerseAnnotation? annotation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reading = Theme.of(context).extension<BibleReadingStyle>() ??
        BibleReadingStyle.light;
    final colorScheme = Theme.of(context).colorScheme;

    final highlightBg = reading.highlightColorFor(annotation?.highlightColor);
    final isFavorite = annotation?.isFavorite ?? false;
    final hasNote = annotation?.hasNote ?? false;

    return AnimatedBuilder(
      animation: entranceAnimation,
      builder: (context, _) {
        const span = 0.9;
        final slice = verseCount > 0 ? span / verseCount : 1.0;
        final start = index * slice;
        final local = ((entranceAnimation.value - start) / slice)
            .clamp(0.0, 1.0)
            .toDouble();
        final dy = (1 - local) * 10.0;

        return Opacity(
          opacity: local,
          child: Transform.translate(
            offset: Offset(0, dy),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Semantics(
                button: true,
                label:
                    'Versículo ${verse.number}. ${isFavorite ? "En favoritos. " : ""}${highlightBg != null ? "Resaltado. " : ""}${hasNote ? "Con nota. " : ""}Tocar para opciones',
                excludeSemantics: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTap,
                  child: Container(
                    padding: highlightBg != null
                        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 6)
                        : const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: highlightBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Numeral with optional indicators for favorite and note
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.translate(
                              offset: const Offset(0, -2),
                              child: Text(
                                '${verse.number}',
                                style: reading.verseNumber,
                              ),
                            ),
                            if (isFavorite) ...[
                              const SizedBox(height: 2),
                              Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: ReadingPalette.amber,
                              ),
                            ],
                            if (hasNote) ...[
                              const SizedBox(height: 2),
                              Icon(
                                Icons.note_alt_rounded,
                                size: 12,
                                color: colorScheme.secondary,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            verse.text,
                            style: reading
                                .readingText(fontSizeMultiplier)
                                .copyWith(color: colorScheme.onSurface),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
