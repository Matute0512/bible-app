import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bible_app/models/bible_book.dart';
import 'package:bible_app/models/bible_chapter.dart';
import 'package:bible_app/models/verse.dart';
import 'package:bible_app/providers/app_providers.dart';
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
        verses: [
          const Verse(number: 1, text: 'En el principio creó Dios los cielos y la tierra.'),
          const Verse(number: 2, text: 'Y la tierra estaba desordenada y vacía.'),
        ],
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

  group('Verse Interaction and Annotations UI tests', () {
    testWidgets('tapping a verse opens VerseActionSheet with highlight swatches and actions', (tester) async {
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

      // Find first verse text and tap it
      final verseFinder = find.text('En el principio creó Dios los cielos y la tierra.');
      expect(verseFinder, findsOneWidget);
      await tester.tap(verseFinder);
      await tester.pumpAndSettle();

      // VerseActionSheet is open
      expect(find.byType(VerseActionSheet), findsOneWidget);
      expect(find.text('Génesis 1:1'), findsOneWidget);
      expect(find.text('Resaltar:'), findsOneWidget);
      expect(find.text('Favorito'), findsOneWidget);
      expect(find.text('Nota'), findsOneWidget);
      expect(find.text('Copiar'), findsOneWidget);
      expect(find.text('Compartir'), findsOneWidget);

      // Toggle Favorite
      await tester.tap(find.text('Favorito'));
      await tester.pumpAndSettle();

      // Verify in repository
      final isFav = await container.read(studyRepositoryProvider).getAnnotation(
            bookId: 'GEN',
            chapterNumber: 1,
            verseNumber: 1,
          );
      expect(isFav, isNotNull);
      expect(isFav!.isFavorite, isTrue);

      // Close sheet
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Verify star icon is visible in VerseListItem
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });
  });
}

