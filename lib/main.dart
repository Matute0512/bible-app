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
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF5C6BC0),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF5C6BC0),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
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
