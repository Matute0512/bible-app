import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_preferences.dart';
import '../providers/app_providers.dart';
import 'home_screen.dart';

/// First-run flow: pick a translation and a reminder time, then start reading.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  BibleTranslation _translation = BibleTranslation.evangelical;
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);
  bool _starting = false;

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      helpText: 'Elegí la hora del recordatorio',
    );
    if (picked != null && mounted) {
      setState(() => _time = picked);
    }
  }

  Future<void> _start() async {
    setState(() => _starting = true);

    final prefsNotifier = ref.read(userPreferencesProvider.notifier);
    final readingPlan = ref.read(readingPlanProvider);
    final notificationService = ref.read(notificationServiceProvider);

    await prefsNotifier.setTranslation(_translation);
    await prefsNotifier.setNotificationTime(_time);
    
    // Persists the UTC installation date that anchors the reading plan.
    await readingPlan.getInstallationDate();

    // Best-effort: denial of the notification permission must not block
    // onboarding (the user can re-enable it later).
    try {
      final granted = await notificationService.requestPermission();
      debugPrint('[notifications] Onboarding: permission $granted');
    } on Exception catch (error) {
      debugPrint('[notifications] Permission request failed: $error');
    }

    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.menu_book_rounded,
                  size: 64, color: colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Lectura Bíblica Diaria',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Un capítulo por día, a tu ritmo.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 40),

              Text('Elegí tu traducción',
                  style: theme.textTheme.titleSmall),
              const SizedBox(height: 12),
              SegmentedButton<BibleTranslation>(
                segments: const [
                  ButtonSegment(
                    value: BibleTranslation.evangelical,
                    label: Text('Evangélica'),
                  ),
                  ButtonSegment(
                    value: BibleTranslation.catholic,
                    label: Text('Católica'),
                  ),
                ],
                selected: {_translation},
                onSelectionChanged: (selection) {
                  setState(() => _translation = selection.first);
                },
              ),
              const SizedBox(height: 24),

              Text('¿A qué hora querés tu recordatorio?',
                  style: theme.textTheme.titleSmall),
              const SizedBox(height: 12),
              Semantics(
                label:
                    'Cambiar la hora del recordatorio. Hora actual: ${_time.format(context)}',
                button: true,
                excludeSemantics: true,
                child: OutlinedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.schedule),
                  label: Text(_time.format(context)),
                ),
              ),

              const Spacer(),

              Semantics(
                label: 'Comenzar a leer el plan de lectura diario',
                button: true,
                excludeSemantics: true,
                child: FilledButton(
                  onPressed: _starting ? null : _start,
                  child: _starting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Comenzar'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
