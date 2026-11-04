import 'package:drift/drift.dart';

import '../../models/bible_book.dart';
import '../../models/bible_chapter.dart';
import '../../models/verse.dart';
import '../../utils/text_normalizer.dart';
import '../app_database.dart';
import '../tables/cached_books_table.dart';
import '../tables/cached_chapters_table.dart';
import '../tables/cached_verses_table.dart';

part 'bible_cache_dao.g.dart';

@DriftAccessor(tables: [CachedBooks, CachedChapters, CachedVerses])
class BibleCacheDao extends DatabaseAccessor<AppDatabase> with _$BibleCacheDaoMixin {
  BibleCacheDao(super.db);

  /// Checks if books are cached for [translationId].
  Future<bool> hasBooks(String translationId) async {
    final count = await (select(cachedBooks)
          ..where((tbl) => tbl.translationId.equals(translationId)))
        .get();
    return count.isNotEmpty;
  }

  /// Retrieves cached books for [translationId], ordered by canonical book order.
  Future<List<BibleBook>> getCachedBooks(String translationId) async {
    final rows = await (select(cachedBooks)
          ..where((tbl) => tbl.translationId.equals(translationId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.bookOrder)]))
        .get();

    return rows
        .map(
          (row) => BibleBook(
            id: row.bookId,
            name: row.name,
            chapterCount: row.chapterCount,
            order: row.bookOrder,
          ),
        )
        .toList();
  }

  /// Saves a list of books into the cache in a single atomic transaction.
  Future<void> saveBooks(String translationId, List<BibleBook> books) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await batch((b) {
      b.insertAllOnConflictUpdate(
        cachedBooks,
        books.map(
          (book) => CachedBooksCompanion.insert(
            translationId: translationId,
            bookId: book.id,
            name: book.name,
            normalizedName: TextNormalizer.normalizeForSearch(book.name),
            chapterCount: book.chapterCount,
            bookOrder: book.order,
            updatedAtMs: now,
          ),
        ),
      );
    });
  }

  /// Checks if a specific chapter is cached locally.
  /// Returns a set of all cached chapter numbers for [bookId] and [translationId].
  Future<Set<int>> getCachedChapterNumbers({
    required String translationId,
    required String bookId,
  }) async {
    final rows = await (select(cachedChapters)
          ..where(
            (tbl) =>
                tbl.translationId.equals(translationId) &
                tbl.bookId.equals(bookId),
          ))
        .get();
    return rows.map((r) => r.chapterNumber).toSet();
  }

  Future<bool> hasChapter({
    required String translationId,
    required String bookId,
    required int chapterNumber,
  }) async {
    final row = await (select(cachedChapters)
          ..where(
            (tbl) =>
                tbl.translationId.equals(translationId) &
                tbl.bookId.equals(bookId) &
                tbl.chapterNumber.equals(chapterNumber),
          ))
        .getSingleOrNull();
    return row != null;
  }

  /// Retrieves a complete cached chapter with its verses, or returns null if not found.
  Future<BibleChapter?> getCachedChapter({
    required String translationId,
    required String bookId,
    required int chapterNumber,
  }) async {
    final chapterRow = await (select(cachedChapters)
          ..where(
            (tbl) =>
                tbl.translationId.equals(translationId) &
                tbl.bookId.equals(bookId) &
                tbl.chapterNumber.equals(chapterNumber),
          ))
        .getSingleOrNull();

    if (chapterRow == null) return null;

    final verseRows = await (select(cachedVerses)
          ..where(
            (tbl) =>
                tbl.translationId.equals(translationId) &
                tbl.bookId.equals(bookId) &
                tbl.chapterNumber.equals(chapterNumber),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.verseNumber)]))
        .get();

    return BibleChapter(
      bookId: chapterRow.bookId,
      bookName: chapterRow.bookName,
      chapterNumber: chapterRow.chapterNumber,
      verses: verseRows
          .map((v) => Verse(number: v.verseNumber, text: v.textContent))
          .toList(),
    );
  }

  /// Saves a chapter and its verses into SQLite and synchronizes with FTS5.
  Future<void> saveChapter(String translationId, BibleChapter chapter) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await transaction(() async {
      // 1. Insert or update chapter metadata
      await into(cachedChapters).insertOnConflictUpdate(
        CachedChaptersCompanion.insert(
          translationId: translationId,
          bookId: chapter.bookId,
          chapterNumber: chapter.chapterNumber,
          bookName: chapter.bookName,
          fetchedAtMs: now,
        ),
      );

      // 2. Insert or update verses
      await batch((b) {
        b.insertAllOnConflictUpdate(
          cachedVerses,
          chapter.verses.map(
            (v) => CachedVersesCompanion.insert(
              translationId: translationId,
              bookId: chapter.bookId,
              chapterNumber: chapter.chapterNumber,
              verseNumber: v.number,
              textContent: v.text,
              normalizedText: TextNormalizer.normalizeForSearch(v.text),
            ),
          ),
        );
      });

      // 3. Sync into FTS5 index (delete existing entries for this chapter first, then insert)
      await customStatement(
        'DELETE FROM fts_verses WHERE translation_id = ? AND book_id = ? AND chapter_number = ?',
        [translationId, chapter.bookId, chapter.chapterNumber],
      );

      for (final v in chapter.verses) {
        await customStatement(
          '''
          INSERT INTO fts_verses (
            translation_id, book_id, chapter_number, verse_number,
            book_name, text_content, normalized_text
          ) VALUES (?, ?, ?, ?, ?, ?, ?)
          ''',
          [
            translationId,
            chapter.bookId,
            chapter.chapterNumber,
            v.number,
            chapter.bookName,
            v.text,
            TextNormalizer.normalizeForSearch(v.text),
          ],
        );
      }
    });
  }

  /// Counts how many distinct chapters are currently cached for [translationId].
  Future<int> getCachedChaptersCount(String translationId) async {
    final countExp = countAll();
    final query = selectOnly(cachedChapters)
      ..addColumns([countExp])
      ..where(cachedChapters.translationId.equals(translationId));
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  /// Saves a batch of chapters and their verses into SQLite and FTS5.
  Future<void> saveBatchChapters(
    String translationId,
    List<BibleChapter> chapters,
  ) async {
    if (chapters.isEmpty) return;
    final now = DateTime.now().millisecondsSinceEpoch;

    await transaction(() async {
      await batch((b) {
        b.insertAllOnConflictUpdate(
          cachedChapters,
          chapters.map(
            (c) => CachedChaptersCompanion.insert(
              translationId: translationId,
              bookId: c.bookId,
              chapterNumber: c.chapterNumber,
              bookName: c.bookName,
              fetchedAtMs: now,
            ),
          ),
        );
      });

      await batch((b) {
        for (final chapter in chapters) {
          b.insertAllOnConflictUpdate(
            cachedVerses,
            chapter.verses.map(
              (v) => CachedVersesCompanion.insert(
                translationId: translationId,
                bookId: chapter.bookId,
                chapterNumber: chapter.chapterNumber,
                verseNumber: v.number,
                textContent: v.text,
                normalizedText: TextNormalizer.normalizeForSearch(v.text),
              ),
            ),
          );
        }
      });

      for (final chapter in chapters) {
        await customStatement(
          'DELETE FROM fts_verses WHERE translation_id = ? AND book_id = ? AND chapter_number = ?',
          [translationId, chapter.bookId, chapter.chapterNumber],
        );
        for (final v in chapter.verses) {
          await customStatement(
            '''
            INSERT INTO fts_verses (
              translation_id, book_id, chapter_number, verse_number,
              book_name, text_content, normalized_text
            ) VALUES (?, ?, ?, ?, ?, ?, ?)
            ''',
            [
              translationId,
              chapter.bookId,
              chapter.chapterNumber,
              v.number,
              chapter.bookName,
              v.text,
              TextNormalizer.normalizeForSearch(v.text),
            ],
          );
        }
      }
    });
  }

  /// Searches the FTS5 virtual table for matching verses, optionally filtered
  /// by a set of allowed [bookIds].
  Future<List<FtsSearchResult>> searchVerses({
    required String translationId,
    required String query,
    Set<String>? bookIds,
    int limit = 50,
  }) async {
    final cleanQuery = query.replaceAll('"', '""').trim();
    if (cleanQuery.isEmpty) return [];

    final ftsQuery = cleanQuery
        .split(' ')
        .where((t) => t.isNotEmpty)
        .map((t) => '"$t"*')
        .join(' ');

    final hasBookFilter = bookIds != null && bookIds.isNotEmpty;
    final bookFilterClause = hasBookFilter
        ? 'AND book_id IN (${bookIds.map((id) => "'$id'").join(',')})'
        : '';

    try {
      final rows = await customSelect(
        '''
        SELECT translation_id, book_id, chapter_number, verse_number,
               book_name, text_content,
               snippet(fts_verses, 5, '<b>', '</b>', '...', 15) as snippet
        FROM fts_verses
        WHERE translation_id = ? AND fts_verses MATCH ? $bookFilterClause
        ORDER BY rank
        LIMIT ?
        ''',
        variables: [
          Variable.withString(translationId),
          Variable.withString(ftsQuery),
          Variable.withInt(limit),
        ],
        readsFrom: {cachedVerses},
      ).get();

      return rows
          .map(
            (r) => FtsSearchResult(
              translationId: r.read<String>('translation_id'),
              bookId: r.read<String>('book_id'),
              chapterNumber: r.read<int>('chapter_number'),
              verseNumber: r.read<int>('verse_number'),
              bookName: r.read<String>('book_name'),
              textContent: r.read<String>('text_content'),
              snippet: r.read<String>('snippet'),
            ),
          )
          .toList();
    } catch (_) {
      final normalizedQuery = '%${TextNormalizer.normalizeForSearch(cleanQuery)}%';
      final rows = await (select(cachedVerses)
            ..where(
              (tbl) {
                var condition = tbl.translationId.equals(translationId) &
                    tbl.normalizedText.like(normalizedQuery);
                if (hasBookFilter) {
                  condition = condition & tbl.bookId.isIn(bookIds);
                }
                return condition;
              },
            )
            ..limit(limit))
          .get();

      return rows
          .map(
            (r) => FtsSearchResult(
              translationId: r.translationId,
              bookId: r.bookId,
              chapterNumber: r.chapterNumber,
              verseNumber: r.verseNumber,
              bookName: '',
              textContent: r.textContent,
              snippet: r.textContent,
            ),
          )
          .toList();
    }
  }
}

/// Structured search hit returned by the FTS5 full-text index.
class FtsSearchResult {
  const FtsSearchResult({
    required this.translationId,
    required this.bookId,
    required this.chapterNumber,
    required this.verseNumber,
    required this.bookName,
    required this.textContent,
    required this.snippet,
  });

  final String translationId;
  final String bookId;
  final int chapterNumber;
  final int verseNumber;
  final String bookName;
  final String textContent;
  final String snippet;

  String get reference => '$bookName $chapterNumber:$verseNumber';
}

