import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bible_app/database/app_database.dart';
import 'package:bible_app/models/bible_book.dart';
import 'package:bible_app/models/bible_chapter.dart';
import 'package:bible_app/models/verse.dart';
import 'package:bible_app/repositories/bible_repository.dart';
import 'package:bible_app/services/bible_api_service.dart';

class MockCountingApi implements BibleApiService {
  int fetchBooksCalls = 0;
  int fetchChapterCalls = 0;
  bool throwNetworkError = false;

  final books = [
    const BibleBook(id: 'GEN', name: 'Génesis', chapterCount: 50, order: 1),
    const BibleBook(id: 'EXO', name: 'Éxodo', chapterCount: 40, order: 2),
    const BibleBook(id: 'REV', name: 'Apocalipsis', chapterCount: 22, order: 66),
  ];

  @override
  Future<List<BibleBook>> fetchBooks(String translationId) async {
    fetchBooksCalls++;
    if (throwNetworkError) {
      throw const SocketException('No internet');
    }
    return books;
  }

  @override
  Future<BibleChapter> fetchChapter({
    required String translationId,
    required String bookId,
    required String bookName,
    required int chapterNumber,
  }) async {
    fetchChapterCalls++;
    if (throwNetworkError) {
      throw const SocketException('No internet');
    }
    return BibleChapter(
      bookId: bookId,
      bookName: bookName,
      chapterNumber: chapterNumber,
      verses: [
        Verse(number: 1, text: 'En el principio... ($bookId $chapterNumber:1)'),
      ],
    );
  }

  @override
  Future<Map<String, dynamic>> fetchCompleteTranslationSimple(
    String translationId,
  ) async => {};
}

void main() {
  late AppDatabase db;
  late MockCountingApi api;
  late BibleRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    api = MockCountingApi();
    repository = BibleRepository(api: api, cache: db.bibleCacheDao);
  });

  tearDown(() async {
    await db.close();
  });

  group('BibleRepository Offline-First caching', () {
    test('fetches chapter from API on first call and caches it in SQLite', () async {
      expect(api.fetchChapterCalls, 0);

      final chapter1 = await repository.getChapter(
        translationId: 'spa_rvg',
        bookId: 'GEN',
        bookName: 'Génesis',
        chapterNumber: 1,
      );

      expect(api.fetchChapterCalls, 1);
      expect(chapter1.reference, 'Génesis 1');

      // Second call must be served from cache without calling the API
      final chapter2 = await repository.getChapter(
        translationId: 'spa_rvg',
        bookId: 'GEN',
        bookName: 'Génesis',
        chapterNumber: 1,
      );

      expect(api.fetchChapterCalls, 1);
      expect(chapter2.reference, 'Génesis 1');
      expect(chapter2.verses.first.text, contains('GEN 1:1'));
    });

    test('serves cached chapter when offline / network error occurs', () async {
      // Pre-cache chapter while online
      await repository.getChapter(
        translationId: 'spa_rvg',
        bookId: 'EXO',
        bookName: 'Éxodo',
        chapterNumber: 20,
      );
      expect(api.fetchChapterCalls, 1);

      // Simulate internet disconnection
      api.throwNetworkError = true;

      // Must succeed from SQLite cache
      final cachedChapter = await repository.getChapter(
        translationId: 'spa_rvg',
        bookId: 'EXO',
        bookName: 'Éxodo',
        chapterNumber: 20,
      );

      expect(cachedChapter.reference, 'Éxodo 20');
      expect(api.fetchChapterCalls, 1); // No new network call attempted
    });

    test('throws network exception if offline and chapter is not cached', () async {
      api.throwNetworkError = true;

      expect(
        () => repository.getChapter(
          translationId: 'spa_rvg',
          bookId: 'LEV',
          bookName: 'Levítico',
          chapterNumber: 1,
        ),
        throwsA(isA<SocketException>()),
      );
    });

    test('deduplicates simultaneous in-flight network requests for the same chapter', () async {
      // Fire 3 simultaneous requests for the same chapter
      final futures = Future.wait([
        repository.getChapter(
          translationId: 'spa_rvg',
          bookId: 'GEN',
          bookName: 'Génesis',
          chapterNumber: 3,
        ),
        repository.getChapter(
          translationId: 'spa_rvg',
          bookId: 'GEN',
          bookName: 'Génesis',
          chapterNumber: 3,
        ),
        repository.getChapter(
          translationId: 'spa_rvg',
          bookId: 'GEN',
          bookName: 'Génesis',
          chapterNumber: 3,
        ),
      ]);

      final results = await futures;
      expect(api.fetchChapterCalls, 1);
      expect(results.length, 3);
      expect(results.every((c) => c.reference == 'Génesis 3'), isTrue);
    });

    test('caches books list and serves from cache on subsequent calls', () async {
      final books1 = await repository.getBooks('spa_rvg');
      expect(api.fetchBooksCalls, 1);
      expect(books1.length, 3);

      final books2 = await repository.getBooks('spa_rvg');
      expect(api.fetchBooksCalls, 1);
      expect(books2.length, 3);
    });
  });

  group('BibleRepository Sequential Navigation in Free Reading', () {
    test('advances to next chapter in same book', () async {
      final next = await repository.resolveNextChapter(
        translationId: 'spa_rvg',
        currentBookId: 'GEN',
        currentChapter: 1,
      );

      expect(next.bookId, 'GEN');
      expect(next.bookName, 'Génesis');
      expect(next.chapterNumber, 2);
    });

    test('advances to chapter 1 of next book when current book is completed', () async {
      // GEN has 50 chapters; next is EXO 1
      final next = await repository.resolveNextChapter(
        translationId: 'spa_rvg',
        currentBookId: 'GEN',
        currentChapter: 50,
      );

      expect(next.bookId, 'EXO');
      expect(next.bookName, 'Éxodo');
      expect(next.chapterNumber, 1);
    });

    test('wraps around to first book when advancing past last book', () async {
      // REV has 22 chapters; next is GEN 1
      final next = await repository.resolveNextChapter(
        translationId: 'spa_rvg',
        currentBookId: 'REV',
        currentChapter: 22,
      );

      expect(next.bookId, 'GEN');
      expect(next.bookName, 'Génesis');
      expect(next.chapterNumber, 1);
    });

    test('goes to previous chapter in same book', () async {
      final prev = await repository.resolvePreviousChapter(
        translationId: 'spa_rvg',
        currentBookId: 'GEN',
        currentChapter: 2,
      );

      expect(prev.bookId, 'GEN');
      expect(prev.bookName, 'Génesis');
      expect(prev.chapterNumber, 1);
    });

    test('goes to last chapter of previous book when going back from chapter 1', () async {
      // Previous to EXO 1 is GEN 50
      final prev = await repository.resolvePreviousChapter(
        translationId: 'spa_rvg',
        currentBookId: 'EXO',
        currentChapter: 1,
      );

      expect(prev.bookId, 'GEN');
      expect(prev.bookName, 'Génesis');
      expect(prev.chapterNumber, 50);
    });
  });
}
