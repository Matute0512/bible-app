import 'package:drift/drift.dart';

import '../../models/verse_annotation.dart';
import '../app_database.dart';
import '../tables/verse_annotations_table.dart';

part 'study_dao.g.dart';

@DriftAccessor(tables: [VerseAnnotations])
class StudyDao extends DatabaseAccessor<AppDatabase> with _$StudyDaoMixin {
  StudyDao(super.db);

  VerseAnnotation _mapRow(VerseAnnotationRow row) {
    return VerseAnnotation(
      id: row.id,
      bookId: row.bookId,
      chapterNumber: row.chapterNumber,
      verseNumber: row.verseNumber,
      isFavorite: row.isFavorite,
      highlightColor: row.highlightColor,
      noteText: row.noteText,
      tagsCsv: row.tagsCsv,
      originTranslationId: row.originTranslationId,
      bookNameSnapshot: row.bookNameSnapshot,
      verseTextSnapshot: row.verseTextSnapshot,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAtMs),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAtMs),
    );
  }

  /// Inserts or updates an annotation row. If all fields are cleared, removes the row.
  Future<void> upsertAnnotation(VerseAnnotation annotation) async {
    final id = annotation.id;

    if (!annotation.hasAnnotation) {
      await (delete(verseAnnotations)..where((tbl) => tbl.id.equals(id))).go();
      return;
    }

    final companion = VerseAnnotationsCompanion.insert(
      id: id,
      bookId: annotation.bookId,
      chapterNumber: annotation.chapterNumber,
      verseNumber: annotation.verseNumber,
      isFavorite: Value(annotation.isFavorite),
      highlightColor: Value(annotation.highlightColor),
      noteText: Value(annotation.noteText),
      tagsCsv: Value(annotation.tagsCsv),
      originTranslationId: annotation.originTranslationId,
      bookNameSnapshot: annotation.bookNameSnapshot,
      verseTextSnapshot: annotation.verseTextSnapshot,
      createdAtMs: annotation.createdAt.millisecondsSinceEpoch,
      updatedAtMs: annotation.updatedAt.millisecondsSinceEpoch,
    );

    await into(verseAnnotations).insertOnConflictUpdate(companion);
  }

  /// Toggles favorite status for a verse coordinate.
  Future<bool> toggleFavorite({
    required String bookId,
    required int chapterNumber,
    required int verseNumber,
    required String originTranslationId,
    required String bookNameSnapshot,
    required String verseTextSnapshot,
  }) async {
    final current = await getAnnotation(
      bookId: bookId,
      chapterNumber: chapterNumber,
      verseNumber: verseNumber,
    );

    final now = DateTime.now();
    final newFavorite = !(current?.isFavorite ?? false);

    if (current != null) {
      final updated = current.copyWith(
        isFavorite: newFavorite,
        updatedAt: now,
      );
      await upsertAnnotation(updated);
    } else {
      final id = VerseAnnotation.coordinateId(bookId, chapterNumber, verseNumber);
      final newAnnotation = VerseAnnotation(
        id: id,
        bookId: bookId,
        chapterNumber: chapterNumber,
        verseNumber: verseNumber,
        isFavorite: true,
        originTranslationId: originTranslationId,
        bookNameSnapshot: bookNameSnapshot,
        verseTextSnapshot: verseTextSnapshot,
        createdAt: now,
        updatedAt: now,
      );
      await upsertAnnotation(newAnnotation);
    }

    return newFavorite;
  }

  /// Sets or clears highlight color for a verse coordinate.
  Future<void> setHighlight({
    required String bookId,
    required int chapterNumber,
    required int verseNumber,
    required String? highlightColor,
    required String originTranslationId,
    required String bookNameSnapshot,
    required String verseTextSnapshot,
  }) async {
    final current = await getAnnotation(
      bookId: bookId,
      chapterNumber: chapterNumber,
      verseNumber: verseNumber,
    );

    final now = DateTime.now();
    if (current != null) {
      final updated = current.copyWith(
        highlightColor: () => highlightColor,
        updatedAt: now,
      );
      await upsertAnnotation(updated);
    } else if (highlightColor != null) {
      final id = VerseAnnotation.coordinateId(bookId, chapterNumber, verseNumber);
      final newAnnotation = VerseAnnotation(
        id: id,
        bookId: bookId,
        chapterNumber: chapterNumber,
        verseNumber: verseNumber,
        highlightColor: highlightColor,
        originTranslationId: originTranslationId,
        bookNameSnapshot: bookNameSnapshot,
        verseTextSnapshot: verseTextSnapshot,
        createdAt: now,
        updatedAt: now,
      );
      await upsertAnnotation(newAnnotation);
    }
  }

  /// Sets or clears personal note for a verse coordinate.
  Future<void> saveNote({
    required String bookId,
    required int chapterNumber,
    required int verseNumber,
    required String? noteText,
    String? tagsCsv,
    required String originTranslationId,
    required String bookNameSnapshot,
    required String verseTextSnapshot,
  }) async {
    final current = await getAnnotation(
      bookId: bookId,
      chapterNumber: chapterNumber,
      verseNumber: verseNumber,
    );

    final now = DateTime.now();
    final trimmed = noteText?.trim();
    final normalizedText = (trimmed != null && trimmed.isNotEmpty) ? trimmed : null;

    if (current != null) {
      final updated = current.copyWith(
        noteText: () => normalizedText,
        tagsCsv: () => tagsCsv,
        updatedAt: now,
      );
      await upsertAnnotation(updated);
    } else if (normalizedText != null) {
      final id = VerseAnnotation.coordinateId(bookId, chapterNumber, verseNumber);
      final newAnnotation = VerseAnnotation(
        id: id,
        bookId: bookId,
        chapterNumber: chapterNumber,
        verseNumber: verseNumber,
        noteText: normalizedText,
        tagsCsv: tagsCsv,
        originTranslationId: originTranslationId,
        bookNameSnapshot: bookNameSnapshot,
        verseTextSnapshot: verseTextSnapshot,
        createdAt: now,
        updatedAt: now,
      );
      await upsertAnnotation(newAnnotation);
    }
  }

  /// Deletes an annotation by ID.
  Future<void> deleteAnnotation(String id) async {
    await (delete(verseAnnotations)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Retrieves annotation for verse coordinate if present.
  Future<VerseAnnotation?> getAnnotation({
    required String bookId,
    required int chapterNumber,
    required int verseNumber,
  }) async {
    final id = VerseAnnotation.coordinateId(bookId, chapterNumber, verseNumber);
    final query = select(verseAnnotations)..where((tbl) => tbl.id.equals(id));
    final row = await query.getSingleOrNull();
    return row != null ? _mapRow(row) : null;
  }

  /// Watches annotation for verse coordinate reactively.
  Stream<VerseAnnotation?> watchAnnotation({
    required String bookId,
    required int chapterNumber,
    required int verseNumber,
  }) {
    final id = VerseAnnotation.coordinateId(bookId, chapterNumber, verseNumber);
    final query = select(verseAnnotations)..where((tbl) => tbl.id.equals(id));
    return query.watchSingleOrNull().map((row) => row != null ? _mapRow(row) : null);
  }

  /// Returns map of verseNumber -> VerseAnnotation for a chapter.
  Future<Map<int, VerseAnnotation>> getAnnotationsForChapter({
    required String bookId,
    required int chapterNumber,
  }) async {
    final query = select(verseAnnotations)
      ..where(
        (tbl) =>
            tbl.bookId.equals(bookId) & tbl.chapterNumber.equals(chapterNumber),
      );
    final rows = await query.get();
    return {for (final r in rows) r.verseNumber: _mapRow(r)};
  }

  /// Watches map of verseNumber -> VerseAnnotation for a chapter.
  Stream<Map<int, VerseAnnotation>> watchAnnotationsForChapter({
    required String bookId,
    required int chapterNumber,
  }) {
    final query = select(verseAnnotations)
      ..where(
        (tbl) =>
            tbl.bookId.equals(bookId) & tbl.chapterNumber.equals(chapterNumber),
      );
    return query.watch().map((rows) {
      return {for (final r in rows) r.verseNumber: _mapRow(r)};
    });
  }

  /// Gets all annotations sorted by updated time descending.
  Future<List<VerseAnnotation>> getAllAnnotations() async {
    final query = select(verseAnnotations)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAtMs)]);
    final rows = await query.get();
    return rows.map(_mapRow).toList();
  }

  /// Watches all annotations sorted by updated time descending.
  Stream<List<VerseAnnotation>> watchAllAnnotations() {
    final query = select(verseAnnotations)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAtMs)]);
    return query.watch().map((rows) => rows.map(_mapRow).toList());
  }

  /// Gets all favorite verses sorted by updated time descending.
  Future<List<VerseAnnotation>> getAllFavorites() async {
    final query = select(verseAnnotations)
      ..where((tbl) => tbl.isFavorite.equals(true))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAtMs)]);
    final rows = await query.get();
    return rows.map(_mapRow).toList();
  }

  /// Watches all favorite verses.
  Stream<List<VerseAnnotation>> watchAllFavorites() {
    final query = select(verseAnnotations)
      ..where((tbl) => tbl.isFavorite.equals(true))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAtMs)]);
    return query.watch().map((rows) => rows.map(_mapRow).toList());
  }

  /// Gets all notes sorted by updated time descending.
  Future<List<VerseAnnotation>> getAllNotes() async {
    final query = select(verseAnnotations)
      ..where((tbl) => tbl.noteText.isNotNull())
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAtMs)]);
    final rows = await query.get();
    return rows.map(_mapRow).toList();
  }

  /// Watches all notes.
  Stream<List<VerseAnnotation>> watchAllNotes() {
    final query = select(verseAnnotations)
      ..where((tbl) => tbl.noteText.isNotNull())
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAtMs)]);
    return query.watch().map((rows) => rows.map(_mapRow).toList());
  }

  /// Gets all highlighted verses, optionally filtered by color.
  Future<List<VerseAnnotation>> getHighlights({String? color}) async {
    final query = select(verseAnnotations)
      ..where((tbl) {
        if (color != null) {
          return tbl.highlightColor.equals(color);
        }
        return tbl.highlightColor.isNotNull();
      })
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAtMs)]);
    final rows = await query.get();
    return rows.map(_mapRow).toList();
  }

  /// Watches all highlighted verses, optionally filtered by color.
  Stream<List<VerseAnnotation>> watchHighlights({String? color}) {
    final query = select(verseAnnotations)
      ..where((tbl) {
        if (color != null) {
          return tbl.highlightColor.equals(color);
        }
        return tbl.highlightColor.isNotNull();
      })
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAtMs)]);
    return query.watch().map((rows) => rows.map(_mapRow).toList());
  }
}
