import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bible_app/models/bible_book.dart';
import 'package:bible_app/models/bible_chapter.dart';
import 'package:bible_app/models/verse.dart';
import 'package:bible_app/providers/app_providers.dart';
import 'package:bible_app/screens/dashboard_screen.dart';
import 'package:bible_app/screens/reading_screen.dart';
import 'package:bible_app/services/bible_api_service.dart';
import 'package:bible_app/services/notification_service.dart';
import 'package:bible_app/services/reading_plan_service.dart';
import 'package:bible_app/theme/bible_theme.dart';

class MockApi implements BibleApiService {
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
  }) async =>
      BibleChapter(
        bookId: bookId,
        bookName: bookName,
        chapterNumber: chapterNumber,
        verses: [const Verse(number: 1, text: 'En el principio creó Dios los cielos y la tierra.')],
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
  }) async =>
      true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  group('Reading Progress and Streak UI tests', () {
    testWidgets('DashboardScreen displays streak and verified canonical progress', (tester) async {
      SharedPreferences.setMockInitialValues({
        ReadingPlanService.installationDateKey: DateTime.now().toUtc().toIso8601String(),
        'pref_translation_id': 'spa_rvg',
      });

      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(MockApi()),
          notificationServiceProvider.overrideWithValue(MockNotification()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(sharedPreferencesProvider.future);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: BibleTheme.build(Brightness.light),
            home: const DashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify streak and progress labels are rendered
      expect(find.text('Racha de lectura'), findsOneWidget);
      expect(find.text('Biblia leída'), findsOneWidget);
      expect(find.text('Progreso verificado'), findsOneWidget);
      expect(find.text('0 de 1189 capítulos'), findsOneWidget);
      expect(find.text('0.0%'), findsOneWidget);
    });

    testWidgets('ReadingScreen renders ChapterCompletionCard and marks chapter as read', (tester) async {
      SharedPreferences.setMockInitialValues({
        ReadingPlanService.installationDateKey: DateTime.now().toUtc().toIso8601String(),
        'pref_translation_id': 'spa_rvg',
      });

      final container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(MockApi()),
          notificationServiceProvider.overrideWithValue(MockNotification()),
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
      await tester.pumpAndSettle();

      // Expect ChapterCompletionCard at end of chapter
      expect(find.byType(ChapterCompletionCard), findsOneWidget);
      expect(find.text('¿Terminaste de leer?'), findsOneWidget);
      expect(find.text('Marcar como leído'), findsOneWidget);

      // Tap "Marcar como leído"
      await tester.tap(find.text('Marcar como leído'));
      await tester.pumpAndSettle();

      // Verify completion state
      expect(find.text('Capítulo completado'), findsOneWidget);
      expect(find.text('Leído'), findsOneWidget);
      expect(find.text('Desmarcar'), findsOneWidget);

      // Verify repository recorded it
      final isRead = await container.read(readingHistoryRepositoryProvider).isChapterRead(
            bookId: 'GEN',
            chapterNumber: 1,
            translationId: 'spa_rvg',
          );
      expect(isRead, isTrue);
    });
  });
}
