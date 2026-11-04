import '../database/daos/study_dao.dart';
import '../models/verse_annotation.dart';

/// Repository managing user annotations: highlights, favorites, and study notes.
class StudyRepository {
  StudyRepository({required this.studyDao});

  final StudyDao studyDao;

  /// Inserts or updates a complete [VerseAnnotation].
  Future<void> upsertAnnotation(VerseAnnotation annotation) =>
      studyDao.upsertAnnotation(annotation);

  /// Toggles favorite status for [verseNumber] in [chapterNumber] of [bookId].
  Future<bool> toggleFavorite({
    required String bookId,
    required int chapterNumber,
    required int verseNumber,
    required String originTranslationId,
    required String bookNameSnapshot,
    required String verseTextSnapshot,
  }) {
    return studyDao.toggleFavorite(
      bookId: bookId,
      chapterNumber: chapterNumber,
      verseNumber: verseNumber,
      originTranslationId: originTranslationId,
      bookNameSnapshot: bookNameSnapshot,
      verseTextSnapshot: verseTextSnapshot,
    );
  }

  /// Sets or clears highlight color for [verseNumber] in [chapterNumber] of [bookId].
  Future<void> setHighlight({
    required String bookId,
    required int chapterNumber,
    required int verseNumber,
    required String? highlightColor,
    required String originTranslationId,
    required String bookNameSnapshot,
    required String verseTextSnapshot,
  }) {
    return studyDao.setHighlight(
      bookId: bookId,
      chapterNumber: chapterNumber,
      verseNumber: verseNumber,
      highlightColor: highlightColor,
      originTranslationId: originTranslationId,
      bookNameSnapshot: bookNameSnapshot,
      verseTextSnapshot: verseTextSnapshot,
    );
  }

  /// Saves or clears personal note for [verseNumber] in [chapterNumber] of [bookId].
  Future<void> saveNote({
    required String bookId,
    required int chapterNumber,
    required int verseNumber,
    required String? noteText,
    String? tagsCsv,
    required String originTranslationId,
    required String bookNameSnapshot,
    required String verseTextSnapshot,
  }) {
    return studyDao.saveNote(
      bookId: bookId,
      chapterNumber: chapterNumber,
      verseNumber: verseNumber,
      noteText: noteText,
      tagsCsv: tagsCsv,
      originTranslationId: originTranslationId,
      bookNameSnapshot: bookNameSnapshot,
      verseTextSnapshot: verseTextSnapshot,
    );
  }

  /// Deletes an annotation by ID (e.g. "GEN:1:1").
  Future<void> deleteAnnotation(String id) => studyDao.deleteAnnotation(id);

  /// Gets annotation for verse coordinate if present.
  Future<VerseAnnotation?> getAnnotation({
    required String bookId,
    required int chapterNumber,
    required int verseNumber,
  }) {
    return studyDao.getAnnotation(
      bookId: bookId,
      chapterNumber: chapterNumber,
      verseNumber: verseNumber,
    );
  }

  /// Watches annotation for verse coordinate reactively.
  Stream<VerseAnnotation?> watchAnnotation({
    required String bookId,
    required int chapterNumber,
    required int verseNumber,
  }) {
    return studyDao.watchAnnotation(
      bookId: bookId,
      chapterNumber: chapterNumber,
      verseNumber: verseNumber,
    );
  }

  /// Returns map of verseNumber -> VerseAnnotation for an entire chapter.
  Future<Map<int, VerseAnnotation>> getAnnotationsForChapter({
    required String bookId,
    required int chapterNumber,
  }) {
    return studyDao.getAnnotationsForChapter(
      bookId: bookId,
      chapterNumber: chapterNumber,
    );
  }

  /// Watches map of verseNumber -> VerseAnnotation for an entire chapter reactively.
  Stream<Map<int, VerseAnnotation>> watchAnnotationsForChapter({
    required String bookId,
    required int chapterNumber,
  }) {
    return studyDao.watchAnnotationsForChapter(
      bookId: bookId,
      chapterNumber: chapterNumber,
    );
  }

  /// Gets all saved annotations.
  Future<List<VerseAnnotation>> getAllAnnotations() => studyDao.getAllAnnotations();

  /// Watches all saved annotations.
  Stream<List<VerseAnnotation>> watchAllAnnotations() => studyDao.watchAllAnnotations();

  /// Gets all favorite verses.
  Future<List<VerseAnnotation>> getAllFavorites() =>
      studyDao.getAllFavorites();

  /// Watches all favorite verses.
  Stream<List<VerseAnnotation>> watchAllFavorites() =>
      studyDao.watchAllFavorites();

  /// Gets all notes.
  Future<List<VerseAnnotation>> getAllNotes() => studyDao.getAllNotes();

  /// Watches all notes.
  Stream<List<VerseAnnotation>> watchAllNotes() => studyDao.watchAllNotes();

  /// Gets all highlights, optionally filtered by color.
  Future<List<VerseAnnotation>> getHighlights({String? color}) =>
      studyDao.getHighlights(color: color);

  /// Watches all highlights, optionally filtered by color.
  Stream<List<VerseAnnotation>> watchHighlights({String? color}) =>
      studyDao.watchHighlights(color: color);
}

