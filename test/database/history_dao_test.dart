import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bible_app/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('HistoryDao', () {
    test('markChapterRead inserts history and sets last_read marker', () async {
      final dao = db.historyDao;

      expect(
        await dao.isChapterRead(
          bookId: 'GEN',
          chapterNumber: 1,
          translationId: 'spa_rvg',
        ),
        isFalse,
      );

      final now = DateTime(2026, 11, 4, 10, 0);
      await dao.markChapterRead(
        bookId: 'GEN',
        chapterNumber: 1,
        translationId: 'spa_rvg',
        readDate: now,
      );

      expect(
        await dao.isChapterRead(
          bookId: 'GEN',
          chapterNumber: 1,
          translationId: 'spa_rvg',
        ),
        isTrue,
      );

      final lastRead = await dao.getLastRead();
      expect(lastRead, isNotNull);
      expect(lastRead!.bookId, 'GEN');
      expect(lastRead.chapterNumber, 1);
      expect(lastRead.translationId, 'spa_rvg');
    });

    test('unmarkChapterRead removes history records', () async {
      final dao = db.historyDao;

      await dao.markChapterRead(
        bookId: 'EXO',
        chapterNumber: 20,
        translationId: 'spa_rvg',
      );
      expect(
        await dao.isChapterRead(
          bookId: 'EXO',
          chapterNumber: 20,
          translationId: 'spa_rvg',
        ),
        isTrue,
      );

      await dao.unmarkChapterRead(
        bookId: 'EXO',
        chapterNumber: 20,
        translationId: 'spa_rvg',
      );
      expect(
        await dao.isChapterRead(
          bookId: 'EXO',
          chapterNumber: 20,
          translationId: 'spa_rvg',
        ),
        isFalse,
      );
    });

    test('getUniqueReadChaptersCount counts distinct chapters only', () async {
      final dao = db.historyDao;

      // Read GEN 1 twice on different days
      await dao.markChapterRead(
        bookId: 'GEN',
        chapterNumber: 1,
        translationId: 'spa_rvg',
        readDate: DateTime(2026, 11, 1),
      );
      await dao.markChapterRead(
        bookId: 'GEN',
        chapterNumber: 1,
        translationId: 'spa_rvg',
        readDate: DateTime(2026, 11, 2),
      );

      // Read GEN 2 once
      await dao.markChapterRead(
        bookId: 'GEN',
        chapterNumber: 2,
        translationId: 'spa_rvg',
        readDate: DateTime(2026, 11, 2),
      );

      // Read MAT 1 in another translation
      await dao.markChapterRead(
        bookId: 'MAT',
        chapterNumber: 1,
        translationId: 'spa_blm',
        readDate: DateTime(2026, 11, 2),
      );

      final rvgCount = await dao.getUniqueReadChaptersCount('spa_rvg');
      expect(rvgCount, 2); // GEN 1 and GEN 2

      final blmCount = await dao.getUniqueReadChaptersCount('spa_blm');
      expect(blmCount, 1); // MAT 1

      final set = await dao.getReadChaptersSet('spa_rvg');
      expect(set, {'GEN:1', 'GEN:2'});
    });

    test('calculateCurrentStreak correctly counts consecutive days', () async {
      final dao = db.historyDao;
      final now = DateTime(2026, 11, 4, 14, 0);

      // Case 1: No readings -> streak 0
      expect(await dao.calculateCurrentStreak('spa_rvg', referenceNow: now), 0);

      // Case 2: Read today only -> streak 1
      await dao.markChapterRead(
        bookId: 'GEN',
        chapterNumber: 1,
        translationId: 'spa_rvg',
        readDate: DateTime(2026, 11, 4, 9, 0),
      );
      expect(await dao.calculateCurrentStreak('spa_rvg', referenceNow: now), 1);

      // Case 3: Read today and yesterday -> streak 2
      await dao.markChapterRead(
        bookId: 'GEN',
        chapterNumber: 2,
        translationId: 'spa_rvg',
        readDate: DateTime(2026, 11, 3, 20, 0),
      );
      expect(await dao.calculateCurrentStreak('spa_rvg', referenceNow: now), 2);

      // Case 4: Read today, yesterday, and 2 days ago -> streak 3
      await dao.markChapterRead(
        bookId: 'GEN',
        chapterNumber: 3,
        translationId: 'spa_rvg',
        readDate: DateTime(2026, 11, 2, 10, 0),
      );
      expect(await dao.calculateCurrentStreak('spa_rvg', referenceNow: now), 3);

      // Case 5: Tomorrow without read yet (grace period):
      // If reference date is 2026-11-05 (haven't read yet today, but read on 4th, 3rd, 2nd)
      final tomorrow = DateTime(2026, 11, 5, 8, 0);
      expect(await dao.calculateCurrentStreak('spa_rvg', referenceNow: tomorrow), 3);

      // Case 6: Missed day (reference date is 2026-11-06 without reading on 5th)
      final twoDaysLater = DateTime(2026, 11, 6, 8, 0);
      expect(await dao.calculateCurrentStreak('spa_rvg', referenceNow: twoDaysLater), 0);
    });
  });
}
