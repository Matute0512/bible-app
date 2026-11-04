import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bible_app/models/bible_book.dart';
import 'package:bible_app/models/bible_chapter.dart';
import 'package:bible_app/models/verse.dart';
import 'package:bible_app/providers/app_providers.dart';
import 'package:bible_app/router.dart';
import 'package:bible_app/screens/app_shell_screen.dart';
import 'package:bible_app/screens/dashboard_screen.dart';
import 'package:bible_app/screens/explore_screen.dart';
import 'package:bible_app/screens/onboarding_screen.dart';
import 'package:bible_app/screens/reading_screen.dart';
import 'package:bible_app/screens/saved_screen.dart';
import 'package:bible_app/screens/study_screen.dart';
import 'package:bible_app/services/bible_api_service.dart';
import 'package:bible_app/services/notification_service.dart';
import 'package:bible_app/services/reading_plan_service.dart';
import 'package:bible_app/theme/bible_theme.dart';

class MockApi implements BibleApiService {
  @override
  Future<Map<String, dynamic>> fetchCompleteTranslationSimple(String translationId) async => {};
  @override
  Future<List<BibleBook>> fetchBooks(String translationId) async => [
    const BibleBook(id: 'GEN', name: 'Génesis', order: 1, chapterCount: 50),
  ];

  @override
  Future<BibleChapter> fetchChapter({
    required String translationId,
    required String bookId,
    required String bookName,
    required int chapterNumber,
  }) async => BibleChapter(
    bookId: bookId,
    bookName: bookName,
    chapterNumber: chapterNumber,
    verses: [const Verse(number: 1, text: 'En el principio...')],
  );
}

class MockNotification implements NotificationService {
  @override
  VoidCallback? get onNotificationTap => null;
  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> cancelDaily() async {}
  @override
  Future<bool> scheduleDailyNotification({
    required TimeOfDay time,
    required String passageReference,
  }) async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  group('Router tests', () {
    testWidgets('redirects to /onboarding when installation date is missing', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(MockApi()),
          notificationServiceProvider.overrideWithValue(MockNotification()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(sharedPreferencesProvider.future);
      final router = container.read(routerProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: ThemeData(extensions: [BibleReadingStyle.light]),
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets(
      'allows accessing /onboarding directly when already configured',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          ReadingPlanService.installationDateKey: DateTime.now()
              .toUtc()
              .toIso8601String(),
        });

        final container = ProviderContainer(
          overrides: [
            apiServiceProvider.overrideWithValue(MockApi()),
            notificationServiceProvider.overrideWithValue(MockNotification()),
          ],
        );
        addTearDown(container.dispose);

        await container.read(sharedPreferencesProvider.future);
        final router = container.read(routerProvider);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              theme: ThemeData(extensions: [BibleReadingStyle.light]),
              routerConfig: router,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(DashboardScreen), findsOneWidget);
      },
    );

    testWidgets(
      'notification tap navigates to reading with dashboard in stack',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          ReadingPlanService.installationDateKey: DateTime.now()
              .toUtc()
              .toIso8601String(),
        });

        final container = ProviderContainer(
          overrides: [
            apiServiceProvider.overrideWithValue(MockApi()),
            notificationServiceProvider.overrideWithValue(MockNotification()),
          ],
        );
        addTearDown(container.dispose);

        await container.read(sharedPreferencesProvider.future);
        final router = container.read(routerProvider);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              theme: ThemeData(extensions: [BibleReadingStyle.light]),
              routerConfig: router,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(DashboardScreen), findsOneWidget);

        // Trigger notification tap logic
        final navContext = navigatorKey.currentContext;
        expect(navContext, isNotNull);
        // Navigate to /dashboard/reading
        navContext!.go('/dashboard/reading');
        await tester.pumpAndSettle();

        expect(find.byType(ReadingScreen), findsOneWidget);

        // Verify that pop is possible and returns to DashboardScreen
        router.pop();
        await tester.pumpAndSettle();
        expect(find.byType(DashboardScreen), findsOneWidget);
      },
    );

    testWidgets(
      'AppShellScreen renders 4 tabs and switches branches smoothly',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          ReadingPlanService.installationDateKey: DateTime.now()
              .toUtc()
              .toIso8601String(),
        });

        final container = ProviderContainer(
          overrides: [
            apiServiceProvider.overrideWithValue(MockApi()),
            notificationServiceProvider.overrideWithValue(MockNotification()),
          ],
        );
        addTearDown(container.dispose);

        await container.read(sharedPreferencesProvider.future);
        final router = container.read(routerProvider);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              theme: BibleTheme.build(Brightness.light),
              routerConfig: router,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Verify AppShell navigation bar exists with 4 destinations
        expect(find.byType(AppShellScreen), findsOneWidget);
        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.widgetWithText(NavigationDestination, 'Inicio'), findsOneWidget);
        expect(find.widgetWithText(NavigationDestination, 'Biblia'), findsOneWidget);
        expect(find.widgetWithText(NavigationDestination, 'Guardados'), findsOneWidget);
        expect(find.widgetWithText(NavigationDestination, 'Estudio'), findsOneWidget);

        // Initial tab is DashboardScreen
        expect(find.byType(DashboardScreen), findsOneWidget);

        // 2. Switch to 'Biblia' tab
        await tester.tap(find.widgetWithText(NavigationDestination, 'Biblia'));
        await tester.pumpAndSettle();
        expect(find.byType(ExploreScreen), findsOneWidget);

        // 3. Switch to 'Guardados' tab
        await tester.tap(find.widgetWithText(NavigationDestination, 'Guardados'));
        await tester.pumpAndSettle();
        expect(find.byType(SavedScreen), findsOneWidget);

        // 4. Switch to 'Estudio' tab
        await tester.tap(find.widgetWithText(NavigationDestination, 'Estudio'));
        await tester.pumpAndSettle();
        expect(find.byType(StudyScreen), findsOneWidget);

        // 5. Navigate to /reading directly -> full-screen reading mode (no NavigationBar)
        router.go('/reading');
        await tester.pumpAndSettle();
        expect(find.byType(ReadingScreen), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
      },
    );
  });
}
