import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_providers.dart';
import '../theme/bible_theme.dart';
import '../widgets/graph_explorer.dart';

class StudyScreen extends ConsumerWidget {
  const StudyScreen({super.key});

  void _loadChapterAndOpen(
    WidgetRef ref,
    BuildContext context, {
    required String bookId,
    required String bookName,
    required int chapterNumber,
  }) {
    ref.read(dailyReadingProvider.notifier).loadFreeChapter(
          bookId,
          bookName,
          chapterNumber,
        );
    context.push('/reading');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final readingStyle = BibleReadingStyle.of(context);
    final progressAsync = ref.watch(readingProgressProvider);
    final progress = progressAsync.value;

    return Scaffold(
      backgroundColor: readingStyle.surfaceColor,
      appBar: AppBar(
        backgroundColor: readingStyle.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Estudio y Conexiones',
          style: theme.textTheme.titleMedium?.copyWith(
            fontFamily: 'Lora',
            fontWeight: FontWeight.bold,
            color: readingStyle.textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Buscar en la Biblia',
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // -----------------------------------------------------------------
          // 1. Curated Theological Graph Card
          // -----------------------------------------------------------------
          Container(
            decoration: BoxDecoration(
              color: readingStyle.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.hub_outlined,
                        color: theme.colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Grafo de Conexiones',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontFamily: 'Lora',
                              fontWeight: FontWeight.bold,
                              color: readingStyle.textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '6 categorías de relaciones teológicas',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'Inter',
                              color: readingStyle.metaColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Explorá cómo los pasajes bíblicos dialogan entre sí a través de profecías, cumplimientos, paralelismos, citas y temas compartidos.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Inter',
                    color: readingStyle.textColor,
                    height: 1.45,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Pasajes destacados con conexiones:',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    color: readingStyle.metaColor,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildPassageChip(
                      context,
                      ref,
                      bookId: 'GEN',
                      bookName: 'Génesis',
                      chapterNumber: 1,
                      label: 'Génesis 1 · Creación',
                    ),
                    _buildPassageChip(
                      context,
                      ref,
                      bookId: 'JHN',
                      bookName: 'Juan',
                      chapterNumber: 1,
                      label: 'Juan 1 · El Verbo',
                    ),
                    _buildPassageChip(
                      context,
                      ref,
                      bookId: 'PSA',
                      bookName: 'Salmos',
                      chapterNumber: 104,
                      label: 'Salmo 104 · Alabanza',
                    ),
                    _buildPassageChip(
                      context,
                      ref,
                      bookId: 'REV',
                      bookName: 'Apocalipsis',
                      chapterNumber: 21,
                      label: 'Apocalipsis 21 · Nueva Creación',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => showGraphExplorer(context),
                    icon: const Icon(Icons.explore_outlined, size: 18),
                    label: const Text(
                      'Explorar conexiones del día',
                      style: TextStyle(fontFamily: 'Inter'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // -----------------------------------------------------------------
          // 2. Personal Study Notebook Card
          // -----------------------------------------------------------------
          Container(
            decoration: BoxDecoration(
              color: readingStyle.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.collections_bookmark_outlined,
                        color: theme.colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Colección de Guardados',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontFamily: 'Lora',
                              fontWeight: FontWeight.bold,
                              color: readingStyle.textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Favoritos, resaltados y notas personales',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'Inter',
                              color: readingStyle.metaColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Accedé rápidamente a tus versículos destacados con los 4 colores editoriales, tus notas de estudio clasificadas por etiquetas y tus favoritos.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Inter',
                    color: readingStyle.textColor,
                    height: 1.45,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: () => context.push('/saved'),
                    icon: const Icon(Icons.bookmark_outline, size: 18),
                    label: const Text(
                      'Abrir cuaderno de guardados',
                      style: TextStyle(fontFamily: 'Inter'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // -----------------------------------------------------------------
          // 3. Progress and Study Habits Card
          // -----------------------------------------------------------------
          if (progress != null) ...[
            Container(
              decoration: BoxDecoration(
                color: readingStyle.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.insights_rounded,
                        color: theme.colorScheme.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Progreso de Estudio',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontFamily: 'Lora',
                          fontWeight: FontWeight.bold,
                          color: readingStyle.textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricColumn(
                        context,
                        value: '${progress.readChaptersCount}',
                        label: 'Capítulos leídos',
                      ),
                      Container(
                        height: 36,
                        width: 1,
                        color: theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.5),
                      ),
                      _buildMetricColumn(
                        context,
                        value: '${progress.currentStreakDays}',
                        label: 'Días de racha',
                      ),
                      Container(
                        height: 36,
                        width: 1,
                        color: theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.5),
                      ),
                      _buildMetricColumn(
                        context,
                        value: '${progress.progressPercentage.toStringAsFixed(1)}%',
                        label: 'Biblia leída',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPassageChip(
    BuildContext context,
    WidgetRef ref, {
    required String bookId,
    required String bookName,
    required int chapterNumber,
    required String label,
  }) {
    final theme = Theme.of(context);
    final readingStyle = BibleReadingStyle.of(context);

    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(fontFamily: 'Inter', fontSize: 12),
      ),
      backgroundColor: readingStyle.cardBackground,
      side: BorderSide(
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onPressed: () => _loadChapterAndOpen(
        ref,
        context,
        bookId: bookId,
        bookName: bookName,
        chapterNumber: chapterNumber,
      ),
    );
  }

  Widget _buildMetricColumn(
    BuildContext context, {
    required String value,
    required String label,
  }) {
    final theme = Theme.of(context);
    final readingStyle = BibleReadingStyle.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontFamily: 'Lora',
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'Inter',
            fontSize: 11,
            color: readingStyle.metaColor,
          ),
        ),
      ],
    );
  }
}
