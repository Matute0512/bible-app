import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/daos/bible_cache_dao.dart';
import '../database/daos/history_dao.dart';

/// Provider for the singleton Drift [AppDatabase].
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Provider for [BibleCacheDao].
final bibleCacheDaoProvider = Provider<BibleCacheDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.bibleCacheDao;
});

/// Provider for [HistoryDao].
final historyDaoProvider = Provider<HistoryDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.historyDao;
});
