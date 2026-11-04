import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bible_app/database/app_database.dart';
import 'package:bible_app/repositories/history_repository.dart';

void main() {
  late AppDatabase db;
  late ReadingHistoryRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = ReadingHistoryRepository(historyDao: db.historyDao);
  });

  tearDown(() async {
    await db.close();
  });

  group('ReadingHistoryRepository', () {
    test('getTotalCanonChapters returns 1189 for RVG and 1326 for BLM', () {
      expect(ReadingHistoryRepository.getTotalCanonChapters('spa_rvg'), 1189);
      expect(ReadingHistoryRepository.getTotalCanonChapters('spa_blm'), 1326);
    });

    test('getReadingProgress aggregates read count, percentage, streak and lastRead', () async {
      final initial = await repository.getReadingProgress('spa_rvg');
      expect(initial.readChaptersCount, 0);
      expect(initial.totalCanonChapters, 1189);
      expect(initial.progressFraction, 0.0);
      expect(initial.formattedPercentage, '0.0%');
      expect(initial.currentStreakDays, 0);
      expect(initial.lastRead, isNull);

      // Mark GEN 1 as read today
      final now = DateTime.now();
      await repository.markChapterAsRead(
        bookId: 'GEN',
        chapterNumber: 1,
        translationId: 'spa_rvg',
        readDate: now,
      );

      final progress = await repository.getReadingProgress('spa_rvg');
      expect(progress.readChaptersCount, 1);
      expect(progress.totalCanonChapters, 1189);
      expect(progress.progressFraction, closeTo(1 / 1189, 0.0001));
      expect(progress.currentStreakDays, 1);
      expect(progress.lastRead, isNotNull);
      expect(progress.lastRead!.bookId, 'GEN');
      expect(progress.lastRead!.chapterNumber, 1);
    });

    test('unmarkChapterAsRead decrements count and updates progress', () async {
      await repository.markChapterAsRead(
        bookId: 'GEN',
        chapterNumber: 1,
        translationId: 'spa_rvg',
      );
      expect(await repository.isChapterRead(bookId: 'GEN', chapterNumber: 1, translationId: 'spa_rvg'), isTrue);

      await repository.unmarkChapterAsRead(
        bookId: 'GEN',
        chapterNumber: 1,
        translationId: 'spa_rvg',
      );
      expect(await repository.isChapterRead(bookId: 'GEN', chapterNumber: 1, translationId: 'spa_rvg'), isFalse);

      final progress = await repository.getReadingProgress('spa_rvg');
      expect(progress.readChaptersCount, 0);
    });
  });
}
