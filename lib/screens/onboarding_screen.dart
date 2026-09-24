import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../models/user_preferences.dart';
import '../providers/app_providers.dart';
import 'reading_screen.dart';

/// First-run flow: pick a translation and a reminder time, then start reading.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  BibleTranslation _translation = BibleTranslation.evangelical;
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);
  bool _starting = false;
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
      MaterialPageRoute<void>(builder: (_) => const ReadingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _buildPage(
                    title: 'Lectura Bíblica Diaria',
                    description:
                        'Un capítulo por día, a tu propio ritmo. Seguí el plan de lectura sin apuros.',
                    icon: Icons.menu_book_rounded,
                    colorScheme: colorScheme,
                    theme: theme,
                  ),
                  _buildPage(
                    title: 'Conexiones Profundas',
                    description:
                        'Explorá relaciones entre pasajes a través del grafo interactivo.',
                    icon: Icons.hub_outlined,
                    colorScheme: colorScheme,
                    theme: theme,
                  ),
                  _buildSettingsPage(theme, colorScheme),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: 3,
                    effect: ExpandingDotsEffect(
                      activeDotColor: colorScheme.primary,
                      dotColor: colorScheme.primary.withValues(alpha: 0.2),
                      dotHeight: 8,
                      dotWidth: 8,
                    ),
                  ),
                  if (_currentPage == 2)
                    FilledButton(
                      onPressed: _starting ? null : _start,
                      child: _starting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Comenzar'),
                    )
                  else
                    FilledButton.tonal(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Siguiente'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String description,
    required IconData icon,
    required ColorScheme colorScheme,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 80, color: colorScheme.primary),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPage(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Personalizá tu experiencia',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 48),
          Text('Elegí tu traducción', style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: SegmentedButton<BibleTranslation>(
              segments: const [
                ButtonSegment(
                  value: BibleTranslation.evangelical,
                  label: Text('Reina Valera'),
                ),
                ButtonSegment(
                  value: BibleTranslation.catholic,
                  label: Text('Latinoamericana'),
                ),
              ],
              selected: {_translation},
              onSelectionChanged: (selection) {
                setState(() => _translation = selection.first);
              },
            ),
          ),
          const SizedBox(height: 32),
          Text(
            '¿A qué hora querés tu recordatorio?',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickTime,
            icon: const Icon(Icons.schedule),
            label: Text(_time.format(context)),
          ),
        ],
      ),
    );
  }
}
