import 'package:flutter/foundation.dart';

/// Represents the user's last read position.
@immutable
class LastReadTarget {
  const LastReadTarget({
    required this.bookId,
    required this.chapterNumber,
    required this.translationId,
    required this.updatedAt,
  });

  final String bookId;
  final int chapterNumber;
  final String translationId;
  final DateTime updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LastReadTarget &&
          runtimeType == other.runtimeType &&
          bookId == other.bookId &&
          chapterNumber == other.chapterNumber &&
          translationId == other.translationId;

  @override
  int get hashCode =>
      bookId.hashCode ^ chapterNumber.hashCode ^ translationId.hashCode;

  @override
  String toString() =>
      'LastReadTarget(book: $bookId, chapter: $chapterNumber, translation: $translationId)';
}

/// Aggregated user reading progress and streak calculation.
@immutable
class ReadingProgress {
  const ReadingProgress({
    required this.readChaptersCount,
    required this.totalCanonChapters,
    required this.currentStreakDays,
    this.lastRead,
  });

  /// Total unique chapters read by the user in this translation/canon.
  final int readChaptersCount;

  /// Total canonical chapters for this translation (1,189 for RVG, 1,326 for BLM).
  final int totalCanonChapters;

  /// Reading streak in consecutive days.
  final int currentStreakDays;

  /// Last read passage marker (if any).
  final LastReadTarget? lastRead;

  /// Progress fraction from 0.0 to 1.0.
  double get progressFraction => totalCanonChapters == 0
      ? 0.0
      : (readChaptersCount / totalCanonChapters).clamp(0.0, 1.0);

  /// Progress percentage formatted to 1 decimal place (e.g. 3.5).
  double get progressPercentage => (progressFraction * 100.0);

  /// Human-readable percentage string (e.g. "3.5%").
  String get formattedPercentage => '${progressPercentage.toStringAsFixed(1)}%';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingProgress &&
          runtimeType == other.runtimeType &&
          readChaptersCount == other.readChaptersCount &&
          totalCanonChapters == other.totalCanonChapters &&
          currentStreakDays == other.currentStreakDays &&
          lastRead == other.lastRead;

  @override
  int get hashCode =>
      readChaptersCount.hashCode ^
      totalCanonChapters.hashCode ^
      currentStreakDays.hashCode ^
      lastRead.hashCode;

  @override
  String toString() =>
      'ReadingProgress($readChaptersCount/$totalCanonChapters ($formattedPercentage), streak: $currentStreakDays, last: $lastRead)';
}
