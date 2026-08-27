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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final plan =
          await widget.readingPlan.todayAndTomorrow(widget.preferences.translation);

      final chapter = await widget.api.fetchChapter(
        translationId: widget.preferences.translation.translationId,
        bookId: plan.today.bookId,
        bookName: plan.today.bookName,
        chapterNumber: plan.today.chapterNumber,
      );

      if (!mounted) {
        return;
      }
      setState(() {
        _chapter = chapter;
        _loading = false;
      });

      // Keep the daily notification in sync with the reading plan.
      await _rescheduleNotification(plan.tomorrow.reference);
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

  /// Re-arms the daily notification with the upcoming passage. Best-effort:
  /// notification failures must never block the reading.
  Future<void> _rescheduleNotification(String passageReference) async {
    if (!widget.preferences.notificationsEnabled) {
      return;
    }
    try {
      await widget.notificationService.scheduleDailyNotification(
        time: widget.preferences.notificationTime,
        passageReference: passageReference,
      );
    } on Exception {
      // Scheduling is best-effort.
    }
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

    try {
      final plan =
          await widget.readingPlan.todayAndTomorrow(widget.preferences.translation);
      await widget.notificationService.scheduleDailyNotification(
        time: time,
        passageReference: plan.tomorrow.reference,
      );
    } on Exception {
      // The reading still works even if scheduling fails.
    }

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle),
            SizedBox(width: 12),
            Expanded(child: Text('Notificación diaria programada')),
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
      body: _buildBody(),
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
                'Pasaje bíblico del día: ${chapter.bookName} capítulo ${chapter.chapterNumber}',
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
