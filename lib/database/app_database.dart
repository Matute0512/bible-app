import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/bible_cache_dao.dart';
import 'daos/history_dao.dart';
import 'tables/cached_books_table.dart';
import 'tables/cached_chapters_table.dart';
import 'tables/cached_verses_table.dart';
import 'tables/reading_history_table.dart';
import 'tables/reading_progress_table.dart';
import 'tables/user_reading_plans_table.dart';
import 'tables/verse_annotations_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    CachedBooks,
    CachedChapters,
    CachedVerses,
    VerseAnnotations,
    ReadingHistory,
    ReadingProgressState,
    UserReadingPlans,
  ],
  daos: [BibleCacheDao, HistoryDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection()) {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          // Initialize FTS5 virtual table for lightning-fast diacritic-insensitive Bible search
          await customStatement('''
            CREATE VIRTUAL TABLE IF NOT EXISTS fts_verses USING fts5(
              translation_id UNINDEXED,
              book_id UNINDEXED,
              chapter_number UNINDEXED,
              verse_number UNINDEXED,
              book_name UNINDEXED,
              text_content,
              normalized_text,
              tokenize = 'unicode61 remove_diacritics 2'
            );
          ''');
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return NativeDatabase.memory();
    }
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'bible_app.sqlite'));
      return NativeDatabase.createInBackground(file);
    } catch (_) {
      // Fallback for test environments and headless runners
      return NativeDatabase.memory();
    }
  });
}

