import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/bible_chapter.dart';
import '../models/verse.dart';
import '../providers/app_providers.dart';
import '../services/reading_plan_service.dart';
import '../theme/bible_theme.dart';
import '../widgets/graph_explorer.dart';
import '../models/verse_annotation.dart';
import '../widgets/reader/chapter_completion_card.dart';
import '../widgets/reader/verse_action_sheet.dart';
import '../widgets/reader/chapter_header.dart';
import '../widgets/reader/settings_sheet.dart';
import '../widgets/reader/verse_list_item.dart';
import '../widgets/verse_shimmer.dart';

export '../widgets/reader/chapter_completion_card.dart';
export '../widgets/reader/verse_action_sheet.dart';
export '../widgets/reader/chapter_header.dart';
export '../widgets/reader/settings_sheet.dart';
export '../widgets/reader/verse_list_item.dart';

/// Main reading screen: shows the chapter of the day, its curated connection
/// graph and the settings sheet.
///
/// Text widgets scale with the system text scale factor automatically, so the
/// biblical text honors the user's accessibility preferences on top of the
/// manual font-size slider.
class ReadingScreen extends ConsumerStatefulWidget {
  const ReadingScreen({super.key});

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen>
    with SingleTickerProviderStateMixin {
  /// Drives the subtle staggered fade-in of verses after a chapter arrives.
  late final AnimationController _entrance;

  /// 1 = slide from right (Next), -1 = slide from left (Previous)
  int _slideDirection = 1;

  /// Controls immersive reading mode (auto-hides bars on scroll down).
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      value: 1.0,
    );
    _requestNotificationPermissionIfEnabled();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  /// Requests notification permission only when the user has notifications enabled.
  Future<void> _requestNotificationPermissionIfEnabled() async {
    final prefs = ref.read(userPreferencesProvider).value;
    if (prefs?.notificationsEnabled != true) {
      return;
    }
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

  void _goToNext() {
    setState(() => _slideDirection = 1);
    ref.read(dailyReadingProvider.notifier).goToChapter(1);
  }

  void _goToPrevious() {
    setState(() => _slideDirection = -1);
    ref.read(dailyReadingProvider.notifier).goToChapter(-1);
  }

  Future<void> _openSettings() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => const SettingsSheet(),
    );
  }

  /// Opens the contextual action sheet for highlighting, favorites, and notes.
  Future<void> _openVerseActions(
    BibleChapter chapter,
    Verse verse,
    VerseAnnotation? annotation,
  ) {
    final translationId =
        ref.read(userPreferencesProvider).value?.translationId ?? 'spa_rvg';
    return VerseActionSheet.show(
      context: context,
      chapter: chapter,
      verse: verse,
      translationId: translationId,
      annotation: annotation,
      onOpenGraph: () => _openGraphExplorer(chapter, fromVerse: verse.number),
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
    final chapter = switch (state) {
      Loaded s => s.chapter,
      FreeReadingLoaded s => s.chapter,
      Navigating s => s.previousChapter,
      _ => null,
    };

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          offset: _showControls ? Offset.zero : const Offset(0, -1),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _showControls ? 1.0 : 0.0,
            child: AppBar(
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
          ),
        ),
      ),
      // The chapter navigation stays visible even while a new chapter loads.
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        offset: _showControls ? Offset.zero : const Offset(0, 1.3),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _showControls ? 1.0 : 0.0,
          child: _buildChapterNav(state),
        ),
      ),
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
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity < -300) {
                // Swipe left = Next
                _goToNext();
              } else if (velocity > 300) {
                // Swipe right = Previous
                _goToPrevious();
              }
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final isEntering =
                    child.key == ValueKey<String>(_contentKey(state));
                final offset = isEntering
                    ? _slideDirection.toDouble()
                    : -_slideDirection.toDouble();
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(offset, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
              child: KeyedSubtree(
                key: ValueKey<String>(_contentKey(state)),
                child: _buildCurrentContent(stateAsync),
              ),
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
    if (state is FreeReadingLoaded) {
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

    BibleChapter chapter;
    if (state is Loaded) {
      chapter = state.chapter;
    } else if (state is FreeReadingLoaded) {
      chapter = state.chapter;
    } else if (state is Navigating) {
      chapter = state.previousChapter;
    } else {
      return const VerseShimmerList();
    }

    return _buildChapter(chapter, state);
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

  Widget _buildChapter(BibleChapter chapter, DailyReadingState state) {
    final reading = Theme.of(context).extension<BibleReadingStyle>() ??
        BibleReadingStyle.light;
    final colorScheme = Theme.of(context).colorScheme;
    final hasConnections = ref
        .read(verseConnectionsProvider)
        .hasConnections(
          bookId: chapter.bookId,
          chapterNumber: chapter.chapterNumber,
        );
    final fontSizeMultiplier =
        ref.watch(userPreferencesProvider).value?.fontSizeMultiplier ?? 1.0;

    final annotationsAsync = ref.watch(
      chapterAnnotationsProvider((
        bookId: chapter.bookId,
        chapterNumber: chapter.chapterNumber,
      )),
    );
    final annotations = annotationsAsync.asData?.value ?? const <int, VerseAnnotation>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChapterHeader(
          chapter: chapter,
          dateLabel: (state is FreeReadingLoaded)
              ? 'Lectura Libre'
              : _formatToday(),
          reading: reading,
          colorScheme: colorScheme,
          showTapHint: hasConnections,
        ),
        Expanded(
          child: NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              if (notification.direction == ScrollDirection.reverse) {
                // Scrolling down -> hide bars for immersive reading
                if (_showControls) {
                  setState(() => _showControls = false);
                }
              } else if (notification.direction == ScrollDirection.forward) {
                // Scrolling up -> show bars
                if (!_showControls) {
                  setState(() => _showControls = true);
                }
              }
              return false;
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 6, 24, 40),
            itemCount: chapter.verses.length + 1,
            itemBuilder: (context, index) {
              if (index == chapter.verses.length) {
                final translationId =
                    ref.watch(userPreferencesProvider).value?.translationId ??
                        'spa_rvg';
                return ChapterCompletionCard(
                  chapter: chapter,
                  translationId: translationId,
                  source: (state is FreeReadingLoaded)
                      ? 'free_reading'
                      : 'daily_plan',
                );
              }
              final verse = chapter.verses[index];
              final annotation = annotations[verse.number];
              return VerseListItem(
                verse: verse,
                index: index,
                verseCount: chapter.verses.length,
                entranceAnimation: _entrance,
                fontSizeMultiplier: fontSizeMultiplier,
                annotation: annotation,
                onTap: () => _openVerseActions(
                  chapter,
                  verse,
                  annotation,
                ),
              );
            },
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
    final isFreeLoaded = state is FreeReadingLoaded;
    final isNavigating = state is Navigating;

    final List<ReadingPlanEntry>? plan = isLoaded
        ? state.plan
        : (isNavigating ? state.plan : null);
    final enabled = (isLoaded && plan != null) || isFreeLoaded;
    final currentIndex = isLoaded
        ? state.currentIndex
        : (isNavigating ? state.targetIndex : null);

    final position = isLoaded && plan != null && currentIndex != null
        ? '${currentIndex + 1} de ${plan.length}'
        : (isFreeLoaded ? state.chapter.reference : null);

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
                onTap: enabled ? _goToPrevious : null,
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
                onTap: enabled ? _goToNext : null,
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
  final VoidCallback? onTap;

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
                style: TextStyle(
                  color: foreground,
                  fontSize: 13,
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
