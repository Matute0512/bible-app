import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/bible_chapter.dart';

import '../models/verse.dart';
import '../services/reading_plan_service.dart';
import '../theme/bible_theme.dart';
import '../widgets/graph_explorer.dart';
import '../widgets/verse_shimmer.dart';
import '../providers/app_providers.dart';

/// Main reading screen: shows the chapter of the day, its curated connection
/// graph and the settings sheet.
///
/// Text widgets scale with the system text scale factor automatically, so the
/// biblical text honors the user's accessibility preferences on top of the
/// manual font-size slider.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  /// Drives the subtle staggered fade-in of verses after a chapter arrives.
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  /// Best-effort runtime permission request; denial never blocks reading.
  Future<void> _requestNotificationPermission() async {
    try {
      final service = ref.read(notificationServiceProvider);
      await service.requestPermission();
    } on Exception {
      // Permission denial is non-fatal.
    }
  }

  // ---------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------

  Future<void> _openSettings() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => const _SettingsSheet(),
    );
  }

  /// Opens the connection graph centered on the current chapter.
  Future<void> _openGraphExplorer(
    BibleChapter chapter, {
    int? fromVerse,
  }) async {
    await showGraphExplorer(context, fromVerse: fromVerse);
  }

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(dailyReadingProvider);

    // Listen to changes to trigger entrance animation when a new chapter loads
    ref.listen<AsyncValue<DailyReadingState>>(dailyReadingProvider, (
      previous,
      next,
    ) {
      next.whenData((state) {
        if (state is Loaded) {
          final isNew =
              previous?.value is! Loaded ||
              (previous!.value as Loaded).currentIndex != state.currentIndex;
          if (isNew) {
            _entrance.forward(from: 0);
          }
        }
      });
    });

    final state = stateAsync.value;
    final isNavigating = state is Navigating;
    final isLoaded = state is Loaded;
    final chapter = isLoaded
        ? state.chapter
        : (isNavigating ? state.previousChapter : null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lectura de Hoy'),
        centerTitle: true,
        actions: [
          Semantics(
            label: 'Ver conexiones de este capítulo',
            button: true,
            excludeSemantics: true,
            child: IconButton(
              icon: const Icon(Icons.hub_outlined),
              tooltip: 'Ver conexiones de este capítulo',
              onPressed: chapter == null
                  ? null
                  : () => _openGraphExplorer(chapter),
            ),
          ),
          Semantics(
            label: 'Abrir configuración',
            button: true,
            excludeSemantics: true,
            child: IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Abrir configuración',
              onPressed: _openSettings,
            ),
          ),
        ],
      ),
      // The chapter navigation stays visible even while a new chapter loads.
      bottomNavigationBar: _buildChapterNav(state),
      body: _buildBody(stateAsync),
    );
  }

  Widget _buildBody(AsyncValue<DailyReadingState> stateAsync) {
    final state = stateAsync.value;
    final isNavigating = state is Navigating;

    final progressBar = isNavigating
        ? const LinearProgressIndicator(minHeight: 2)
        : const SizedBox.shrink();

    return Column(
      children: [
        progressBar,
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: KeyedSubtree(
              key: ValueKey<String>(_contentKey(state)),
              child: _buildCurrentContent(stateAsync),
            ),
          ),
        ),
      ],
    );
  }

  /// Stable identity for the animated switcher so chapter changes (and load →
  /// content) cross-fade instead of cutting over.
  String _contentKey(DailyReadingState? state) {
    if (state == null || state is LoadingPlan) {
      return 'loading';
    }
    if (state is DailyReadingError) {
      return 'error:${state.message}';
    }
    if (state is Loaded) {
      return state.chapter.reference;
    }
    if (state is Navigating) {
      return state.previousChapter.reference;
    }
    return 'loading';
  }

  Widget _buildCurrentContent(AsyncValue<DailyReadingState> stateAsync) {
    final state = stateAsync.value;

    if (stateAsync.hasError) {
      return _buildError(stateAsync.error.toString());
    }

    if (state is DailyReadingError) {
      return _buildError(state.message);
    }

    if (state == null || state is LoadingPlan) {
      return const VerseShimmerList();
    }

    final chapter = state is Loaded
        ? state.chapter
        : (state as Navigating).previousChapter;
    return _buildChapter(chapter);
  }

  Widget _buildError(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48, color: colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'No pudimos cargar el capítulo. Revisá tu conexión a internet',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => ref.invalidate(dailyReadingProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapter(BibleChapter chapter) {
    final reading = Theme.of(context).extension<BibleReadingStyle>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final hasConnections = ref
        .read(verseConnectionsProvider)
        .hasConnections(
          bookId: chapter.bookId,
          chapterNumber: chapter.chapterNumber,
        );
    final fontSizeMultiplier =
        ref.watch(userPreferencesProvider).value?.fontSizeMultiplier ?? 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ChapterHeader(
          chapter: chapter,
          dateLabel: _formatToday(),
          reading: reading,
          colorScheme: colorScheme,
          showTapHint: hasConnections,
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 6, 24, 40),
            itemCount: chapter.verses.length,
            itemBuilder: (context, index) => VerseListItem(
              verse: chapter.verses[index],
              index: index,
              verseCount: chapter.verses.length,
              entranceAnimation: _entrance,
              fontSizeMultiplier: fontSizeMultiplier,
              onTap: () => _openGraphExplorer(
                chapter,
                fromVerse: chapter.verses[index].number,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Chapter navigation (previous / next)
  // ---------------------------------------------------------------------

  Widget _buildChapterNav(DailyReadingState? state) {
    final isLoaded = state is Loaded;
    final isNavigating = state is Navigating;

    final List<ReadingPlanEntry>? plan = isLoaded
        ? state.plan
        : (isNavigating ? state.plan : null);
    final enabled = plan != null && isLoaded;
    final currentIndex = isLoaded
        ? state.currentIndex
        : (isNavigating ? state.targetIndex : null);

    final position = plan == null || currentIndex == null
        ? null
        : '${currentIndex + 1} de ${plan.length}';

    final container = Container(
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).extension<BibleReadingStyle>()!.navBarBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: _NavAction(
                icon: Icons.chevron_left,
                label: 'Anterior',
                alignment: MainAxisAlignment.start,
                enabled: enabled,
                onTap: () =>
                    ref.read(dailyReadingProvider.notifier).goToChapter(-1),
              ),
            ),
            if (position != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Capítulo',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      position,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Expanded(
              child: _NavAction(
                icon: Icons.chevron_right,
                label: 'Siguiente',
                alignment: MainAxisAlignment.end,
                enabled: enabled,
                onTap: () =>
                    ref.read(dailyReadingProvider.notifier).goToChapter(1),
              ),
            ),
          ],
        ),
      ),
    );

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: container,
    );
  }

  String _formatToday() {
    final formatted = DateFormat('EEEE d MMMM', 'es').format(DateTime.now());
    return formatted[0].toUpperCase() + formatted.substring(1);
  }
}

/// Pinned passage heading: large centered serif title, date and a soft amber
/// hairline, plus a subtle hint that verses are explorable when the chapter
/// has curated connections.
class _ChapterHeader extends StatelessWidget {
  const _ChapterHeader({
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

/// One half of the floating navigation bar (previous/next).
class _NavAction extends StatelessWidget {
  const _NavAction({
    required this.icon,
    required this.label,
    required this.alignment,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final MainAxisAlignment alignment;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = enabled
        ? colorScheme.primary
        : colorScheme.onSurface.withValues(alpha: 0.3);

    final action = Material(
      color: enabled
          ? colorScheme.primary.withValues(alpha: 0.08)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            mainAxisAlignment: alignment,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 26, color: foreground),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      label: 'Capítulo $label',
      enabled: enabled,
      excludeSemantics: true,
      child: action,
    );
  }
}

/// Modal bottom sheet with the font-size slider and the notification time.
class _SettingsSheet extends ConsumerStatefulWidget {
  const _SettingsSheet();

  @override
  ConsumerState<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends ConsumerState<_SettingsSheet> {
  late double _fontSize;

  @override
  void initState() {
    super.initState();
    _fontSize =
        ref.read(userPreferencesProvider).value?.fontSizeMultiplier ?? 1.0;
  }

  void _onFontSizeChanged(double value) {
    setState(() => _fontSize = value);
    ref.read(userPreferencesProvider.notifier).setFontSizeMultiplier(value);
  }

  Future<void> _pickTime() async {
    final initialTime =
        ref.read(userPreferencesProvider).value?.notificationTime ??
        const TimeOfDay(hour: 8, minute: 0);
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: 'Elegí la hora del recordatorio',
    );
    if (picked == null || !mounted) {
      return;
    }
    // Close the sheet first so the confirmation SnackBar is visible.
    Navigator.of(context).pop();
    await ref
        .read(userPreferencesProvider.notifier)
        .setNotificationTime(picked);

    final scheduled = await ref
        .read(dailyReadingProvider.notifier)
        .rescheduleNotification();
    if (!mounted) return;

    final colorScheme = Theme.of(context).colorScheme;
    final onLightPill = colorScheme.inverseSurface.computeLuminance() > 0.5;
    final checkColor = onLightPill
        ? const Color(0xFF2E7D32)
        : const Color(0xFF7CD38B);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                scheduled ? Icons.check_circle : Icons.error_outline,
                size: 22,
                color: scheduled ? checkColor : colorScheme.error,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  scheduled
                      ? 'Notificación diaria programada'
                      : 'No se pudo programar la notificación. Revisá los permisos',
                ),
              ),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final preferences = ref.watch(userPreferencesProvider).value;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        MediaQuery.paddingOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Configuración', style: theme.textTheme.titleLarge),
          const SizedBox(height: 24),

          Text('Tamaño del texto bíblico', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Row(
            children: [
              // Small / large “A” marks the ends of the scale, tinted with the
              // primary indigo to match the interactive slider.
              Semantics(
                label: 'Fuente más pequeña',
                child: ExcludeSemantics(
                  child: Text(
                    'A',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Slider(
                  value: _fontSize,
                  min: 0.8,
                  max: 1.5,
                  divisions: 14,
                  label: '${(_fontSize * 100).round()}%',
                  onChanged: _onFontSizeChanged,
                ),
              ),
              Semantics(
                label: 'Fuente más grande',
                child: ExcludeSemantics(
                  child: Text(
                    'A',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Text(
            '${(_fontSize * 100).round()}%',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ReadingPalette.amber.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.notifications_active,
                size: 22,
                color: ReadingPalette.amber,
              ),
            ),
            title: const Text('Recordatorio diario'),
            subtitle: Text(preferences?.notificationTime.format(context) ?? ''),
            trailing: FilledButton.tonal(
              onPressed: _pickTime,
              child: const Text('Cambiar'),
            ),
            onTap: _pickTime,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

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
    final reading = Theme.of(context).extension<BibleReadingStyle>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: entranceAnimation,
      builder: (context, _) {
        // Each verse occupies a slice of the animation timeline, so the ones
        // near the top fade in just before those further down the scroll.
        final span = 0.9;
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
