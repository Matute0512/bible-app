import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/daos/study_dao.dart';
import '../models/verse_annotation.dart';
import '../repositories/study_repository.dart';
import 'database_provider.dart';

/// Provider for [StudyDao].
final studyDaoProvider = Provider<StudyDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.studyDao;
});

/// Provider for [StudyRepository].
final studyRepositoryProvider = Provider<StudyRepository>((ref) {
  final dao = ref.watch(studyDaoProvider);
  return StudyRepository(studyDao: dao);
});

/// Reactive stream of annotations for a chapter, mapped by verse number.
final chapterAnnotationsProvider = StreamProvider.family<
    Map<int, VerseAnnotation>, ({String bookId, int chapterNumber})>(
  (ref, arg) {
    final repo = ref.watch(studyRepositoryProvider);
    return repo.watchAnnotationsForChapter(
      bookId: arg.bookId,
      chapterNumber: arg.chapterNumber,
    );
  },
);

/// Reactive stream of all favorite verses.
final allFavoritesProvider = StreamProvider<List<VerseAnnotation>>((ref) {
  final repo = ref.watch(studyRepositoryProvider);
  return repo.watchAllFavorites();
});

/// Reactive stream of all study notes.
final allNotesProvider = StreamProvider<List<VerseAnnotation>>((ref) {
  final repo = ref.watch(studyRepositoryProvider);
  return repo.watchAllNotes();
});

/// Reactive stream of all highlights, optionally filtered by color.
final highlightsProvider =
    StreamProvider.family<List<VerseAnnotation>, String?>((ref, color) {
  final repo = ref.watch(studyRepositoryProvider);
  return repo.watchHighlights(color: color);
});
