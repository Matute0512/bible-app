import 'package:drift/drift.dart';

/// Key-value persistent progress markers (e.g. 'last_read').
class ReadingProgressState extends Table {
  TextColumn get key => text()(); // e.g. "last_read"
  TextColumn get translationId => text()();
  TextColumn get bookId => text()();
  IntColumn get chapterNumber => integer()();
  IntColumn get verseScrollOffset => integer().withDefault(const Constant(0))();
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column> get primaryKey => {key};
}

