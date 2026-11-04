import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';



import '../models/reading_progress.dart';

import '../providers/app_providers.dart';
import '../providers/thematic_plans_provider.dart';
import '../theme/bible_theme.dart';

import 'reading_screen.dart'; // for SettingsSheet



class DashboardScreen extends ConsumerWidget {

  const DashboardScreen({super.key});



  @override

  Widget build(BuildContext context, WidgetRef ref) {

    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;



    final readingState = ref.watch(dailyReadingProvider).value;

    final todayRef = switch (readingState) {

      Loaded s => s.plan[s.currentIndex].reference,

      _ => null,

    };



    final progressAsync = ref.watch(readingProgressProvider);

    final progress = progressAsync.value;
    final activeThematicPlan = ref.watch(activeThematicPlanProvider);



    return Scaffold(

      appBar: AppBar(

        title: const Text('Inicio'),

        actions: [

          IconButton(

            icon: const Icon(Icons.search),

            onPressed: () => context.push('/search'),

            tooltip: 'Buscar en la Biblia',

          ),

          IconButton(

            icon: const Icon(Icons.collections_bookmark_outlined),

            onPressed: () => context.push('/saved'),

            tooltip: 'Guardados y notas',

          ),

          IconButton(

            icon: const Icon(Icons.settings_outlined),

            onPressed: () => _openSettings(context),

            tooltip: 'Configuración',

          ),

        ],

      ),

      body: SafeArea(

        child: ListView(

          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),

          children: [

            // ---------------------------------------------------------------

            // Metric Cards: Streak & Real Progress

            // ---------------------------------------------------------------

            _buildMetricsSection(context, progress),

            const SizedBox(height: 24),



            // ---------------------------------------------------------------

            // Section: Daily Reading Plan

            // ---------------------------------------------------------------

            Text(

              'Tu lectura de hoy',

              style: theme.textTheme.titleMedium?.copyWith(

                color: colorScheme.primary,

                fontWeight: FontWeight.bold,

              ),

            ),

            const SizedBox(height: 12),

            Card(

              elevation: 0,

              color: colorScheme.surfaceContainerHighest,

              shape: RoundedRectangleBorder(

                borderRadius: BorderRadius.circular(20),

              ),

              child: Padding(

                padding: const EdgeInsets.all(24),

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Row(

                      children: [

                        Icon(Icons.menu_book, color: colorScheme.primary),

                        const SizedBox(width: 8),

                        Text(

                          'Capítulo del día',

                          style: theme.textTheme.titleMedium?.copyWith(

                            fontWeight: FontWeight.w600,

                          ),

                        ),

                      ],

                    ),

                    const SizedBox(height: 12),

                    if (todayRef != null)

                      Text(

                        todayRef,

                        style: theme.textTheme.headlineSmall?.copyWith(

                          color: colorScheme.primary,

                          fontWeight: FontWeight.bold,

                        ),

                      ),

                    const SizedBox(height: 6),

                    Text(

                      todayRef != null

                          ? 'Un capítulo al día, todos los días.'

                          : 'Cargando tu lectura de hoy...',

                      style: theme.textTheme.bodyMedium?.copyWith(

                        color: colorScheme.onSurfaceVariant,

                      ),

                    ),

                    const SizedBox(height: 20),

                    SizedBox(

                      width: double.infinity,

                      child: FilledButton(

                        onPressed: () => context.push('/reading'),

                        child: const Text('Leer capítulo de hoy'),

                      ),

                    ),

                  ],

                ),

              ),

            ),



            // ---------------------------------------------------------------

            // ---------------------------------------------------------------
            // Active Thematic Reading Plan (Feature E)
            // ---------------------------------------------------------------
            if (activeThematicPlan != null) ...[
              const SizedBox(height: 20),
              _buildActiveThematicPlanCard(context, ref, activeThematicPlan),
            ],

            // Optional Card: Resume Last Read (if available)

            // ---------------------------------------------------------------

            if (progress?.lastRead != null) ...[

              const SizedBox(height: 20),

              _buildLastReadCard(context, ref, progress!.lastRead!),

            ],



            const SizedBox(height: 24),

            Text(

              'Explorar las Escrituras',

              style: theme.textTheme.titleMedium?.copyWith(

                color: colorScheme.primary,

                fontWeight: FontWeight.bold,

              ),

            ),

            const SizedBox(height: 12),

            // Free exploration card

            Card(

              elevation: 0,

              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),

              shape: RoundedRectangleBorder(

                borderRadius: BorderRadius.circular(20),

              ),

              child: InkWell(

                onTap: () => context.push('/explore'),

                borderRadius: BorderRadius.circular(20),

                child: Padding(

                  padding: const EdgeInsets.all(20),

                  child: Row(

                    children: [

                      Container(

                        padding: const EdgeInsets.all(12),

                        decoration: BoxDecoration(

                          color: colorScheme.primary.withValues(alpha: 0.1),

                          shape: BoxShape.circle,

                        ),

                        child: Icon(Icons.search, color: colorScheme.primary),

                      ),

                      const SizedBox(width: 16),

                      Expanded(

                        child: Column(

                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [

                            Text(

                              'Búsqueda libre',

                              style: theme.textTheme.titleMedium?.copyWith(

                                fontWeight: FontWeight.w600,

                              ),

                            ),

                            const SizedBox(height: 4),

                            Text(

                              'Lee cualquier libro o capítulo de la Biblia',

                              style: theme.textTheme.bodySmall?.copyWith(

                                color: colorScheme.onSurfaceVariant,

                              ),

                            ),

                          ],

                        ),

                      ),

                      Icon(

                        Icons.chevron_right,

                        color: colorScheme.onSurfaceVariant,

                      ),

                    ],

                  ),

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }



  Widget _buildMetricsSection(BuildContext context, ReadingProgress? progress) {

    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;



    final streak = progress?.currentStreakDays ?? 0;

    final readCount = progress?.readChaptersCount ?? 0;

    final totalChapters = progress?.totalCanonChapters ?? 1189;

    final percentage = progress?.formattedPercentage ?? '0.0%';

    final fraction = progress?.progressFraction ?? 0.0;



    return Container(

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(

        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),

        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),

        borderRadius: BorderRadius.circular(20),

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(

            children: [

              // Streak Pill / Metric

              Expanded(

                child: Container(

                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

                  decoration: BoxDecoration(

                    color: colorScheme.surface,

                    borderRadius: BorderRadius.circular(14),

                    border: Border.all(

                      color: colorScheme.outlineVariant.withValues(alpha: 0.4),

                    ),

                  ),

                  child: Row(

                    children: [

                      Text(

                        streak > 0 ? '🔥' : '✨',

                        style: const TextStyle(fontSize: 22),

                      ),

                      const SizedBox(width: 10),

                      Expanded(

                        child: Column(

                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [

                            Text(

                              '$streak ${streak == 1 ? "día" : "días"}',

                              style: theme.textTheme.titleMedium?.copyWith(

                                fontWeight: FontWeight.bold,

                                color: colorScheme.primary,

                              ),

                            ),

                            Text(

                              'Racha de lectura',

                              style: theme.textTheme.labelSmall?.copyWith(

                                color: colorScheme.onSurfaceVariant,

                              ),

                            ),

                          ],

                        ),

                      ),

                    ],

                  ),

                ),

              ),

              const SizedBox(width: 12),

              // Percentage Metric

              Expanded(

                child: Container(

                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

                  decoration: BoxDecoration(

                    color: colorScheme.surface,

                    borderRadius: BorderRadius.circular(14),

                    border: Border.all(

                      color: colorScheme.outlineVariant.withValues(alpha: 0.4),

                    ),

                  ),

                  child: Row(

                    children: [

                      Icon(

                        Icons.auto_stories_outlined,

                        size: 22,

                        color: colorScheme.primary,

                      ),

                      const SizedBox(width: 10),

                      Expanded(

                        child: Column(

                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [

                            Text(

                              percentage,

                              style: theme.textTheme.titleMedium?.copyWith(

                                fontWeight: FontWeight.bold,

                                color: colorScheme.primary,

                              ),

                            ),

                            Text(

                              'Biblia leída',

                              style: theme.textTheme.labelSmall?.copyWith(

                                color: colorScheme.onSurfaceVariant,

                              ),

                            ),

                          ],

                        ),

                      ),

                    ],

                  ),

                ),

              ),

            ],

          ),

          const SizedBox(height: 16),

          // Progress bar

          ClipRRect(

            borderRadius: BorderRadius.circular(6),

            child: LinearProgressIndicator(

              value: fraction,

              minHeight: 8,

              backgroundColor: colorScheme.surfaceContainerHighest,

              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),

            ),

          ),

          const SizedBox(height: 8),

          Row(

            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [

              Text(

                'Progreso verificado',

                style: theme.textTheme.labelSmall?.copyWith(

                  color: colorScheme.onSurfaceVariant,

                ),

              ),

              Text(

                '$readCount de $totalChapters capítulos',

                style: theme.textTheme.labelSmall?.copyWith(

                  fontWeight: FontWeight.w600,

                  color: colorScheme.onSurface,

                ),

              ),

            ],

          ),

        ],

      ),

    );

  }



  Widget _buildLastReadCard(

    BuildContext context,

    WidgetRef ref,

    LastReadTarget lastRead,

  ) {

    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;



    return Card(

      elevation: 0,

      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),

      shape: RoundedRectangleBorder(

        borderRadius: BorderRadius.circular(16),

        side: BorderSide(

          color: colorScheme.outlineVariant.withValues(alpha: 0.4),

        ),

      ),

      child: ListTile(

        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

        leading: Container(

          padding: const EdgeInsets.all(8),

          decoration: BoxDecoration(

            color: colorScheme.secondary.withValues(alpha: 0.12),

            shape: BoxShape.circle,

          ),

          child: Icon(

            Icons.history_rounded,

            color: colorScheme.secondary,

            size: 20,

          ),

        ),

        title: Text(

          'Continuar donde lo dejaste',

          style: theme.textTheme.labelMedium?.copyWith(

            color: colorScheme.onSurfaceVariant,

          ),

        ),

        subtitle: Text(

          '${lastRead.bookId} capítulo ${lastRead.chapterNumber}',

          style: theme.textTheme.titleSmall?.copyWith(

            fontWeight: FontWeight.w600,

          ),

        ),

        trailing: OutlinedButton(

          style: OutlinedButton.styleFrom(

            visualDensity: VisualDensity.compact,

            padding: const EdgeInsets.symmetric(horizontal: 12),

          ),

          onPressed: () {

            ref

                .read(dailyReadingProvider.notifier)

                .loadFreeChapter(

                  lastRead.bookId,

                  lastRead.bookId,

                  lastRead.chapterNumber,

                );

            context.push('/reading');

          },

          child: const Text('Reanudar'),

        ),

      ),

    );

  }



  Future<void> _openSettings(BuildContext context) {

    return showModalBottomSheet<void>(

      context: context,

      isScrollControlled: true,

      builder: (_) => const SettingsSheet(),

    );

  }


  Widget _buildActiveThematicPlanCard(
    BuildContext context,
    WidgetRef ref,
    ActiveThematicPlan activePlan,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final plan = activePlan.plan;
    final progress = activePlan.progress;
    final totalDays = plan.durationDays;
    final nextDay = activePlan.currentOrNextDay;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: ReadingPalette.amber.withValues(alpha: 0.5),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: ReadingPalette.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'PLAN TEMATICO EN CURSO',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 0.6,
                      color: ReadingPalette.amber,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${progress.completedCount}/$totalDays dias',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontFamily: 'Inter',
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              plan.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: 'Lora',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              nextDay != null
                  ? 'Dia ${nextDay.dayNumber} · ${nextDay.reference}'
                  : plan.subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'Inter',
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.fraction(totalDays),
                minHeight: 5,
                backgroundColor: colorScheme.outlineVariant.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation(ReadingPalette.amber),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (nextDay != null)
                  FilledButton.tonal(
                    onPressed: () {
                      ref.read(dailyReadingProvider.notifier).loadFreeChapter(
                            nextDay.bookId,
                            nextDay.bookName,
                            nextDay.chapter,
                          );
                      context.push('/reading');
                    },
                    child: const Text('Continuar plan'),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/plans'),
                  child: const Text('Ver planes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
