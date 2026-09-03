import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/bible_chapter.dart';
import '../models/user_preferences.dart';
import '../models/verse.dart';
import '../services/bible_api_service.dart';
import '../services/notification_service.dart';
import '../services/reading_plan_service.dart';
import '../services/verse_connections_service.dart';
import '../theme/bible_theme.dart';
import '../widgets/graph_explorer.dart';
import '../widgets/verse_shimmer.dart';

/// Main reading screen: shows the chapter of the day, its curated connection
/// graph and the settings sheet.
///
/// Text widgets scale with the system text scale factor automatically, so the
/// biblical text honors the user's accessibility preferences on top of the
/// manual font-size slider.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.preferences,
    required this.api,
    required this.readingPlan,
    required this.notificationService,
  });

  final UserPreferences preferences;
  final BibleApiService api;
  final ReadingPlanService readingPlan;
  final NotificationService notificationService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  /// True only while the very first chapter (or a retry) is being fetched;
  /// shows the shimmer skeleton.
  bool _loading = true;

  /// True while the user browses from one chapter to another; keeps the
  /// current chapter visible under a thin progress line until the new one is
  /// ready, then cross-fades.
  bool _switching = false;

  BibleApiException? _error;
  BibleChapter? _chapter;

  /// Full reading plan, built once at load so chapter navigation is instant.
  List<ReadingPlanEntry>? _plan;

  /// Index in [_plan] the daily reading is anchored to (derived from the
  /// installation date). Manual navigation does not move it.
  int _todayIndex = 0;

  /// Current position in [_plan] while the user browses chapters.
  int _planIndex = 0;

  /// Drives the subtle staggered fade-in of verses after a chapter arrives.
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  @override
  void initState() {
    super.initState();
    _load();
    // Ask for the Android 13+ notification permission here too, so users who
    // installed the app on Android 12 and later upgraded also get the runtime
    // prompt. It is a no-op (no dialog) once the user has already answered.
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
      await widget.notificationService.requestPermission();
    } on Exception {
      // Permission denial is non-fatal.
    }
  }

  /// Builds the plan, anchors [todayIndex]/[_planIndex] to today, loads the
  /// chapter and re-arms the daily reminder. Errors reuse the retry UI.
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final plan = await widget.readingPlan.buildPlan(
        widget.preferences.translation,
      );
      final elapsed = await widget.readingPlan.daysElapsed();
      final todayIndex = elapsed % plan.length;

      if (!mounted) {
        return;
      }
      setState(() {
        _plan = plan;
        _todayIndex = todayIndex;
        _planIndex = todayIndex;
        _loading = false;
      });

      await _fetchChapterAt(_planIndex);
      await _rescheduleNotification();
    } on BibleApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  /// Fetches the chapter at [index] and swaps it in with a fade.
  Future<void> _fetchChapterAt(int index) async {
    final plan = _plan;
    if (plan == null) {
      return;
    }
    final entry = plan[index];
    final chapter = await widget.api.fetchChapter(
      translationId: widget.preferences.translation.translationId,
      bookId: entry.bookId,
      bookName: entry.bookName,
      chapterNumber: entry.chapterNumber,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _chapter = chapter;
      _loading = false;
      _switching = false;
    });
    _entrance.forward(from: 0);
  }

  /// Moves [delta] steps through the plan (wrapping around at both ends).
  Future<void> _goToChapter(int delta) async {
    final plan = _plan;
    if (plan == null || _loading || _switching) {
      return;
    }
    final next = (_planIndex + delta + plan.length) % plan.length;
    await _goToPlanIndex(next);
  }

  /// Navigates to the plan entry at [index], keeping the old chapter on screen
  /// (under a thin progress line) until the new one is ready.
  Future<void> _goToPlanIndex(int index) async {
    final plan = _plan;
    if (plan == null || _loading || _switching) {
      return;
    }
    if (index == _planIndex && _chapter != null) {
      return;
    }

    setState(() {
      _switching = true;
      _error = null;
      _planIndex = index;
    });

    try {
      await _fetchChapterAt(index);
    } on BibleApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error;
        _switching = false;
      });
    }
  }

  /// Re-arms the daily notification with the passage the user will see when it
  /// fires: today's chapter when the reminder still fires today, tomorrow's
  /// when today's reminder already passed. Always anchored to the daily
  /// [_todayIndex], regardless of manual navigation. Best-effort: failures
  /// must never block the reading. Returns whether scheduling succeeded.
  Future<bool> _rescheduleNotification() async {
    final plan = _plan;
    if (!widget.preferences.notificationsEnabled || plan == null) {
      return false;
    }
    try {
      return await widget.notificationService.scheduleDailyNotification(
        time: widget.preferences.notificationTime,
        passageReference: _entryForNextReminder(plan).reference,
      );
    } on Exception catch (error) {
      debugPrint('[notifications] Scheduling failed: $error');
      return false;
    }
  }

  /// The chapter the daily reminder should advertise, based on whether the
  /// reminder time still falls later today or already passed.
  ReadingPlanEntry _entryForNextReminder(List<ReadingPlanEntry> plan) {
    final now = TimeOfDay.now();
    final reminder = widget.preferences.notificationTime;
    final nowMinutes = now.hour * 60 + now.minute;
    final reminderMinutes = reminder.hour * 60 + reminder.minute;
    final index = nowMinutes >= reminderMinutes
        ? (_todayIndex + 1) % plan.length
        : _todayIndex;
    return plan[index];
  }

  // ---------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------

  Future<void> _openSettings() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _SettingsSheet(
        preferences: widget.preferences,
        onFontSizeChanged: _handleFontSizeChanged,
        onTimeChanged: _handleTimeChanged,
      ),
    );
  }

  /// Opens the connection graph centered on the current chapter.
  Future<void> _openGraphExplorer({int? fromVerse}) async {
    final chapter = _chapter;
    if (chapter == null) {
      return;
    }
    final center = PassageRef(
      bookId: chapter.bookId,
      bookName: chapter.bookName,
      chapterNumber: chapter.chapterNumber,
    );
    await showGraphExplorer(
      context: context,
      center: center,
      connections: VerseConnectionService.instance.connectionsFor(
        bookId: chapter.bookId,
        chapterNumber: chapter.chapterNumber,
      ),
      originHint: fromVerse == null ? null : 'desde el versículo $fromVerse',
      onOpenPassage: _openPassageFromGraph,
    );
  }

  /// Called when a node/chip is tapped inside the graph sheet: closes the
  /// sheet and navigates to the connected passage when it belongs to the plan.
  void _openPassageFromGraph(PassageRef target) {
    final plan = _plan;
    Navigator.of(context).pop();
    if (plan == null) {
      return;
    }
    final index = plan.indexWhere(
      (entry) =>
          entry.bookId == target.bookId &&
          entry.chapterNumber == target.chapterNumber,
    );
    if (index < 0) {
      _showSnack(
        success: false,
        message: 'Este pasaje no está en tu plan actual de lectura',
      );
      return;
    }
    _goToPlanIndex(index);
  }

  Future<void> _handleFontSizeChanged(double value) async {
    await widget.preferences.setFontSizeMultiplier(value);
    if (mounted) {
      setState(() {}); // Rebuild the verses with the new size.
    }
  }

  Future<void> _handleTimeChanged(TimeOfDay time) async {
    await widget.preferences.setNotificationTime(time);
    final scheduled = await _rescheduleNotification();
    if (!mounted) {
      return;
    }
    _showSnack(
      success: scheduled,
      message: scheduled
          ? 'Notificación diaria programada'
          : 'No se pudo programar la notificación. Revisá los permisos',
    );
  }

  /// Shows the elegant floating confirmation/error toast.
  void _showSnack({required bool success, required String message}) {
    if (!mounted) {
      return;
    }
    final colorScheme = Theme.of(context).colorScheme;
    // The check must keep contrast against whichever pill the snack bar theme
    // paints (dark in light mode, light in dark mode).
    final onLightPill = colorScheme.inverseSurface.computeLuminance() > 0.5;
    final checkColor = onLightPill
        ? const Color(0xFF2E7D32) // deep green on a light pill
        : const Color(0xFF7CD38B); // light green on a dark pill

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error_outline,
                size: 22,
                color: success ? checkColor : colorScheme.error,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
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
              onPressed: _chapter == null ? null : () => _openGraphExplorer(),
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
      bottomNavigationBar: _buildChapterNav(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final progressBar = _switching
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
              key: ValueKey<String>(_contentKey()),
              child: _buildCurrentContent(),
            ),
          ),
        ),
      ],
    );
  }

  /// Stable identity for the animated switcher so chapter changes (and load →
  /// content) cross-fade instead of cutting over.
  String _contentKey() {
    if (_loading) {
      return 'loading';
    }
    final error = _error;
    if (error != null) {
      return 'error:${error.message}';
    }
    return _chapter?.reference ?? 'loading';
  }

  Widget _buildCurrentContent() {
    final error = _error;
    // A failure always surfaces its retry UI — even when no chapter has been
    // shown yet (first load) so the user is never stuck on a silent skeleton.
    if (error != null && !_loading) {
      return _buildError(error);
    }
    if (_loading || _chapter == null) {
      return const VerseShimmerList();
    }
    return _buildChapter(_chapter!);
  }

  Widget _buildError(BibleApiException error) {
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
              error.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _load,
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
    final hasConnections = VerseConnectionService.instance.hasConnections(
      bookId: chapter.bookId,
      chapterNumber: chapter.chapterNumber,
    );

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
            itemBuilder: (context, index) => _buildVerse(
              chapter.verses[index],
              index,
              chapter.verses.length,
            ),
          ),
        ),
      ],
    );
  }

  /// One verse row: amber numeral + serif text, with a staggered entrance and
  /// a tap that opens the passage's connection graph.
  Widget _buildVerse(Verse verse, int index, int verseCount) {
    final reading = Theme.of(context).extension<BibleReadingStyle>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _entrance,
      builder: (context, _) {
        // Each verse occupies a slice of the animation timeline, so the ones
        // near the top fade in just before those further down the scroll.
        final span = 0.9;
        final slice = verseCount > 0 ? span / verseCount : 1.0;
        final start = index * slice;
        final local = ((_entrance.value - start) / slice)
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
                  onTap: () => _openGraphExplorer(fromVerse: verse.number),
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
                              .readingText(
                                widget.preferences.fontSizeMultiplier,
                              )
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

  // ---------------------------------------------------------------------
  // Chapter navigation (previous / next)
  // ---------------------------------------------------------------------

  Widget _buildChapterNav() {
    final plan = _plan;
    final enabled =
        plan != null && !_loading && !_switching && _chapter != null;
    final position = plan == null
        ? null
        : '${_planIndex + 1} de ${plan.length}';

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
                onTap: () => _goToChapter(-1),
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
                onTap: () => _goToChapter(1),
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
class _SettingsSheet extends StatefulWidget {
  const _SettingsSheet({
    required this.preferences,
    required this.onFontSizeChanged,
    required this.onTimeChanged,
  });

  final UserPreferences preferences;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;

  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  late double _fontSize;

  @override
  void initState() {
    super.initState();
    _fontSize = widget.preferences.fontSizeMultiplier;
  }

  void _onFontSizeChanged(double value) {
    setState(() => _fontSize = value);
    widget.onFontSizeChanged(value);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: widget.preferences.notificationTime,
      helpText: 'Elegí la hora del recordatorio',
    );
    if (picked == null || !mounted) {
      return;
    }
    // Close the sheet first so the confirmation SnackBar is visible.
    Navigator.of(context).pop();
    widget.onTimeChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
            subtitle: Text(widget.preferences.notificationTime.format(context)),
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
