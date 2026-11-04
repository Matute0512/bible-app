import 'package:flutter/material.dart';

import '../../models/bible_chapter.dart';
import '../../theme/bible_theme.dart';

/// Passage header showing the chapter reference (e.g. "Génesis 1"), date or mode,
/// decorative divider, and a subtle prompt to tap verses when connections exist.
class ChapterHeader extends StatelessWidget {
  const ChapterHeader({
    super.key,
    required this.chapter,
    required this.dateLabel,
    required this.reading,
    required this.colorScheme,
    required this.showTapHint,
  });

  final BibleChapter chapter;
  final String dateLabel;
  final BibleReadingStyle reading;
  final ColorScheme colorScheme;
  final bool showTapHint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
      child: Semantics(
        label:
            'Pasaje bíblico: ${chapter.bookName} capítulo ${chapter.chapterNumber}',
        excludeSemantics: true,
        child: Column(
          children: [
            Text(
              chapter.reference,
              textAlign: TextAlign.center,
              style: reading.chapterTitle,
            ),
            const SizedBox(height: 2),
            Text(
              dateLabel,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 64,
              height: 2,
              decoration: BoxDecoration(
                color: reading.headingDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (showTapHint) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app_outlined,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tocá un versículo para ver sus conexiones',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
