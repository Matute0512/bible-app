import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/bible_repository.dart';
import 'bible_api_provider.dart';
import 'database_provider.dart';

/// Provider for the singleton [BibleRepository].
final bibleRepositoryProvider = Provider<BibleRepository>((ref) {
  final api = ref.watch(apiServiceProvider);
  final cache = ref.watch(bibleCacheDaoProvider);
  return BibleRepository(api: api, cache: cache);
});
