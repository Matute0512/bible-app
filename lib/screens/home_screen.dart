import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/bible_chapter.dart';
import '../models/user_preferences.dart';
import '../services/bible_api_service.dart';
import '../services/notification_service.dart';
import '../services/reading_plan_service.dart';

/// Main reading screen: shows the chapter of the day and the settings sheet.
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

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  BibleApiException? _error;
  BibleChapter? _chapter;

  /// Full reading plan, built once at load so chapter navigation is instant.
  List<ReadingPlanEntry>? _plan;

  /// Index in [_plan] the daily reading is anchored to (derived from the
  /// installation date). Manual navigation does not move it.
  int _todayIndex = 0;

  /// Current position in [_plan] while the user browses chapters.
  int _planIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
    // Ask for the Android 13+ notification permission here too, so users who
    // installed the app on Android 12 and later upgraded also get the runtime
    // prompt. It is a no-op (no dialog) once the user has already answered.
    _requestNotificationPermission();
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
      final plan =
          await widget.readingPlan.buildPlan(widget.preferences.translation);
      final elapsed = await widget.readingPlan.daysElapsed();
      final todayIndex = elapsed % plan.length;

      if (!mounted) {
        return;
      }
      setState(() {
        _plan = plan;
        _todayIndex = todayIndex;
        _planIndex = todayIndex;
      });

      await _fetchChapter();
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

  /// Loads the chapter at [_planIndex] into [_chapter].
  Future<void> _fetchChapter() async {
    final plan = _plan;
    if (plan == null) {
      return;
    }
    final entry = plan[_planIndex];
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
    });
  }

  /// Moves [delta] steps through the plan (wrapping around at both ends).
  Future<void> _goToChapter(int delta) async {
    final plan = _plan;
    if (plan == null || _loading) {
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _planIndex = (_planIndex + delta + plan.length) % plan.length;
    });
    try {
      await _fetchChapter();
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

  Future<void> _openSettings() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => _SettingsSheet(
        preferences: widget.preferences,
        onFontSizeChanged: _handleFontSizeChanged,
        onTimeChanged: _handleTimeChanged,
      ),
    );
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              scheduled ? Icons.check_circle : Icons.error_outline,
              color: scheduled ? null : Theme.of(context).colorScheme.error,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lectura de Hoy'),
        actions: [
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

  /// Previous/next chapter controls. Always rendered so the settings and the
  /// navigation are reachable from any state.
  Widget _buildChapterNav() {
    final plan = _plan;
    final enabled = plan != null && !_loading;
    final position = plan == null ? null : '${_planIndex + 1}/${plan.length}';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                label: 'Capítulo anterior',
                button: true,
                excludeSemantics: true,
                child: OutlinedButton.icon(
                  onPressed: enabled ? () => _goToChapter(-1) : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Capítulo Anterior'),
                ),
              ),
            ),
            if (position != null) ...[
              const SizedBox(width: 8),
              Text(
                position,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Semantics(
                label: 'Capítulo siguiente',
                button: true,
                excludeSemantics: true,
                child: OutlinedButton.icon(
                  onPressed: enabled ? () => _goToChapter(1) : null,
                  icon: const Icon(Icons.arrow_forward),
                  iconAlignment: IconAlignment.end,
                  label: const Text('Capítulo Siguiente'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _buildError();
    }
    return _buildChapter(_chapter!);
  }

  Widget _buildError() {
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
              _error!.message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Semantics(
            label:
                'Pasaje bíblico: ${chapter.bookName} capítulo ${chapter.chapterNumber}',
            excludeSemantics: true,
            child: Column(
              children: [
                Text(
                  chapter.reference,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatToday(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            itemCount: chapter.verses.length,
            itemBuilder: (context, index) {
              final verse = chapter.verses[index];
              final baseSize = 18.0 * widget.preferences.fontSizeMultiplier;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${verse.number}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        verse.text,
                        style: TextStyle(
                          // Serif for deep, traditional reading; the base
                          // 18sp scales with both the font slider and the
                          // system text scale factor.
                          fontFamily: 'serif',
                          fontSize: baseSize,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatToday() =>
      DateFormat('EEEE d MMMM', 'es').format(DateTime.now());
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

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Configuración', style: theme.textTheme.titleLarge),
          const SizedBox(height: 24),

          Text('Tamaño del texto bíblico', style: theme.textTheme.titleSmall),
          Row(
            children: [
              const Icon(Icons.text_fields),
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
              const Icon(Icons.text_fields),
            ],
          ),
          Text(
            '${(_fontSize * 100).round()}%',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: const Text('Hora de la notificación'),
            subtitle: Text(widget.preferences.notificationTime.format(context)),
            trailing: TextButton(
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
