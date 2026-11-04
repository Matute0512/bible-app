import 'package:flutter/material.dart';

import '../../models/verse.dart';
import '../../theme/bible_theme.dart';

/// Renders a single verse in the reading list with editorial typography,
/// an amber verse numeral, and staggered entrance animation.
class VerseListItem extends StatelessWidget {
  const VerseListItem({
    super.key,
    required this.verse,
    required this.index,
    required this.verseCount,
    required this.entranceAnimation,
    required this.fontSizeMultiplier,
    required this.onTap,
  });

  final Verse verse;
  final int index;
  final int verseCount;
  final Animation<double> entranceAnimation;
  final double fontSizeMultiplier;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reading = Theme.of(context).extension<BibleReadingStyle>() ??
        BibleReadingStyle.light;
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: entranceAnimation,
      builder: (context, _) {
        // Each verse occupies a slice of the animation timeline, so the ones
        // near the top fade in just before those further down the scroll.
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
              padding: const EdgeInsets.only(bottom: 18),
              child: Semantics(
                button: true,
                label: 'Versículo ${verse.number}. Ver conexiones',
                hint: 'Abre las referencias relacionadas de este pasaje',
                excludeSemantics: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTap,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Slight upward offset gives the numeral a printed
                      // "superscript anchor" feel next to the verse text.
                      Transform.translate(
                        offset: const Offset(0, -3),
                        child: Text(
                          '${verse.number}',
                          style: reading.verseNumber,
                        ),
                      ),
                      const SizedBox(width: 14),
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
        );
      },
    );
  }
}
