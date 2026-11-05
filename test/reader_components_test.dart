import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bible_app/providers/app_providers.dart';
import 'package:bible_app/screens/reading_screen.dart';
import 'package:bible_app/theme/bible_theme.dart';
import 'package:bible_app/services/notification_service.dart';

class MockNotificationService implements NotificationService {
  bool requestPermissionCalled = false;
  int scheduleDailyCalled = 0;
  int cancelDailyCalled = 0;

  @override
  VoidCallback? onNotificationTap;

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async {
    requestPermissionCalled = true;
    return true;
  }

  @override
  Future<void> cancelDaily() async {
    cancelDailyCalled++;
  }

  @override
  Future<bool> scheduleDailyNotification({
    required TimeOfDay time,
    required String passageReference,
  }) async {
    scheduleDailyCalled++;
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsSheet Component', () {
    testWidgets('toggles notification switch and updates preferences', (tester) async {
      SharedPreferences.setMockInitialValues({
        'pref_notifications_enabled': true,
      });

      final mockNotification = MockNotificationService();
      final container = ProviderContainer(
        overrides: [
          notificationServiceProvider.overrideWithValue(mockNotification),
        ],
      );
      addTearDown(container.dispose);

      await container.read(sharedPreferencesProvider.future);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: BibleTheme.build(Brightness.light),
            home: const Scaffold(
              body: SettingsSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find notifications switch
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      expect(tester.widget<Switch>(switchFinder).value, isTrue);

      // Ensure visible inside SingleChildScrollView and tap to disable notifications
      await tester.ensureVisible(switchFinder);
      await tester.pumpAndSettle();
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(tester.widget<Switch>(switchFinder).value, isFalse);
      expect(
        container.read(userPreferencesProvider).value?.notificationsEnabled,
        isFalse,
      );
      expect(mockNotification.cancelDailyCalled, greaterThanOrEqualTo(1));
    });

    testWidgets('dismisses via close button without modifying any preferences', (tester) async {
      SharedPreferences.setMockInitialValues({
        'pref_notifications_enabled': true,
      });

      final mockNotification = MockNotificationService();
      final container = ProviderContainer(
        overrides: [
          notificationServiceProvider.overrideWithValue(mockNotification),
        ],
      );
      addTearDown(container.dispose);

      await container.read(sharedPreferencesProvider.future);
      final initialPrefs = await container.read(userPreferencesProvider.future);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: BibleTheme.build(Brightness.light),
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      showDragHandle: true,
                      builder: (_) => const SettingsSheet(),
                    );
                  },
                  child: const Text('Abrir'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Configuración'), findsOneWidget);
      final closeBtn = find.byTooltip('Cerrar configuración');
      expect(closeBtn, findsOneWidget);

      await tester.tap(closeBtn);
      await tester.pumpAndSettle();

      expect(find.text('Configuración'), findsNothing);
      final finalPrefs = container.read(userPreferencesProvider).value;
      expect(finalPrefs?.fontSizeMultiplier, equals(initialPrefs.fontSizeMultiplier));
      expect(finalPrefs?.themeMode, equals(initialPrefs.themeMode));
      expect(finalPrefs?.translation, equals(initialPrefs.translation));
      expect(finalPrefs?.notificationsEnabled, equals(initialPrefs.notificationsEnabled));
      expect(finalPrefs?.notificationTime, equals(initialPrefs.notificationTime));
    });
  });

  group('ReadingScreen permission check', () {
    testWidgets('does not request notification permission if notifications are disabled', (tester) async {
      SharedPreferences.setMockInitialValues({
        'installation_date_utc': DateTime.now().toUtc().toIso8601String(),
        'pref_notifications_enabled': false,
      });

      final mockNotification = MockNotificationService();
      final container = ProviderContainer(
        overrides: [
          notificationServiceProvider.overrideWithValue(mockNotification),
        ],
      );
      addTearDown(container.dispose);

      await container.read(sharedPreferencesProvider.future);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: BibleTheme.build(Brightness.light),
            home: const ReadingScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(mockNotification.requestPermissionCalled, isFalse);
    });
  });
}

