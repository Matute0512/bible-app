import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bible_app/database/app_database.dart';
import 'package:bible_app/models/bible_book.dart';
import 'package:bible_app/models/bible_chapter.dart';
import 'package:bible_app/models/verse.dart';
import 'package:bible_app/repositories/bible_repository.dart';
import 'package:bible_app/services/bible_api_service.dart';

class FakeSearchApiService implements BibleApiService {
  @override
  Future<List<BibleBook>> fetchBooks(String translationId) async => [
        const BibleBook(id: 'GEN', name: 'Génesis', chapterCount: 50, order: 1),
        const BibleBook(id: 'JHN', name: 'Juan', chapterCount: 21, order: 43),
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
  ) async {
    return {
      'translation': {'id': translationId, 'name': 'Test Bible'},
      'books': [
        {
          'id': 'GEN',
          'name': 'Génesis',
          'chapters': [
            {
              'chapter': {
                'number': 1,
                'content': [
                  {
                    'type': 'verse',
                    'number': 1,
                    'text': 'En el principio creó Dios los cielos y la tierra.'
                  },
                  {
                    'type': 'verse',
                    'number': 2,
                    'text': 'Y la tierra estaba desordenada y vacía; y las tinieblas estaban sobre la faz del abismo.'
                  },
                ],
              },
            },
          ],
        },
        {
          'id': 'JHN',
          'name': 'Juan',
          'chapters': [
            {
              'chapter': {
                'number': 3,
                'content': [
                  {
                    'type': 'verse',
                    'number': 16,
                    'text': 'Porque de tal manera amó Dios al mundo, que ha dado a su Hijo unigénito.'
                  },
                ],
              },
            },
          ],
        },
      ],
    };
  }
}

void main() {
  late AppDatabase db;
  late FakeSearchApiService api;
  late BibleRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    api = FakeSearchApiService();
    repository = BibleRepository(api: api, cache: db.bibleCacheDao);
  });

  tearDown(() async {
    await db.close();
  });

  group('FTS5 Bible Search & Batch Download', () {
    test('downloadAndIndexCompleteTranslation downloads and indexes all verses', () async {
      final doubleProgress = <double>[];
      final count = await repository.downloadAndIndexCompleteTranslation(
        'spa_rvg',
        onProgress: (p, status) => doubleProgress.add(p),
      );

      expect(count, 2); // 2 chapters
      expect(doubleProgress.contains(1.0), isTrue);

      final cachedCount = await repository.getCachedChaptersCount('spa_rvg');
      expect(cachedCount, 2);
    });

    test('searchVerses finds term with exact matching', () async {
      await repository.downloadAndIndexCompleteTranslation('spa_rvg');

      final results = await repository.searchVerses(
        translationId: 'spa_rvg',
        query: 'principio',
      );

      expect(results, isNotEmpty);
      expect(results.first.bookId, 'GEN');
      expect(results.first.verseNumber, 1);
      expect(results.first.textContent, contains('En el principio'));
    });

    test('searchVerses is diacritic-insensitive (e.g. amo matches amó)', () async {
      await repository.downloadAndIndexCompleteTranslation('spa_rvg');

      // Query without accent: "amo" should match "amó"
      final results = await repository.searchVerses(
        translationId: 'spa_rvg',
        query: 'amo',
      );

      expect(results, isNotEmpty);
      expect(results.any((r) => r.bookId == 'JHN' && r.verseNumber == 16), isTrue);
    });

    test('searchVerses filters results by bookIds (testament filtering)', () async {
      await repository.downloadAndIndexCompleteTranslation('spa_rvg');

      // Both verses contain "Dios"
      final otOnly = await repository.searchVerses(
        translationId: 'spa_rvg',
        query: 'Dios',
        bookIds: {'GEN'},
      );

      expect(otOnly.every((r) => r.bookId == 'GEN'), isTrue);

      final ntOnly = await repository.searchVerses(
        translationId: 'spa_rvg',
        query: 'Dios',
        bookIds: {'JHN'},
      );

      expect(ntOnly.every((r) => r.bookId == 'JHN'), isTrue);
    });
  });
}
