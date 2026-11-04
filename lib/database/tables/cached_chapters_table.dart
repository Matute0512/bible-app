import 'package:drift/drift.dart';

/// Local cache for Bible chapter metadata per translation.
class CachedChapters extends Table {
  TextColumn get translationId => text()();
  TextColumn get bookId => text()();
  IntColumn get chapterNumber => integer()();
  TextColumn get bookName => text()();
  TextColumn get sha256 => text().nullable()();
  IntColumn get fetchedAtMs => integer()();

  @override
  Set<Column> get primaryKey => {translationId, bookId, chapterNumber};
}

