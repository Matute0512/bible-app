import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/app_providers.dart';
import 'models/user_preferences.dart';
import 'theme/bible_theme.dart';
import 'router.dart';

// The global navigatorKey is now in router.dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Loads Spanish date patterns for the `intl` formatters used in the UI.
  await initializeDateFormatting('es');

  final container = ProviderContainer();
  // Wait for SharedPreferences to be ready within the Riverpod scope
  await container.read(sharedPreferencesProvider.future);

  final notificationService = container.read(notificationServiceProvider);
  await notificationService.init();

  runApp(
    UncontrolledProviderScope(container: container, child: const BibleApp()),
  );
}

class BibleApp extends ConsumerWidget {
  const BibleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider).value;
    final themeModePreference = prefs?.themeMode ?? AppThemeMode.system;

    ThemeMode themeMode;
    switch (themeModePreference) {
      case AppThemeMode.system:
        themeMode = ThemeMode.system;
        break;
      case AppThemeMode.light:
      case AppThemeMode.sepia:
        themeMode = ThemeMode.light;
        break;
      case AppThemeMode.dark:
        themeMode = ThemeMode.dark;
        break;
    }

    final isSepia = themeModePreference == AppThemeMode.sepia;
    final lightTheme = _appTheme(Brightness.light, isSepia: isSepia);
    final darkTheme = _appTheme(Brightness.dark);

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Lectura Bíblica Diaria',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      locale: const Locale('es'),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }

  /// Builds the warm "open book" theme for [brightness].
  ///
  /// Warm palette tuned for long reading sessions: deep indigo for wisdom and
  /// calm, amber/gold for accents and verse numbers, soft cream instead of
  /// pure white, and warm charcoal instead of pure black for body text. The
  /// reading typography lives in [BibleReadingStyle] so light and dark each
  /// carry their own legible variant.
  static ThemeData _appTheme(Brightness brightness, {bool isSepia = false}) {
    return BibleTheme.build(brightness, isSepia: isSepia);
  }
}
