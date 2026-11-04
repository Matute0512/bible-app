// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bible_cache_dao.dart';

// ignore_for_file: type=lint
mixin _$BibleCacheDaoMixin on DatabaseAccessor<AppDatabase> {
  $CachedBooksTable get cachedBooks => attachedDatabase.cachedBooks;
  $CachedChaptersTable get cachedChapters => attachedDatabase.cachedChapters;
  $CachedVersesTable get cachedVerses => attachedDatabase.cachedVerses;
  BibleCacheDaoManager get managers => BibleCacheDaoManager(this);
}

class BibleCacheDaoManager {
  final _$BibleCacheDaoMixin _db;
  BibleCacheDaoManager(this._db);
  $$CachedBooksTableTableManager get cachedBooks =>
      $$CachedBooksTableTableManager(_db.attachedDatabase, _db.cachedBooks);
  $$CachedChaptersTableTableManager get cachedChapters =>
      $$CachedChaptersTableTableManager(
        _db.attachedDatabase,
        _db.cachedChapters,
      );
  $$CachedVersesTableTableManager get cachedVerses =>
      $$CachedVersesTableTableManager(_db.attachedDatabase, _db.cachedVerses);
}
