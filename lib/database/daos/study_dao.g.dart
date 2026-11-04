// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_dao.dart';

// ignore_for_file: type=lint
mixin _$StudyDaoMixin on DatabaseAccessor<AppDatabase> {
  $VerseAnnotationsTable get verseAnnotations =>
      attachedDatabase.verseAnnotations;
  StudyDaoManager get managers => StudyDaoManager(this);
}

class StudyDaoManager {
  final _$StudyDaoMixin _db;
  StudyDaoManager(this._db);
  $$VerseAnnotationsTableTableManager get verseAnnotations =>
      $$VerseAnnotationsTableTableManager(
        _db.attachedDatabase,
        _db.verseAnnotations,
      );
}
