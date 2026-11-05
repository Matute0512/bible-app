import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers.dart';
import '../../services/backup_service.dart';
import '../../theme/bible_theme.dart';

/// Modal bottom sheet with typography slider, 4-theme selector, translation picker,
/// and notification toggle + reminder time picker.
class SettingsSheet extends ConsumerStatefulWidget {
  const SettingsSheet({super.key});

  @override
  ConsumerState<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends ConsumerState<SettingsSheet> {
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

  Future<void> _onToggleNotifications(bool enabled) async {
    await ref
        .read(userPreferencesProvider.notifier)
        .setNotificationsEnabled(enabled);

    if (!enabled) {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.cancelDaily();
    } else {
      await ref
          .read(dailyReadingProvider.notifier)
          .rescheduleNotification();
    }
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
    final reading = theme.extension<BibleReadingStyle>() ??
        BibleReadingStyle.light;
    final notificationsEnabled = preferences?.notificationsEnabled ?? true;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 12, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Configuración', style: theme.textTheme.titleLarge),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Cerrar configuración',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24,
                8,
                24,
                MediaQuery.paddingOf(context).bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCard(
            context,
            title: 'Lectura',
            icon: Icons.text_fields,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Live preview
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: reading.readingBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: reading.headingDivider),
                  ),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: '1 ', style: reading.verseNumber),
                        TextSpan(
                          text:
                              'En el principio creó Dios los cielos y la tierra.',
                          style: reading.readingText(_fontSize),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
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
                const SizedBox(height: 16),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SegmentedButton<AppThemeMode>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: AppThemeMode.system,
                        icon: Icon(Icons.brightness_auto),
                        label: Text('Auto'),
                      ),
                      ButtonSegment(
                        value: AppThemeMode.light,
                        icon: Icon(Icons.light_mode),
                        label: Text('Claro'),
                      ),
                      ButtonSegment(
                        value: AppThemeMode.sepia,
                        icon: Icon(Icons.menu_book),
                        label: Text('Sepia'),
                      ),
                      ButtonSegment(
                        value: AppThemeMode.dark,
                        icon: Icon(Icons.dark_mode),
                        label: Text('Oscuro'),
                      ),
                    ],
                    selected: {preferences?.themeMode ?? AppThemeMode.system},
                    onSelectionChanged: (set) {
                      ref
                          .read(userPreferencesProvider.notifier)
                          .setThemeMode(set.first);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildCard(
            context,
            title: 'Traducción',
            icon: Icons.translate,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SegmentedButton<BibleTranslation>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: BibleTranslation.evangelical,
                    label: Text('RVG (66 libros)'),
                  ),
                  ButtonSegment(
                    value: BibleTranslation.catholic,
                    label: Text('BLM (73 libros)'),
                  ),
                ],
                selected: {
                  preferences?.translation ?? BibleTranslation.evangelical,
                },
                onSelectionChanged: (set) {
                  ref
                      .read(userPreferencesProvider.notifier)
                      .setTranslation(set.first);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildCard(
            context,
            title: 'Recordatorio',
            icon: Icons.notifications_active,
            iconColor: ReadingPalette.amber,
            iconBg: ReadingPalette.amber.withValues(alpha: 0.16),
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Recordatorio diario'),
                    subtitle: const Text('Notificación para tu capítulo del día'),
                    value: notificationsEnabled,
                    onChanged: _onToggleNotifications,
                  ),
                  if (notificationsEnabled) ...[
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Hora del recordatorio'),
                      subtitle: Text(
                        preferences?.notificationTime.format(context) ?? '',
                      ),
                      trailing: FilledButton.tonal(
                        onPressed: _pickTime,
                        child: const Text('Cambiar'),
                      ),
                      onTap: _pickTime,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildCard(
            context,
            title: 'Copia de Seguridad Local',
            icon: Icons.backup_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Exporta tus notas, versículos favoritos, colores de resaltado y planes a un archivo JSON portable.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () async {
                          final db = ref.read(databaseProvider);
                          await const BackupService().shareBackupFile(db);
                        },
                        icon: const Icon(Icons.share_outlined, size: 16),
                        label: const Text('Exportar JSON'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showRestoreDialog,
                        icon: const Icon(Icons.restore_page_outlined, size: 16),
                        label: const Text('Restaurar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildCard(
            context,
            title: 'Información y Licencias',
            icon: Icons.info_outline,
            child: Material(
              type: MaterialType.transparency,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Acerca de, Licencias y Privacidad'),
                subtitle: const Text('Atribución bíblica, fuentes SIL OFL y filosofía local-first'),
                trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/about');
                  },
                ),
              ),
            ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    Color? iconColor,
    Color? iconBg,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBg ?? colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: iconColor ?? colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Future<void> _showRestoreDialog() async {
    final textController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Restaurar copia de seguridad'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pega el contenido JSON de tu copia de seguridad para restaurar notas, favoritos e historial:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: '{\n  "version": 1,\n  "app": "bible_app", ...\n}',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dCtx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dCtx).pop(true),
            child: const Text('Importar'),
          ),
        ],
      ),
    );

    if (result == true && textController.text.trim().isNotEmpty && mounted) {
      try {
        final db = ref.read(databaseProvider);
        final importSummary = await const BackupService().importUserDataJson(
          db,
          textController.text.trim(),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '¡Copia restaurada! (${importSummary.totalRecords} registros importados)',
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text('Error al restaurar: $e'),
          ),
        );
      }
    }
  }
}
