import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/bible_book.dart';
import '../providers/app_providers.dart';
import '../utils/text_normalizer.dart';

final booksProvider = FutureProvider.autoDispose<List<BibleBook>>((ref) async {
  ref.keepAlive();

  final translationId = await ref.watch(
    userPreferencesProvider.selectAsync((s) => s.translationId),
  );
  final repo = ref.watch(bibleRepositoryProvider);
  return repo.getBooks(translationId);
});

final cachedChaptersForBookProvider =
    FutureProvider.family<Set<int>, String>((ref, bookId) async {
  final translationId = await ref.watch(
    userPreferencesProvider.selectAsync((s) => s.translationId),
  );
  final repo = ref.watch(bibleRepositoryProvider);
  return repo.getCachedChapterNumbers(
    translationId: translationId,
    bookId: bookId,
  );
});

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String _searchQuery = '';
  String _selectedTestament = 'Todos';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final booksAsync = ref.watch(booksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Búsqueda Libre')),
      body: booksAsync.when(
        data: (books) {
          final filteredBooks = books.where((book) {
            // Testament filter: Mateo (order 40) is NT start in protestant canon
            if (_selectedTestament == 'Nuevo Testamento' && book.order < 40) {
              return false;
            }
            if (_selectedTestament == 'Antiguo Testamento' && book.order >= 40) {
              return false;
            }

            if (_searchQuery.trim().isEmpty) return true;

            final normalizedBook = TextNormalizer.normalizeForSearch(book.name);
            final normalizedQuery = TextNormalizer.normalizeForSearch(_searchQuery);
            return normalizedBook.contains(normalizedQuery);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar libro...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Todos'),
                      selected: _selectedTestament == 'Todos',
                      onSelected: (_) => setState(() => _selectedTestament = 'Todos'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Antiguo Testamento'),
                      selected: _selectedTestament == 'Antiguo Testamento',
                      onSelected: (_) =>
                          setState(() => _selectedTestament = 'Antiguo Testamento'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Nuevo Testamento'),
                      selected: _selectedTestament == 'Nuevo Testamento',
                      onSelected: (_) =>
                          setState(() => _selectedTestament = 'Nuevo Testamento'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _BooksListView(books: filteredBooks),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Error al cargar libros: $err',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ),
      ),
    );
  }
}

class _BooksListView extends StatelessWidget {
  const _BooksListView({required this.books});

  final List<BibleBook> books;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        return _BookExpansionTile(book: books[index]);
      },
    );
  }
}

class _BookExpansionTile extends ConsumerWidget {
  const _BookExpansionTile({required this.book});

  final BibleBook book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cachedChaptersAsync = ref.watch(cachedChaptersForBookProvider(book.id));
    final cachedChapters = cachedChaptersAsync.asData?.value ?? const <int>{};

    final subtitleText = cachedChapters.isEmpty
        ? '${book.chapterCount} capítulos'
        : '${book.chapterCount} capítulos • ${cachedChapters.length} sin conexión';

    return ExpansionTile(
      title: Text(book.displayName, style: theme.textTheme.titleMedium),
      subtitle: Row(
        children: [
          Text(subtitleText, style: theme.textTheme.bodySmall),
          if (cachedChapters.isNotEmpty) ...[
            const SizedBox(width: 4),
            Icon(Icons.offline_pin_outlined, size: 14, color: colorScheme.secondary),
          ],
        ],
      ),
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 60,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: book.chapterCount,
          itemBuilder: (context, chapterIndex) {
            final chapterNum = chapterIndex + 1;
            final isCached = cachedChapters.contains(chapterNum);

            return InkWell(
              onTap: () {
                ref
                    .read(dailyReadingProvider.notifier)
                    .loadFreeChapter(book.id, book.name, chapterNum);
                context.push('/reading');
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isCached
                      ? colorScheme.secondaryContainer.withValues(alpha: 0.35)
                      : null,
                  border: Border.all(
                    color: isCached
                        ? colorScheme.secondary.withValues(alpha: 0.5)
                        : colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      '$chapterNum',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    if (isCached)
                      Positioned(
                        top: 3,
                        right: 3,
                        child: Icon(
                          Icons.offline_pin,
                          size: 10,
                          color: colorScheme.secondary,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
