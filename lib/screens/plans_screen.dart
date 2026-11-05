import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/reading_plan_definition.dart';
import '../providers/app_providers.dart';
import '../providers/thematic_plans_provider.dart';
import '../theme/bible_theme.dart';

/// Screen displaying the curated thematic reading plans catalog, active plan
/// tracking, and day-by-day checklist.
class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final readingStyle = BibleReadingStyle.of(context);

    final plansAsync = ref.watch(thematicPlansDefinitionsProvider);
    final progressAsync = ref.watch(thematicPlansProgressProvider);
    final activePlan = ref.watch(activeThematicPlanProvider);

    return Scaffold(
      backgroundColor: readingStyle.surfaceColor,
      appBar: AppBar(
        backgroundColor: readingStyle.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Planes de Lectura',
          style: theme.textTheme.titleMedium?.copyWith(
            fontFamily: 'Lora',
            fontWeight: FontWeight.bold,
            color: readingStyle.textColor,
          ),
        ),
      ),
      body: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Error al cargar planes: $err',
              style: TextStyle(color: readingStyle.textColor),
            ),
          ),
        ),
        data: (plans) {
          final progressMap = progressAsync.value ?? {};

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // -------------------------------------------------------------
              // 1. Editorial Header
              // -------------------------------------------------------------
              Text(
                'Recorridos Temáticos',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontFamily: 'Lora',
                  fontWeight: FontWeight.bold,
                  color: readingStyle.textColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Planes curados de 14, 21 y 30 días para meditar en pasajes seleccionados con progreso independiente.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Inter',
                  color: readingStyle.metaColor,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),

              // -------------------------------------------------------------
              // 2. Active Plan Spotlight (if any)
              // -------------------------------------------------------------
              if (activePlan != null) ...[
                _buildActivePlanCard(context, ref, activePlan),
                const SizedBox(height: 24),
              ],

              // -------------------------------------------------------------
              // 3. Catalog of Curated Plans
              // -------------------------------------------------------------
              Text(
                'Catálogo de Planes',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFamily: 'Lora',
                  fontWeight: FontWeight.bold,
                  color: readingStyle.textColor,
                ),
              ),
              const SizedBox(height: 12),
              ...plans.map((plan) {
                final prog = progressMap[plan.id];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _PlanCatalogCard(
                    plan: plan,
                    progress: prog,
                    onTap: () => _openPlanDetailModal(context, plan),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActivePlanCard(
    BuildContext context,
    WidgetRef ref,
    ActiveThematicPlan activePlan,
  ) {
    final theme = Theme.of(context);
    final readingStyle = BibleReadingStyle.of(context);
    final plan = activePlan.plan;
    final progress = activePlan.progress;
    final nextDay = activePlan.currentOrNextDay;

    final completedCount = progress.completedCount;
    final totalDays = plan.durationDays;
    final percent = progress.percentage(totalDays).toStringAsFixed(0);
    final fraction = progress.fraction(totalDays);

    return Container(
      decoration: BoxDecoration(
        color: readingStyle.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ReadingPalette.amber.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ReadingPalette.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'PLAN ACTIVO',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: ReadingPalette.amber,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '$completedCount de $totalDays días ($percent%)',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: readingStyle.metaColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            plan.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: 'Lora',
              fontWeight: FontWeight.bold,
              color: readingStyle.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            plan.subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'Inter',
              color: readingStyle.metaColor,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              backgroundColor:
                  theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation(ReadingPalette.amber),
            ),
          ),
          const SizedBox(height: 16),
          if (nextDay != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: readingStyle.surfaceColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Siguiente lectura: Día ${nextDay.dayNumber}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            color: ReadingPalette.amber,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${nextDay.reference} · ${nextDay.title}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Lora',
                            fontWeight: FontWeight.w600,
                            color: readingStyle.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      ref.read(dailyReadingProvider.notifier).loadFreeChapter(
                            nextDay.bookId,
                            nextDay.bookName,
                            nextDay.chapter,
                          );
                      context.push('/reading');
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Leer hoy'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _openPlanDetailModal(context, plan),
                child: const Text('Ver todos los días'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openPlanDetailModal(
    BuildContext context,
    ReadingPlanDefinition plan,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PlanDetailSheet(plan: plan),
    );
  }
}

/// Catalog card for a single thematic plan.
class _PlanCatalogCard extends StatelessWidget {
  final ReadingPlanDefinition plan;
  final ThematicPlanProgress? progress;
  final VoidCallback onTap;

  const _PlanCatalogCard({
    required this.plan,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final readingStyle = BibleReadingStyle.of(context);

    final completed = progress?.completedCount ?? 0;
    final total = plan.durationDays;
    final isActive = progress?.isActive ?? false;
    final isDone = progress?.isCompleted ?? false;
    final fraction = progress?.fraction(total) ?? 0.0;

    return Container(
      decoration: BoxDecoration(
        color: readingStyle.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? ReadingPalette.amber.withValues(alpha: 0.5)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: isActive ? 1.5 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getCategoryIcon(plan.category),
                        color: theme.colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${plan.durationDays} DÍAS',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10.5,
                                    letterSpacing: 0.5,
                                    color: readingStyle.metaColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '·  ${plan.category}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontFamily: 'Inter',
                                  color: readingStyle.metaColor,
                                ),
                              ),
                              const Spacer(),
                              if (isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ReadingPalette.amber
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'ACTIVO',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      color: ReadingPalette.amber,
                                    ),
                                  ),
                                )
                              else if (isDone)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'COMPLETADO',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            plan.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontFamily: 'Lora',
                              fontWeight: FontWeight.bold,
                              color: readingStyle.textColor,
                              fontSize: 15.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  plan.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'Inter',
                    color: readingStyle.textColor.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
                if (completed > 0) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: fraction,
                            minHeight: 4,
                            backgroundColor: theme.colorScheme.outlineVariant
                                .withValues(alpha: 0.3),
                            valueColor: AlwaysStoppedAnimation(
                              isDone ? Colors.green : ReadingPalette.amber,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$completed / $total días',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontFamily: 'Inter',
                          color: readingStyle.metaColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Oración y Alabanza':
        return Icons.auto_stories;
      case 'Evangelio':
        return Icons.menu_book;
      case 'Sabiduría':
        return Icons.lightbulb_outline;
      case 'Fortaleza':
        return Icons.shield_outlined;
      default:
        return Icons.bookmark_border;
    }
  }
}

/// Bottom sheet displaying the complete day-by-day checklist for a plan.
class _PlanDetailSheet extends ConsumerWidget {
  final ReadingPlanDefinition plan;

  const _PlanDetailSheet({required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final readingStyle = BibleReadingStyle.of(context);
    final progressAsync = ref.watch(thematicPlansProgressProvider);
    final progress = progressAsync.value?[plan.id];
    final controller = ref.read(thematicPlansControllerProvider);

    final completedDays = progress?.completedDays ?? <int>{};
    final isActive = progress?.isActive ?? false;
    final isDone = progress?.isCompleted ?? false;
    final totalDays = plan.durationDays;
    final percent =
        ((completedDays.length / totalDays) * 100).toStringAsFixed(0);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: readingStyle.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: 'Lora',
                          fontWeight: FontWeight.bold,
                          color: readingStyle.textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${completedDays.length} de $totalDays días completados ($percent%)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'Inter',
                          color: readingStyle.metaColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Action Toolbar (Activar, Pausar, Reiniciar)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                if (!isActive)
                  FilledButton.icon(
                    onPressed: () async {
                      await controller.activatePlan(plan.id);
                    },
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: Text(
                      isDone ? 'Reiniciar y activar' : 'Activar como principal',
                      style: const TextStyle(fontFamily: 'Inter'),
                    ),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () async {
                      await controller.pausePlan(plan.id);
                    },
                    icon: const Icon(Icons.pause, size: 18),
                    label: const Text(
                      'Pausar plan',
                      style: TextStyle(fontFamily: 'Inter'),
                    ),
                  ),
                const Spacer(),
                if (completedDays.isNotEmpty)
                  TextButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (dCtx) => AlertDialog(
                          title: const Text('¿Reiniciar progreso?'),
                          content: Text(
                            'Se borrará el historial de días leídos del plan «${plan.title}». Esta acción no se puede deshacer.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dCtx).pop(false),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(dCtx).pop(true),
                              child: const Text('Reiniciar'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await controller.resetPlan(plan.id);
                      }
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Reiniciar'),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Days List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: plan.days.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (ctx, index) {
                final day = plan.days[index];
                final isDayDone = completedDays.contains(day.dayNumber);

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  leading: Checkbox(
                    value: isDayDone,
                    activeColor: ReadingPalette.amber,
                    onChanged: (val) async {
                      if (val == true) {
                        await controller.markDayCompleted(
                          plan.id,
                          day.dayNumber,
                          totalDays: totalDays,
                        );
                      } else {
                        await controller.unmarkDayCompleted(
                          plan.id,
                          day.dayNumber,
                        );
                      }
                    },
                  ),
                  title: Text(
                    'Día ${day.dayNumber} · ${day.reference}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Lora',
                      fontWeight: FontWeight.bold,
                      decoration:
                          isDayDone ? TextDecoration.lineThrough : null,
                      color: isDayDone
                          ? readingStyle.metaColor
                          : readingStyle.textColor,
                    ),
                  ),
                  subtitle: Text(
                    day.theme.isNotEmpty ? day.theme : day.title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'Inter',
                      color: readingStyle.metaColor,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.chrome_reader_mode_outlined),
                    tooltip: 'Leer capítulo',
                    onPressed: () {
                      Navigator.of(context).pop();
                      ref.read(dailyReadingProvider.notifier).loadFreeChapter(
                            day.bookId,
                            day.bookName,
                            day.chapter,
                          );
                      context.push('/reading');
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
