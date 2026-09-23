import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/app_providers.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme/bible_theme.dart';

/// Global navigator key so the notification tap handler can route back to the
/// Home screen from anywhere in the app.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
    UncontrolledProviderScope(
      container: container,
      child: const BibleApp(),
    ),
  );
}

class BibleApp extends StatelessWidget {
  const BibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lectura Bíblica Diaria',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      // Follows the device theme (light/dark) automatically.
      themeMode: ThemeMode.system,
      theme: _appTheme(Brightness.light),
      darkTheme: _appTheme(Brightness.dark),
      locale: const Locale('es'),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const StartupGate(),
    );
  }

  /// Builds the warm "open book" theme for [brightness].
  ///
  /// Warm palette tuned for long reading sessions: deep indigo for wisdom and
  /// calm, amber/gold for accents and verse numbers, soft cream instead of
  /// pure white, and warm charcoal instead of pure black for body text. The
  /// reading typography lives in [BibleReadingStyle] so light and dark each
  /// carry their own legible variant.
  static ThemeData _appTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final reading = isLight ? BibleReadingStyle.light : BibleReadingStyle.dark;

    final scheme = ColorScheme.fromSeed(
      seedColor: ReadingPalette.indigo,
      brightness: brightness,
      primary: isLight ? ReadingPalette.indigo : null,
      onPrimary: isLight ? Colors.white : null,
      secondary: isLight ? ReadingPalette.amber : ReadingPalette.amberLight,
      surface: reading.readingBackground,
      onSurface: isLight
          ? ReadingPalette.charcoal
          : ReadingPalette.charcoalPaper,
    );

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: reading.readingBackground,
      extensions: [reading],
      appBarTheme: AppBarTheme(
        backgroundColor: reading.readingBackground,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      // Floating pill so the confirmation snack bar reads as a deliberate,
      // gentle toast instead of a material bar glued to the screen edge.
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        modalBackgroundColor: isLight
            ? ReadingPalette.paper
            : const Color(0xFF211C16),
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ReadingPalette.amberDivider,
        thickness: 1,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.primary.withValues(alpha: 0.16),
        thumbColor: scheme.primary,
        overlayColor: scheme.primary.withValues(alpha: 0.12),
        valueIndicatorColor: scheme.primary,
        valueIndicatorTextStyle: TextStyle(
          color: scheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
      splashFactory: InkSparkle.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}

/// Decides between Onboarding (first run) and Home (returning user).
class StartupGate extends ConsumerWidget {
  const StartupGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingPlan = ref.watch(readingPlanProvider);

    return FutureBuilder<bool>(
      future: readingPlan.hasInstallationDate(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data!) {
          return const HomeScreen();
        }
        return const OnboardingScreen();
      },
    );
  }
}
