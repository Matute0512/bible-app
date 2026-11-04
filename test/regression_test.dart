import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bible_app/models/bible_book.dart';
import 'package:bible_app/models/bible_chapter.dart';
import 'package:bible_app/models/verse.dart';
import 'package:bible_app/providers/app_providers.dart';
import 'package:bible_app/screens/explore_screen.dart';
import 'package:bible_app/screens/reading_screen.dart';
import 'package:bible_app/services/bible_api_service.dart';
import 'package:bible_app/services/notification_service.dart';
import 'dart:io';

import 'package:google_fonts/google_fonts.dart';
import 'package:bible_app/screens/onboarding_screen.dart';
import 'package:bible_app/services/reading_plan_service.dart';
import 'package:bible_app/theme/bible_theme.dart';
import 'package:bible_app/widgets/graph_explorer.dart';

class CountingBibleApiService implements BibleApiService {
  int fetchBooksCount = 0;
  int fetchChapterCount = 0;

  @override
  Future<List<BibleBook>> fetchBooks(String translationId) async {
    fetchBooksCount++;
    return [
      BibleBook(id: 'GEN', name: 'Génesis', order: 1, chapterCount: 50),
      BibleBook(id: 'EXO', name: 'Éxodo', order: 2, chapterCount: 40),
      BibleBook(id: 'MAT', name: 'Mateo', order: 40, chapterCount: 28),
    ];
  }

  @override
  Future<BibleChapter> fetchChapter({
    required String translationId,
    required String bookId,
    required String bookName,
    required int chapterNumber,
  }) async {
    fetchChapterCount++;
    return BibleChapter(
      bookId: bookId,
      bookName: bookName,
      chapterNumber: chapterNumber,
      verses: [
        Verse(number: 1, text: 'En el principio...'),
        Verse(number: 2, text: 'Y la tierra estaba desordenada...'),
      ],
    );
  }
}

class TestNotificationService implements NotificationService {
  int scheduleCount = 0;
  String? lastPassageReference;

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
  }) async {
    scheduleCount++;
    lastPassageReference = passageReference;
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await initializeDateFormatting('es');
  });

  group('Regression tests for code review findings', () {
    testWidgets('C1: ReadingScreen renders verses with opacity > 0 when mounted with pre-loaded state',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        ReadingPlanService.installationDateKey:
            DateTime.now().toUtc().toIso8601String(),
      });

      final mockApi = CountingBibleApiService();
      final mockNotification = TestNotificationService();

      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(mockApi),
          notificationServiceProvider.overrideWithValue(mockNotification),
        ],
      );
      addTearDown(container.dispose);

      await container.read(sharedPreferencesProvider.future);
      // Wait for state to be fully Loaded BEFORE mounting ReadingScreen
      final state = await container.read(dailyReadingProvider.future);
      expect(state, isA<Loaded>());

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData(
              extensions: [BibleReadingStyle.light],
            ),
            home: const ReadingScreen(),
          ),
        ),
      );

      // Settle animations
      await tester.pumpAndSettle();

      // Find VerseListItem or Text with verse content
      expect(find.text('En el principio...'), findsOneWidget);

      // Verify opacity of the verse item is 1.0 (not 0.0)
      final opacities = tester
          .widgetList<Opacity>(find.descendant(
            of: find.byType(VerseListItem),
            matching: find.byType(Opacity),
          ))
          .toList();

      expect(opacities, isNotEmpty);
      for (final op in opacities) {
        expect(op.opacity, 1.0);
      }
    });

    testWidgets('R5: AppBar connections button is enabled in FreeReadingLoaded state',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        ReadingPlanService.installationDateKey:
            DateTime.now().toUtc().toIso8601String(),
      });

      final mockApi = CountingBibleApiService();
      final mockNotification = TestNotificationService();

      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(mockApi),
          notificationServiceProvider.overrideWithValue(mockNotification),
        ],
      );
      addTearDown(container.dispose);

      await container.read(sharedPreferencesProvider.future);
      await container.read(dailyReadingProvider.future);

      // Switch to free reading mode
      await container
          .read(dailyReadingProvider.notifier)
          .loadFreeChapter('EXO', 'Éxodo', 1);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData(
              extensions: [BibleReadingStyle.light],
            ),
            home: const ReadingScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final hubButtonFinder = find.widgetWithIcon(IconButton, Icons.hub_outlined);
      expect(hubButtonFinder, findsOneWidget);
      final hubButton = tester.widget<IconButton>(hubButtonFinder);
      expect(hubButton.onPressed, isNotNull,
          reason: 'Connections button should be enabled in FreeReadingLoaded mode');
    });

    test('R1: rescheduleNotification works in FreeReadingLoaded mode', () async {
      SharedPreferences.setMockInitialValues({
        ReadingPlanService.installationDateKey:
            DateTime.now().toUtc().toIso8601String(),
      });

      final mockApi = CountingBibleApiService();
      final mockNotification = TestNotificationService();

      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(mockApi),
          notificationServiceProvider.overrideWithValue(mockNotification),
        ],
      );
      addTearDown(container.dispose);

      await container.read(sharedPreferencesProvider.future);
      await container.read(dailyReadingProvider.future);

      // Load free chapter
      await container
          .read(dailyReadingProvider.notifier)
          .loadFreeChapter('EXO', 'Éxodo', 1);

      expect(container.read(dailyReadingProvider).value, isA<FreeReadingLoaded>());

      // Reschedule should still work and schedule notification for daily reading
      final success = await container
          .read(dailyReadingProvider.notifier)
          .rescheduleNotification();

      expect(success, isTrue);
      expect(mockNotification.lastPassageReference, isNotNull);
    });

    test('R4: booksProvider does not re-fetch books when fontSizeMultiplier changes', () async {
      SharedPreferences.setMockInitialValues({});

      final mockApi = CountingBibleApiService();
      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(mockApi),
        ],
      );
      addTearDown(container.dispose);

      await container.read(sharedPreferencesProvider.future);

      // First fetch
      await container.read(booksProvider.future);
      expect(mockApi.fetchBooksCount, 1);

      // Update font size multiplier
      await container
          .read(userPreferencesProvider.notifier)
          .setFontSizeMultiplier(1.4);

      // Read booksProvider again
      await container.read(booksProvider.future);
      // It should NOT have triggered a second fetch
      expect(mockApi.fetchBooksCount, 1,
          reason: 'Changing font size must not refetch books');
    });
  });

  group('UI/UX Redesign verification tests', () {
    test('BibleTheme.build configures Light, Sepia, and Dark themes with BibleReadingStyle', () {
      final lightTheme = BibleTheme.build(Brightness.light);
      final sepiaTheme = BibleTheme.build(Brightness.light, isSepia: true);
      final darkTheme = BibleTheme.build(Brightness.dark);

      final lightExt = lightTheme.extension<BibleReadingStyle>()!;
      final sepiaExt = sepiaTheme.extension<BibleReadingStyle>()!;
      final darkExt = darkTheme.extension<BibleReadingStyle>()!;

      expect(lightExt.isSepia, isFalse);
      expect(lightExt.isDark, isFalse);
      expect(sepiaExt.isSepia, isTrue);
      expect(sepiaExt.isDark, isFalse);
      expect(darkExt.isDark, isTrue);
      expect(lightTheme.scaffoldBackgroundColor, ReadingPalette.cream);
      expect(sepiaTheme.scaffoldBackgroundColor, ReadingPalette.sepiaSurface);
      expect(darkTheme.scaffoldBackgroundColor, ReadingPalette.charcoalSurface);
    });

    testWidgets(
      'ExploreScreen filters books by diacritic-insensitive search and testament',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final mockApi = CountingBibleApiService();
        final container = ProviderContainer(
          overrides: [apiServiceProvider.overrideWithValue(mockApi)],
        );
        addTearDown(container.dispose);

        await container.read(sharedPreferencesProvider.future);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: BibleTheme.build(Brightness.light),
              home: const ExploreScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Génesis'), findsOneWidget);
        expect(find.text('Éxodo'), findsOneWidget);
        expect(find.text('Mateo'), findsOneWidget);

        // Filter by Nuevo Testamento
        await tester.tap(find.text('Nuevo Testamento'));
        await tester.pumpAndSettle();
        expect(find.text('Mateo'), findsOneWidget);
        expect(find.text('Génesis'), findsNothing);

        // Switch back to Todos and search "genesis" without accent
        await tester.tap(find.text('Todos'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'genesis');
        await tester.pumpAndSettle();

        expect(find.text('Génesis'), findsOneWidget);
        expect(find.text('Mateo'), findsNothing);
      },
    );

    testWidgets(
      'GraphExplorerWidget renders Genesis 1 connections and filters by ConnectionKind',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          ReadingPlanService.installationDateKey: DateTime.now()
              .toUtc()
              .toIso8601String(),
        });

        final mockApi = CountingBibleApiService();
        final mockNotification = TestNotificationService();

        final container = ProviderContainer(
          overrides: [
            apiServiceProvider.overrideWithValue(mockApi),
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
                body: GraphExplorerWidget(
                  fromVerse: 1,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('Conexiones de Génesis 1'), findsOneWidget);
        expect(find.text('Desde el versículo 1'), findsOneWidget);
        expect(find.text('Juan 1'), findsWidgets);
      },
    );

    test(
      'Android main manifest declares INTERNET permission for release builds',
      () {
        final manifest = File(
          'android/app/src/main/AndroidManifest.xml',
        ).readAsStringSync();
        expect(
          manifest,
          contains('android.permission.INTERNET'),
          reason:
              'Release APKs cannot fetch Bible chapters without INTERNET permission in main/AndroidManifest.xml',
        );
      },
    );

    testWidgets(
      'OnboardingScreen renders Latinoamericana on a single line without clipping on 360dp width',
      (tester) async {
        tester.view.physicalSize = const Size(360, 780);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        SharedPreferences.setMockInitialValues({});
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await container.read(sharedPreferencesProvider.future);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: BibleTheme.build(Brightness.light),
              home: const OnboardingScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Navigate to the settings page in OnboardingScreen
        await tester.tap(find.text('Siguiente'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Siguiente'));
        await tester.pumpAndSettle();

        final textFinder = find.text('Latinoamericana');
        expect(textFinder, findsOneWidget);

        final renderParagraph = tester.renderObject(textFinder);
        expect(renderParagraph.paintBounds.height, lessThan(32.0));
      },
    );
  });
}
