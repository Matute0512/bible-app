import 'package:drift/drift.dart';

/// User highlights, favorites, and personal notes keyed by canonical Bible coordinates.
@DataClassName('VerseAnnotationRow')
class VerseAnnotations extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text()();
  IntColumn get chapterNumber => integer()();
  IntColumn get verseNumber => integer()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  TextColumn get highlightColor => text().nullable()(); // 'ochre' | 'olive' | 'terracotta' | 'indigo'
  TextColumn get noteText => text().nullable()();
  TextColumn get tagsCsv => text().nullable()();
  TextColumn get originTranslationId => text()();
  TextColumn get bookNameSnapshot => text()();
  TextColumn get verseTextSnapshot => text()();
  IntColumn get createdAtMs => integer()();
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
