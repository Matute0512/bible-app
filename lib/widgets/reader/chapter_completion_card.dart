import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/bible_chapter.dart';
import '../../providers/app_providers.dart';

/// Card displayed at the end of a chapter allowing the user to mark it as read,
/// tracking real reading progress and daily streaks.
class ChapterCompletionCard extends ConsumerWidget {
  const ChapterCompletionCard({
    super.key,
    required this.chapter,
    required this.translationId,
    this.source = 'daily_plan',
  });

  final BibleChapter chapter;
  final String translationId;
  final String source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isReadAsync = ref.watch(
      isChapterReadProvider(
        (bookId: chapter.bookId, chapterNumber: chapter.chapterNumber),
      ),
    );
    final isRead = isReadAsync.value ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isRead
            ? colorScheme.secondaryContainer.withValues(alpha: 0.25)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        border: Border.all(
          color: isRead
              ? colorScheme.secondary.withValues(alpha: 0.4)
              : colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isRead
                      ? colorScheme.secondary.withValues(alpha: 0.15)
                      : colorScheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isRead
                      ? Icons.check_circle_rounded
                      : Icons.menu_book_outlined,
                  color: isRead ? colorScheme.secondary : colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRead ? 'Capítulo completado' : '¿Terminaste de leer?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isRead
                          ? '${chapter.reference} registrado en tu progreso'
                          : 'Registra tu avance y mantén tu racha diaria',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isRead) ...[
                TextButton(
                  onPressed: () async {
                    await ref
                        .read(readingHistoryRepositoryProvider)
                        .unmarkChapterAsRead(
                          bookId: chapter.bookId,
                          chapterNumber: chapter.chapterNumber,
                          translationId: translationId,
                        );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${chapter.reference} desmarcado',
                            
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Desmarcar',
                    style: TextStyle(color: colorScheme.outline),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: null, // Visual confirmation state
                  icon: const Icon(Icons.done_all_rounded, size: 18),
                  label: const Text('Leído'),
                ),
              ] else ...[
                FilledButton.icon(
                  onPressed: () async {
                    await ref
                        .read(readingHistoryRepositoryProvider)
                        .markChapterAsRead(
                          bookId: chapter.bookId,
                          chapterNumber: chapter.chapterNumber,
                          translationId: translationId,
                          source: source,
                        );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('¡${chapter.reference} marcado como leído!'),
                          action: SnackBarAction(
                            label: 'Deshacer',
                            onPressed: () {
                              ref
                                  .read(readingHistoryRepositoryProvider)
                                  .unmarkChapterAsRead(
                                    bookId: chapter.bookId,
                                    chapterNumber: chapter.chapterNumber,
                                    translationId: translationId,
                                  );
                            },
                          ),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Marcar como leído'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
