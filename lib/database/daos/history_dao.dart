import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/reading_history_table.dart';
import '../tables/reading_progress_table.dart';

part 'history_dao.g.dart';

@DriftAccessor(tables: [ReadingHistory, ReadingProgressState])
class HistoryDao extends DatabaseAccessor<AppDatabase> with _$HistoryDaoMixin {
  HistoryDao(super.db);

  /// Formats date to YYYY-MM-DD
  static String formatIsoDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Marks a chapter as read, recording history and updating 'last_read'.
  Future<void> markChapterRead({
    required String bookId,
    required int chapterNumber,
    required String translationId,
    DateTime? readDate,
    String source = 'daily_plan',
    String? planId,
    int durationSeconds = 0,
  }) async {
    final now = DateTime.now();
    final date = readDate ?? now;
    final dateIso = formatIsoDate(date);

    await transaction(() async {
      // 1. Insert history log
      await into(readingHistory).insert(
        ReadingHistoryCompanion.insert(
          bookId: bookId,
          chapterNumber: chapterNumber,
          translationId: translationId,
          readingDateIso: dateIso,
          readAtMs: date.millisecondsSinceEpoch,
          durationSeconds: Value(durationSeconds),
          source: Value(source),
          planId: Value(planId),
        ),
      );

      // 2. Upsert 'last_read' state marker
      await into(readingProgressState).insertOnConflictUpdate(
        ReadingProgressStateCompanion.insert(
          key: 'last_read',
          translationId: translationId,
          bookId: bookId,
          chapterNumber: chapterNumber,
          verseScrollOffset: const Value(0),
          updatedAtMs: now.millisecondsSinceEpoch,
        ),
      );
    });
  }

  /// Removes reading history records for a specific chapter.
  Future<void> unmarkChapterRead({
    required String bookId,
    required int chapterNumber,
    required String translationId,
  }) async {
    await (delete(readingHistory)
          ..where(
            (tbl) =>
                tbl.bookId.equals(bookId) &
                tbl.chapterNumber.equals(chapterNumber) &
                tbl.translationId.equals(translationId),
          ))
        .go();
  }

  /// Checks if a chapter has been marked as read at least once.
  Future<bool> isChapterRead({
    required String bookId,
    required int chapterNumber,
    required String translationId,
  }) async {
    final query = select(readingHistory)
      ..where(
        (tbl) =>
            tbl.bookId.equals(bookId) &
            tbl.chapterNumber.equals(chapterNumber) &
            tbl.translationId.equals(translationId),
      )
      ..limit(1);
    final result = await query.getSingleOrNull();
    return result != null;
  }

  /// Watches if a chapter has been marked as read.
  Stream<bool> watchIsChapterRead({
    required String bookId,
    required int chapterNumber,
    required String translationId,
  }) {
    final query = select(readingHistory)
      ..where(
        (tbl) =>
            tbl.bookId.equals(bookId) &
            tbl.chapterNumber.equals(chapterNumber) &
            tbl.translationId.equals(translationId),
      )
      ..limit(1);
    return query.watchSingleOrNull().map((entry) => entry != null);
  }

  /// Returns unique read chapters as a set of 'bookId:chapterNumber' strings.
  Future<Set<String>> getReadChaptersSet(String translationId) async {
    final query = selectOnly(readingHistory, distinct: true)
      ..addColumns([readingHistory.bookId, readingHistory.chapterNumber])
      ..where(readingHistory.translationId.equals(translationId));

    final rows = await query.get();
    return rows.map((row) {
      final bId = row.read(readingHistory.bookId)!;
      final chNum = row.read(readingHistory.chapterNumber)!;
      return '$bId:$chNum';
    }).toSet();
  }

  /// Watches unique read chapters as a set of 'bookId:chapterNumber' strings.
  Stream<Set<String>> watchReadChaptersSet(String translationId) {
    final query = selectOnly(readingHistory, distinct: true)
      ..addColumns([readingHistory.bookId, readingHistory.chapterNumber])
      ..where(readingHistory.translationId.equals(translationId));

    return query.watch().map((rows) {
      return rows.map((row) {
        final bId = row.read(readingHistory.bookId)!;
        final chNum = row.read(readingHistory.chapterNumber)!;
        return '$bId:$chNum';
      }).toSet();
    });
  }

  /// Returns count of unique chapters read for a translation.
  Future<int> getUniqueReadChaptersCount(String translationId) async {
    final chaptersSet = await getReadChaptersSet(translationId);
    return chaptersSet.length;
  }

  /// Watches count of unique chapters read for a translation.
  Stream<int> watchUniqueReadChaptersCount(String translationId) {
    return watchReadChaptersSet(translationId).map((set) => set.length);
  }

  /// Returns sorted unique reading dates (YYYY-MM-DD) descending.
  Future<List<String>> getDistinctReadingDates(String translationId) async {
    final query = selectOnly(readingHistory, distinct: true)
      ..addColumns([readingHistory.readingDateIso])
      ..where(readingHistory.translationId.equals(translationId))
      ..orderBy([OrderingTerm.desc(readingHistory.readingDateIso)]);

    final rows = await query.get();
    return rows
        .map((r) => r.read(readingHistory.readingDateIso)!)
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Calculates current reading streak in consecutive days.
  ///
  /// If read today, counts consecutive days backwards from today.
  /// If not read today but read yesterday, counts consecutive days backwards from yesterday (grace period).
  /// If neither today nor yesterday, streak is 0.
  Future<int> calculateCurrentStreak(String translationId, {DateTime? referenceNow}) async {
    final distinctDates = await getDistinctReadingDates(translationId);
    if (distinctDates.isEmpty) return 0;

    final datesSet = distinctDates.toSet();
    final now = referenceNow ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final todayIso = formatIsoDate(today);
    final yesterdayIso = formatIsoDate(yesterday);

    DateTime checkDate;
    if (datesSet.contains(todayIso)) {
      checkDate = today;
    } else if (datesSet.contains(yesterdayIso)) {
      checkDate = yesterday;
    } else {
      return 0;
    }

    int streak = 0;
    while (datesSet.contains(formatIsoDate(checkDate))) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Watches current streak in days.
  Stream<int> watchCurrentStreak(String translationId) {
    final query = selectOnly(readingHistory, distinct: true)
      ..addColumns([readingHistory.readingDateIso])
      ..where(readingHistory.translationId.equals(translationId));

    return query.watch().asyncMap((_) => calculateCurrentStreak(translationId));
  }

  /// Gets the latest 'last_read' entry.
  Future<ReadingProgressStateData?> getLastRead() async {
    final query = select(readingProgressState)
      ..where((tbl) => tbl.key.equals('last_read'))
      ..limit(1);
    return query.getSingleOrNull();
  }

  /// Watches the latest 'last_read' entry.
  Stream<ReadingProgressStateData?> watchLastRead() {
    final query = select(readingProgressState)
      ..where((tbl) => tbl.key.equals('last_read'))
      ..limit(1);
    return query.watchSingleOrNull();
  }
}
