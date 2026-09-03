import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/user_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/bible_api_service.dart';
import 'services/notification_service.dart';
import 'services/reading_plan_service.dart';
import 'theme/bible_theme.dart';

/// Global navigator key so the notification tap handler can route back to the
/// Home screen from anywhere in the app.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Loads Spanish date patterns for the `intl` formatters used in the UI.
  await initializeDateFormatting('es');

  final prefs = await SharedPreferences.getInstance();
  final api = BibleApiService();
  final readingPlan = ReadingPlanService(api: api, prefs: prefs);
  final notificationService = NotificationService(
    onNotificationTap: () {
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
    },
  );
  await notificationService.init();

  runApp(
    BibleApp(
      preferences: await UserPreferences.load(),
      api: api,
      readingPlan: readingPlan,
      notificationService: notificationService,
    ),
  );
}

class BibleApp extends StatelessWidget {
  const BibleApp({
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
      home: StartupGate(
        preferences: preferences,
        api: api,
        readingPlan: readingPlan,
        notificationService: notificationService,
      ),
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
class StartupGate extends StatefulWidget {
  const StartupGate({
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
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  bool? _onboardingCompleted;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final completed = await widget.readingPlan.hasInstallationDate();
    if (!mounted) {
      return;
    }
    setState(() => _onboardingCompleted = completed);
  }

  @override
  Widget build(BuildContext context) {
    if (_onboardingCompleted == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_onboardingCompleted!) {
      return HomeScreen(
        preferences: widget.preferences,
        api: widget.api,
        readingPlan: widget.readingPlan,
        notificationService: widget.notificationService,
      );
    }
    return OnboardingScreen(
      preferences: widget.preferences,
      api: widget.api,
      readingPlan: widget.readingPlan,
      notificationService: widget.notificationService,
    );
  }
}
