import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bible_app/database/app_database.dart';
import 'package:bible_app/models/bible_book.dart';
import 'package:bible_app/models/bible_chapter.dart';
import 'package:bible_app/models/verse.dart';
import 'package:bible_app/providers/app_providers.dart';
import 'package:bible_app/repositories/bible_repository.dart';
import 'package:bible_app/repositories/study_repository.dart';
import 'package:bible_app/screens/saved_screen.dart';
import 'package:bible_app/screens/search_screen.dart';
import 'package:bible_app/services/bible_api_service.dart';
import 'package:bible_app/services/reading_plan_service.dart';
import 'package:bible_app/theme/bible_theme.dart';

class MockApi implements BibleApiService {
  @override
  Future<List<BibleBook>> fetchBooks(String translationId) async => [
        const BibleBook(id: 'GEN', name: 'Génesis', order: 1, chapterCount: 50),
        const BibleBook(id: 'JHN', name: 'Juan', order: 43, chapterCount: 21),
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
        ],
      );

  @override
  Future<Map<String, dynamic>> fetchCompleteTranslationSimple(
    String translationId,
  ) async =>
      {};
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  group('SearchScreen & SavedScreen UI Tests', () {
    late AppDatabase db;
    late BibleRepository bibleRepo;
    late StudyRepository studyRepo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      bibleRepo = BibleRepository(api: MockApi(), cache: db.bibleCacheDao);
      studyRepo = StudyRepository(studyDao: db.studyDao);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('SearchScreen renders input, debounces search and highlights results',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        ReadingPlanService.installationDateKey: DateTime.now().toUtc().toIso8601String(),
        'translation': 'evangelical',
      });

      // Populate test chapters in cache
      await db.bibleCacheDao.saveChapter(
        'spa_rvg',
        const BibleChapter(
          bookId: 'GEN',
          bookName: 'Génesis',
          chapterNumber: 1,
          verses: [
            Verse(number: 1, text: 'En el principio creó Dios los cielos y la tierra.'),
          ],
        ),
      );
      await db.bibleCacheDao.saveChapter(
        'spa_rvg',
        const BibleChapter(
          bookId: 'JHN',
          bookName: 'Juan',
          chapterNumber: 3,
          verses: [
            Verse(number: 16, text: 'Porque de tal manera amó Dios al mundo.'),
          ],
        ),
      );

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          bibleRepositoryProvider.overrideWithValue(bibleRepo),
          studyRepositoryProvider.overrideWithValue(studyRepo),
          apiServiceProvider.overrideWithValue(MockApi()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(sharedPreferencesProvider.future);
      await container.read(userPreferencesProvider.future);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: BibleTheme.build(Brightness.light),
            home: const SearchScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify search input and initial suggestions
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Búsqueda Global'), findsOneWidget);
      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('Antiguo Testamento'), findsOneWidget);
      expect(find.text('Nuevo Testamento'), findsOneWidget);

      // Enter search query
      await tester.enterText(find.byType(TextField), 'principio');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // Results displayed
      expect(find.text('Génesis 1:1'), findsOneWidget);
      expect(find.textContaining('versículo encontrado'), findsOneWidget);

      // Filter by Nuevo Testamento (GEN should disappear)
      await tester.tap(find.text('Nuevo Testamento'));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text('Génesis 1:1'), findsNothing);
      expect(find.textContaining('Sin resultados'), findsOneWidget);
    });

    testWidgets('SavedScreen renders tabs, displays favorites, highlights, and notes',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        ReadingPlanService.installationDateKey: DateTime.now().toUtc().toIso8601String(),
        'translation': 'evangelical',
      });

      // Insert annotations
      await studyRepo.toggleFavorite(
        bookId: 'GEN',
        chapterNumber: 1,
        verseNumber: 1,
        originTranslationId: 'spa_rvg',
        bookNameSnapshot: 'Génesis',
        verseTextSnapshot: 'En el principio creó Dios los cielos y la tierra.',
      );

      await studyRepo.setHighlight(
        bookId: 'GEN',
        chapterNumber: 1,
        verseNumber: 1,
        highlightColor: 'ochre',
        originTranslationId: 'spa_rvg',
        bookNameSnapshot: 'Génesis',
        verseTextSnapshot: 'En el principio creó Dios los cielos y la tierra.',
      );

      await studyRepo.saveNote(
        bookId: 'JHN',
        chapterNumber: 3,
        verseNumber: 16,
        noteText: 'El amor infinito de Dios hacia la humanidad.',
        tagsCsv: 'amor,gracia',
        originTranslationId: 'spa_rvg',
        bookNameSnapshot: 'Juan',
        verseTextSnapshot: 'Porque de tal manera amó Dios al mundo.',
      );

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          bibleRepositoryProvider.overrideWithValue(bibleRepo),
          studyRepositoryProvider.overrideWithValue(studyRepo),
          apiServiceProvider.overrideWithValue(MockApi()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(sharedPreferencesProvider.future);
      await container.read(userPreferencesProvider.future);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: BibleTheme.build(Brightness.light),
            home: const SavedScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify "Todos" tab has items
      expect(find.text('Guardados y Estudio'), findsOneWidget);
      expect(find.text('Génesis 1:1'), findsOneWidget);
      expect(find.text('Juan 3:16'), findsOneWidget);
      expect(find.text('El amor infinito de Dios hacia la humanidad.'), findsOneWidget);
      expect(find.text('#amor'), findsOneWidget);

      // Switch to "Favoritos" tab
      await tester.tap(find.text('Favoritos'));
      await tester.pumpAndSettle();
      expect(find.text('Génesis 1:1'), findsOneWidget);
      // Juan 3:16 is not favorite, so it should not appear in Favoritos
      expect(find.text('Juan 3:16'), findsNothing);

      // Switch to "Resaltados" tab
      await tester.tap(find.text('Resaltados'));
      await tester.pumpAndSettle();
      expect(find.text('Génesis 1:1'), findsOneWidget);

      // Switch to "Notas" tab
      await tester.tap(find.text('Notas'));
      await tester.pumpAndSettle();
      expect(find.text('Juan 3:16'), findsOneWidget);
      expect(find.text('El amor infinito de Dios hacia la humanidad.'), findsOneWidget);
    });
  });
}

