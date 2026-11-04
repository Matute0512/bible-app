import 'package:drift/drift.dart';

/// Local cache for individual verses per chapter and translation.
class CachedVerses extends Table {
  TextColumn get translationId => text()();
  TextColumn get bookId => text()();
  IntColumn get chapterNumber => integer()();
  IntColumn get verseNumber => integer()();
  TextColumn get textContent => text()();
  TextColumn get normalizedText => text()();

  @override
  Set<Column> get primaryKey => {translationId, bookId, chapterNumber, verseNumber};
}

