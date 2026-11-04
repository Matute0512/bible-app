import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/reading_progress.dart';
import '../repositories/history_repository.dart';
import 'database_provider.dart';
import 'user_preferences_provider.dart';

/// Provider for [ReadingHistoryRepository].
final readingHistoryRepositoryProvider =
    Provider<ReadingHistoryRepository>((ref) {
  final dao = ref.watch(historyDaoProvider);
  return ReadingHistoryRepository(historyDao: dao);
});

/// Reactive stream of user reading progress and streak metrics.
final readingProgressProvider = StreamProvider<ReadingProgress>((ref) async* {
  final translationId = await ref.watch(
    userPreferencesProvider.selectAsync((s) => s.translationId),
  );
  final repo = ref.watch(readingHistoryRepositoryProvider);
  yield* repo.watchReadingProgress(translationId);
});

/// Reactive stream to check if a specific chapter has been read.
final isChapterReadProvider =
    StreamProvider.family<bool, ({String bookId, int chapterNumber})>(
  (ref, arg) async* {
    final translationId = await ref.watch(
      userPreferencesProvider.selectAsync((s) => s.translationId),
    );
    final repo = ref.watch(readingHistoryRepositoryProvider);
    yield* repo.watchIsChapterRead(
      bookId: arg.bookId,
      chapterNumber: arg.chapterNumber,
      translationId: translationId,
    );
  },
);
