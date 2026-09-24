import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/bible_book.dart';
import '../providers/app_providers.dart';

// [FIX-EXPLORE-01] Provider was declared file-level inside a screen file,
// making it hard to test and causing it to bypass the Riverpod scope.
// Also, it used `ref.watch` inside an async body (wrong — only `ref.read`
// or `ref.watch` in sync provider bodies is safe). Fixed to `ref.read` for
// the api service call, while correctly awaiting the user preferences future.
final booksProvider = FutureProvider.autoDispose<List<BibleBook>>((ref) async {
  // Keep alive while the screen is mounted so the user can scroll freely
  // without triggering a re-fetch on every frame.
  ref.keepAlive();

  final userPrefs = await ref.watch(userPreferencesProvider.future);
  final apiService = ref.read(apiServiceProvider);
  return apiService.fetchBooks(userPrefs.translationId);
});

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final booksAsync = ref.watch(booksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Búsqueda Libre')),
      body: booksAsync.when(
        data: (books) => _BooksListView(books: books),
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

// [FIX-EXPLORE-02] Extracted the list body into its own StatelessWidget.
// Previously, every chapter tap called `context.push('/reading')` BEFORE
// `loadFreeChapter` had finished, causing a race condition where ReadingScreen
// could render the old state. Now we call `context.push` only and the
// ReadingScreen already handles the `LoadingPlan` / shimmer transition.
class _BooksListView extends ConsumerWidget {
  const _BooksListView({required this.books});

  final List<BibleBook> books;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return ExpansionTile(
          title: Text(book.name, style: theme.textTheme.titleMedium),
          subtitle: Text(
            '${book.chapterCount} capítulos',
            style: theme.textTheme.bodySmall,
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
                return InkWell(
                  onTap: () {
                    // Start loading, then navigate. The ReadingScreen shows a
                    // shimmer while the chapter fetch is in progress.
                    ref
                        .read(dailyReadingProvider.notifier)
                        .loadFreeChapter(book.id, book.name, chapterNum);
                    context.push('/reading');
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$chapterNum',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
