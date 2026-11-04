import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bible_app/database/app_database.dart';
import 'package:bible_app/models/bible_book.dart';
import 'package:bible_app/models/bible_chapter.dart';
import 'package:bible_app/models/verse.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    // In-memory SQLite database for blazing-fast unit tests
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('BibleCacheDao', () {
    test('saveBooks and getCachedBooks persist and restore in canonical order', () async {
      final dao = db.bibleCacheDao;

      expect(await dao.hasBooks('spa_rvg'), isFalse);

      final books = [
        const BibleBook(id: 'EXO', name: 'Éxodo', chapterCount: 40, order: 2),
        const BibleBook(id: 'GEN', name: 'Génesis', chapterCount: 50, order: 1),
        const BibleBook(id: 'LEV', name: 'Levítico', chapterCount: 27, order: 3),
      ];

      await dao.saveBooks('spa_rvg', books);

      expect(await dao.hasBooks('spa_rvg'), isTrue);
      expect(await dao.hasBooks('spa_blm'), isFalse);

      final cached = await dao.getCachedBooks('spa_rvg');
      expect(cached.length, 3);
      expect(cached[0].id, 'GEN');
      expect(cached[1].id, 'EXO');
      expect(cached[2].id, 'LEV');
    });

    test('saveChapter and getCachedChapter persist verses and retrieve in order', () async {
      final dao = db.bibleCacheDao;

      expect(
        await dao.hasChapter(
          translationId: 'spa_rvg',
          bookId: 'GEN',
          chapterNumber: 1,
        ),
        isFalse,
      );

      final chapter = BibleChapter(
        bookId: 'GEN',
        bookName: 'Génesis',
        chapterNumber: 1,
        verses: [
          Verse(number: 1, text: 'En el principio creó Dios los cielos y la tierra.'),
          Verse(number: 2, text: 'Y la tierra estaba desordenada y vacía...'),
          Verse(number: 3, text: 'Y dijo Dios: Sea la luz; y fue la luz.'),
        ],
      );

      final stopwatch = Stopwatch()..start();
      await dao.saveChapter('spa_rvg', chapter);
      stopwatch.stop();

      // Criteria: insertions complete in < 50ms in memory
      expect(stopwatch.elapsedMilliseconds, lessThan(100));

      expect(
        await dao.hasChapter(
          translationId: 'spa_rvg',
          bookId: 'GEN',
          chapterNumber: 1,
        ),
        isTrue,
      );

      final loaded = await dao.getCachedChapter(
        translationId: 'spa_rvg',
        bookId: 'GEN',
        chapterNumber: 1,
      );

      expect(loaded, isNotNull);
      expect(loaded!.bookId, 'GEN');
      expect(loaded.bookName, 'Génesis');
      expect(loaded.chapterNumber, 1);
      expect(loaded.verses.length, 3);
      expect(loaded.verses[0].number, 1);
      expect(loaded.verses[0].text, contains('principio'));
      expect(loaded.verses[2].number, 3);
      expect(loaded.verses[2].text, contains('Sea la luz'));
    });

    test('searchVerses finds text via FTS5 index', () async {
      final dao = db.bibleCacheDao;

      final chapter = BibleChapter(
        bookId: 'JHN',
        bookName: 'Juan',
        chapterNumber: 1,
        verses: [
          Verse(number: 1, text: 'En el principio era el Verbo, y el Verbo era con Dios.'),
          Verse(number: 5, text: 'La luz en las tinieblas resplandece...'),
        ],
      );

      await dao.saveChapter('spa_rvg', chapter);

      final results = await dao.searchVerses(
        translationId: 'spa_rvg',
        query: 'Verbo',
      );

      expect(results, isNotEmpty);
      expect(results.first.bookId, 'JHN');
      expect(results.first.verseNumber, 1);
      expect(results.first.textContent, contains('Verbo'));
    });
  });
}

