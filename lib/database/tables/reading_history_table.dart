import 'package:drift/drift.dart';

/// Historical log of chapters read by the user with date and source.
class ReadingHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get bookId => text()();
  IntColumn get chapterNumber => integer()();
  TextColumn get translationId => text()();
  TextColumn get readingDateIso => text()(); // "YYYY-MM-DD" local wall clock date
  IntColumn get readAtMs => integer()();
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
  TextColumn get source => text().withDefault(const Constant('daily_plan'))(); // daily_plan | free_reading | thematic_plan
  TextColumn get planId => text().nullable()();
}

