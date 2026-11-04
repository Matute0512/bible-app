import 'package:drift/drift.dart';

/// Local cache for Bible books per translation.
class CachedBooks extends Table {
  TextColumn get translationId => text()();
  TextColumn get bookId => text()();
  TextColumn get name => text()();
  TextColumn get normalizedName => text()();
  IntColumn get chapterCount => integer()();
  IntColumn get bookOrder => integer()();
  TextColumn get sha256 => text().nullable()();
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column> get primaryKey => {translationId, bookId};
}

