// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_dao.dart';

// ignore_for_file: type=lint
mixin _$HistoryDaoMixin on DatabaseAccessor<AppDatabase> {
  $ReadingHistoryTable get readingHistory => attachedDatabase.readingHistory;
  $ReadingProgressStateTable get readingProgressState =>
      attachedDatabase.readingProgressState;
  HistoryDaoManager get managers => HistoryDaoManager(this);
}

class HistoryDaoManager {
  final _$HistoryDaoMixin _db;
  HistoryDaoManager(this._db);
  $$ReadingHistoryTableTableManager get readingHistory =>
      $$ReadingHistoryTableTableManager(
        _db.attachedDatabase,
        _db.readingHistory,
      );
  $$ReadingProgressStateTableTableManager get readingProgressState =>
      $$ReadingProgressStateTableTableManager(
        _db.attachedDatabase,
        _db.readingProgressState,
      );
}
