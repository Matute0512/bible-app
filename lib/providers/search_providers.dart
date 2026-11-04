import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/daos/bible_cache_dao.dart';
import 'app_providers.dart';

/// Testament filter options for Bible search.
enum SearchTestamentFilter {
  all('Todos'),
  oldTestament('Antiguo Testamento'),
  newTestament('Nuevo Testamento');

  const SearchTestamentFilter(this.label);
  final String label;
}

/// The current text entered in the search bar.
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
  void clear() => state = '';
}

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

/// The active testament filter for search.
class SearchTestamentFilterNotifier extends Notifier<SearchTestamentFilter> {
  @override
  SearchTestamentFilter build() => SearchTestamentFilter.all;

  void setFilter(SearchTestamentFilter filter) => state = filter;
}

final searchTestamentFilterProvider =
    NotifierProvider<SearchTestamentFilterNotifier, SearchTestamentFilter>(
  SearchTestamentFilterNotifier.new,
);

/// Status of full translation offline download.
class TranslationDownloadStatus {
  const TranslationDownloadStatus({
    this.isDownloading = false,
    this.progress = 0.0,
    this.statusMessage = '',
    this.error,
  });

  final bool isDownloading;
  final double progress;
  final String statusMessage;
  final String? error;

  TranslationDownloadStatus copyWith({
    bool? isDownloading,
    double? progress,
    String? statusMessage,
    String? error,
  }) {
    return TranslationDownloadStatus(
      isDownloading: isDownloading ?? this.isDownloading,
      progress: progress ?? this.progress,
      statusMessage: statusMessage ?? this.statusMessage,
      error: error,
    );
  }
}

/// Notifier to trigger and monitor downloading the complete translation offline.
class TranslationDownloadNotifier extends Notifier<TranslationDownloadStatus> {
  @override
  TranslationDownloadStatus build() => const TranslationDownloadStatus();

  Future<void> startDownload(String translationId) async {
    if (state.isDownloading) return;

    state = const TranslationDownloadStatus(
      isDownloading: true,
      progress: 0.05,
      statusMessage: 'Iniciando descarga...',
    );

    try {
      final repository = ref.read(bibleRepositoryProvider);
      await repository.downloadAndIndexCompleteTranslation(
        translationId,
        onProgress: (progress, status) {
          state = state.copyWith(
            progress: progress,
            statusMessage: status,
          );
        },
      );

      // Invalidate cached chapters count so UI updates
      ref.invalidate(cachedChaptersCountProvider);

      state = const TranslationDownloadStatus(
        isDownloading: false,
        progress: 1.0,
        statusMessage: 'Traducción completa guardada para uso sin conexión.',
      );
    } catch (e) {
      state = const TranslationDownloadStatus(
        isDownloading: false,
        error: 'No se pudo descargar la traducción completa. Verificá tu conexión.',
      );
    }
  }
}

final translationDownloadProvider =
    NotifierProvider<TranslationDownloadNotifier, TranslationDownloadStatus>(
  TranslationDownloadNotifier.new,
);

/// Count of distinct chapters cached for the active translation.
final cachedChaptersCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final prefsAsync = await ref.watch(userPreferencesProvider.future);
  final translationId = prefsAsync.translationId;
  final repository = ref.watch(bibleRepositoryProvider);
  return repository.getCachedChaptersCount(translationId);
});

/// Debounced search results from FTS5 SQLite virtual table.
final bibleSearchResultsProvider =
    FutureProvider.autoDispose<List<FtsSearchResult>>((ref) async {
  final query = ref.watch(searchQueryProvider).trim();
  final filter = ref.watch(searchTestamentFilterProvider);
  final prefsAsync = await ref.watch(userPreferencesProvider.future);
  final translationId = prefsAsync.translationId;
  final repository = ref.watch(bibleRepositoryProvider);

  if (query.length < 2) {
    return [];
  }

  // 250ms debounce
  var isCancelled = false;
  ref.onDispose(() => isCancelled = true);
  await Future<void>.delayed(const Duration(milliseconds: 250));
  if (isCancelled) return [];

  // Determine book IDs if testament filter is applied
  Set<String>? allowedBookIds;
  if (filter != SearchTestamentFilter.all) {
    final books = await repository.getBooks(translationId);
    if (filter == SearchTestamentFilter.oldTestament) {
      // Books with order <= 39 or order <= 46 for Catholic canon
      allowedBookIds = books
          .where((b) => b.order <= 39 || (b.order <= 46 && translationId == 'spa_blm'))
          .map((b) => b.id)
          .toSet();
    } else {
      // New Testament
      final otLimit = translationId == 'spa_blm' ? 46 : 39;
      allowedBookIds = books
          .where((b) => b.order > otLimit)
          .map((b) => b.id)
          .toSet();
    }
  }

  return repository.searchVerses(
    translationId: translationId,
    query: query,
    bookIds: allowedBookIds,
    limit: 100,
  );
});
