import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../database/daos/bible_cache_dao.dart';
import '../providers/app_providers.dart';
import '../providers/search_providers.dart';
import '../theme/bible_theme.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final currentQuery = ref.read(searchQueryProvider);
    _textController.text = currentQuery;
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    ref.read(searchQueryProvider.notifier).setQuery(query);
  }

  void _clearQuery() {
    _textController.clear();
    ref.read(searchQueryProvider.notifier).clear();
  }

  void _navigateToVerse(FtsSearchResult result) {
    ref.read(dailyReadingProvider.notifier).loadFreeChapter(
          result.bookId,
          result.bookName,
          result.chapterNumber,
        );
    context.push('/reading');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final readingStyle = BibleReadingStyle.of(context);
    final query = ref.watch(searchQueryProvider);
    final selectedFilter = ref.watch(searchTestamentFilterProvider);
    final searchResultsAsync = ref.watch(bibleSearchResultsProvider);
    final cachedChaptersAsync = ref.watch(cachedChaptersCountProvider);
    final downloadStatus = ref.watch(translationDownloadProvider);
    final userPrefs = ref.watch(userPreferencesProvider).value;
    final activeTranslation = userPrefs?.translationId ?? 'spa_rvg';

    final isCatholic = activeTranslation == 'spa_blm';
    final totalExpectedChapters = isCatholic ? 1326 : 1189;

    return Scaffold(
      backgroundColor: readingStyle.surfaceColor,
      appBar: AppBar(
        backgroundColor: readingStyle.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Volver',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: readingStyle.cardBackground,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              autofocus: query.isEmpty,
              textInputAction: TextInputAction.search,
              onChanged: _onQueryChanged,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: readingStyle.textColor,
                fontFamily: 'Inter',
              ),
              decoration: InputDecoration(
                hintText: 'Buscar palabras o frases...',
                hintStyle: TextStyle(
                  color: readingStyle.metaColor,
                  fontFamily: 'Inter',
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                  color: readingStyle.metaColor,
                ),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        color: readingStyle.metaColor,
                        onPressed: _clearQuery,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Column(
            children: [
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: SearchTestamentFilter.values.map((filter) {
                    final isSelected = filter == selectedFilter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          filter.label,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? theme.colorScheme.onPrimaryContainer
                                : readingStyle.metaColor,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (_) {
                          ref
                              .read(searchTestamentFilterProvider.notifier)
                              .setFilter(filter);
                        },
                        backgroundColor: readingStyle.cardBackground,
                        selectedColor: theme.colorScheme.primaryContainer,
                        side: BorderSide(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Offline download banner if not all chapters are cached
          cachedChaptersAsync.when(
            data: (cachedCount) {
              if (cachedCount >= totalExpectedChapters) {
                return const SizedBox.shrink();
              }
              return _buildDownloadBanner(
                context,
                cachedCount: cachedCount,
                totalCount: totalExpectedChapters,
                downloadStatus: downloadStatus,
                activeTranslation: activeTranslation,
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),

          // Main body: suggestions, results, or empty state
          Expanded(
            child: query.trim().length < 2
                ? _buildInitialSuggestions(context)
                : searchResultsAsync.when(
                    data: (results) {
                      if (results.isEmpty) {
                        return _buildNoResults(context, query);
                      }
                      return _buildResultsList(context, results);
                    },
                    loading: () => Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    error: (err, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Ocurrió un error al buscar: $err',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: readingStyle.metaColor),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadBanner(
    BuildContext context, {
    required int cachedCount,
    required int totalCount,
    required TranslationDownloadStatus downloadStatus,
    required String activeTranslation,
  }) {
    final theme = Theme.of(context);
    final readingStyle = BibleReadingStyle.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: readingStyle.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud_download_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Buscando en $cachedCount de $totalCount capítulos guardados',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: readingStyle.textColor,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Descargá la traducción completa (~1,5 MB) para buscar en toda la Biblia sin conexión.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: readingStyle.metaColor,
              fontFamily: 'Inter',
              fontSize: 11,
            ),
          ),
          if (downloadStatus.isDownloading) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: downloadStatus.progress > 0 ? downloadStatus.progress : null,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 4),
            Text(
              downloadStatus.statusMessage,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: readingStyle.metaColor,
                fontFamily: 'Inter',
              ),
            ),
          ] else if (downloadStatus.error != null) ...[
            const SizedBox(height: 4),
            Text(
              downloadStatus.error!,
              style: TextStyle(
                color: theme.colorScheme.error,
                fontSize: 11,
                fontFamily: 'Inter',
              ),
            ),
          ] else ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                icon: const Icon(Icons.download, size: 16),
                label: const Text(
                  'Descargar Biblia completa',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12),
                ),
                onPressed: () {
                  ref
                      .read(translationDownloadProvider.notifier)
                      .startDownload(activeTranslation);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInitialSuggestions(BuildContext context) {
    final readingStyle = BibleReadingStyle.of(context);
    final theme = Theme.of(context);

    final suggestedTerms = [
      'amor',
      'esperanza',
      'fe',
      'principio',
      'paz',
      'sabiduría',
      'gracia',
      'luz',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Icon(
            Icons.menu_book_outlined,
            size: 48,
            color: readingStyle.metaColor.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Búsqueda Global',
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: 'Lora',
              fontWeight: FontWeight.bold,
              color: readingStyle.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escribí cualquier palabra o frase bíblica.\nLa búsqueda no distingue mayúsculas ni tildes.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'Inter',
              color: readingStyle.metaColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Búsquedas sugeridas',
              style: theme.textTheme.labelMedium?.copyWith(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: readingStyle.metaColor,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestedTerms.map((term) {
              return ActionChip(
                label: Text(
                  term,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                ),
                backgroundColor: readingStyle.cardBackground,
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onPressed: () {
                  _textController.text = term;
                  _onQueryChanged(term);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(BuildContext context, String query) {
    final readingStyle = BibleReadingStyle.of(context);
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 48,
              color: readingStyle.metaColor.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin resultados para «$query»',
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: 'Lora',
                fontWeight: FontWeight.w600,
                color: readingStyle.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Probá con otra palabra o verificá que no haya errores de escritura.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'Inter',
                color: readingStyle.metaColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(BuildContext context, List<FtsSearchResult> results) {
    final theme = Theme.of(context);
    final readingStyle = BibleReadingStyle.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            '${results.length} ${results.length == 1 ? 'versículo encontrado' : 'versículos encontrados'}',
            style: theme.textTheme.labelMedium?.copyWith(
              fontFamily: 'Inter',
              color: readingStyle.metaColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: results.length,
            separatorBuilder: (_, _) => Divider(
              height: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
            itemBuilder: (context, index) {
              final result = results[index];
              return InkWell(
                onTap: () => _navigateToVerse(result),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            result.reference,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontFamily: 'Lora',
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: readingStyle.metaColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _buildSnippetText(context, result.snippet),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Parses FTS5 snippet containing `<b>...</b>` and renders matching words highlighted.
  Widget _buildSnippetText(BuildContext context, String snippet) {
    final readingStyle = BibleReadingStyle.of(context);
    final theme = Theme.of(context);

    final spans = <TextSpan>[];
    final parts = snippet.split('<b>');

    for (var i = 0; i < parts.length; i++) {
      if (i == 0) {
        if (parts[i].isNotEmpty) {
          spans.add(TextSpan(text: parts[i]));
        }
      } else {
        final subParts = parts[i].split('</b>');
        if (subParts.isNotEmpty) {
          // Highlighted match
          spans.add(
            TextSpan(
              text: subParts[0],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
              ),
            ),
          );
          if (subParts.length > 1 && subParts[1].isNotEmpty) {
            spans.add(TextSpan(text: subParts[1]));
          }
        }
      }
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'Lora',
          fontSize: 14,
          height: 1.45,
          color: readingStyle.textColor,
        ),
        children: spans,
      ),
    );
  }
}
