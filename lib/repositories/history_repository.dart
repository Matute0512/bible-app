import 'dart:async';

import '../database/daos/history_dao.dart';
import '../models/reading_progress.dart';

/// Repository for managing user reading history, streak calculation,
/// and canonical progress metrics.
class ReadingHistoryRepository {
  ReadingHistoryRepository({required this.historyDao});

  final HistoryDao historyDao;

  /// Total chapters in the Protestant Canon (Reina-Valera 1909: 66 books).
  static const int protestantCanonChapters = 1189;

  /// Total chapters in the Catholic Canon (Biblia Latinoamericana: 73 books).
  static const int catholicCanonChapters = 1326;

  /// Returns canonical chapters count based on [translationId].
  static int getTotalCanonChapters(String translationId) {
    if (translationId.toLowerCase().contains('blm')) {
      return catholicCanonChapters;
    }
    return protestantCanonChapters;
  }

  /// Marks [chapterNumber] of [bookId] as read.
  Future<void> markChapterAsRead({
    required String bookId,
    required int chapterNumber,
    required String translationId,
    DateTime? readDate,
    String source = 'daily_plan',
    String? planId,
    int durationSeconds = 0,
  }) {
    return historyDao.markChapterRead(
      bookId: bookId,
      chapterNumber: chapterNumber,
      translationId: translationId,
      readDate: readDate,
      source: source,
      planId: planId,
      durationSeconds: durationSeconds,
    );
  }

  /// Unmarks [chapterNumber] of [bookId] as read.
  Future<void> unmarkChapterAsRead({
    required String bookId,
    required int chapterNumber,
    required String translationId,
  }) {
    return historyDao.unmarkChapterRead(
      bookId: bookId,
      chapterNumber: chapterNumber,
      translationId: translationId,
    );
  }

  /// Checks if a chapter has been read.
  Future<bool> isChapterRead({
    required String bookId,
    required int chapterNumber,
    required String translationId,
  }) {
    return historyDao.isChapterRead(
      bookId: bookId,
      chapterNumber: chapterNumber,
      translationId: translationId,
    );
  }

  /// Watches if a chapter has been read.
  Stream<bool> watchIsChapterRead({
    required String bookId,
    required int chapterNumber,
    required String translationId,
  }) {
    return historyDao.watchIsChapterRead(
      bookId: bookId,
      chapterNumber: chapterNumber,
      translationId: translationId,
    );
  }

  /// Gets current reading progress metrics.
  Future<ReadingProgress> getReadingProgress(String translationId) async {
    final readCount = await historyDao.getUniqueReadChaptersCount(translationId);
    final streak = await historyDao.calculateCurrentStreak(translationId);
    final lastReadData = await historyDao.getLastRead();

    LastReadTarget? lastTarget;
    if (lastReadData != null) {
      lastTarget = LastReadTarget(
        bookId: lastReadData.bookId,
        chapterNumber: lastReadData.chapterNumber,
        translationId: lastReadData.translationId,
        updatedAt: DateTime.fromMillisecondsSinceEpoch(lastReadData.updatedAtMs),
      );
    }

    final totalCanon = getTotalCanonChapters(translationId);

    return ReadingProgress(
      readChaptersCount: readCount,
      totalCanonChapters: totalCanon,
      currentStreakDays: streak,
      lastRead: lastTarget,
    );
  }

  /// Watches reading progress metrics reactively.
  Stream<ReadingProgress> watchReadingProgress(String translationId) {
    // Watches changes to reading history and emits updated ReadingProgress
    return historyDao.watchReadChaptersSet(translationId).asyncMap(
      (_) => getReadingProgress(translationId),
    );
  }

  /// Returns read chapter keys (e.g. 'GEN:1').
  Future<Set<String>> getReadChapters(String translationId) {
    return historyDao.getReadChaptersSet(translationId);
  }

  /// Watches read chapter keys reactively.
  Stream<Set<String>> watchReadChapters(String translationId) {
    return historyDao.watchReadChaptersSet(translationId);
  }
}
