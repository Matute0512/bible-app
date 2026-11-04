import 'dart:async';

import '../database/daos/bible_cache_dao.dart';
import '../models/bible_book.dart';
import '../models/bible_chapter.dart';
import '../services/bible_api_service.dart';

/// Lightweight value object representing a target chapter location.
class ChapterTarget {
  const ChapterTarget({
    required this.bookId,
    required this.bookName,
    required this.chapterNumber,
  });

  final String bookId;
  final String bookName;
  final int chapterNumber;
}

/// Offline-first repository for biblical books and chapters.
///
/// Implements cache-first resolution with automatic background caching,
/// request deduplication for in-flight network queries, and sequential
/// canonical chapter navigation across books.
class BibleRepository {
  BibleRepository({
    required this.api,
    required this.cache,
  });

  final BibleApiService api;
  final BibleCacheDao cache;

  final Map<String, Future<BibleChapter>> _inFlightChapters = {};
  final Map<String, Future<List<BibleBook>>> _inFlightBooks = {};

  /// Retrieves books for [translationId], serving from local SQLite cache if available.
  Future<List<BibleBook>> getBooks(
    String translationId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final hasCached = await cache.hasBooks(translationId);
      if (hasCached) {
        return cache.getCachedBooks(translationId);
      }
    }

    if (_inFlightBooks.containsKey(translationId)) {
      return _inFlightBooks[translationId]!;
    }

    final future = _fetchAndCacheBooks(translationId);
    _inFlightBooks[translationId] = future;

    try {
      return await future;
    } finally {
      _inFlightBooks.remove(translationId);
    }
  }

  Future<List<BibleBook>> _fetchAndCacheBooks(String translationId) async {
    try {
      final books = await api.fetchBooks(translationId);
      await cache.saveBooks(translationId, books);
      return books;
    } catch (e) {
      // Fallback to cache if network fails and cache has items
      final hasCached = await cache.hasBooks(translationId);
      if (hasCached) {
        return cache.getCachedBooks(translationId);
      }
      rethrow;
    }
  }

  /// Retrieves a complete chapter with its verses.
  ///
  /// Checks local SQLite cache first. If missing, fetches from API, persists
  /// into SQLite & FTS5 full-text index, and returns the result.
  Future<BibleChapter> getChapter({
    required String translationId,
    required String bookId,
    required String bookName,
    required int chapterNumber,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = await cache.getCachedChapter(
        translationId: translationId,
        bookId: bookId,
        chapterNumber: chapterNumber,
      );
      if (cached != null) {
        return cached;
      }
    }

    final key = '$translationId:$bookId:$chapterNumber';
    if (_inFlightChapters.containsKey(key)) {
      return _inFlightChapters[key]!;
    }

    final future = _fetchAndCacheChapter(
      translationId: translationId,
      bookId: bookId,
      bookName: bookName,
      chapterNumber: chapterNumber,
    );
    _inFlightChapters[key] = future;

    try {
      return await future;
    } finally {
      _inFlightChapters.remove(key);
    }
  }

  Future<BibleChapter> _fetchAndCacheChapter({
    required String translationId,
    required String bookId,
    required String bookName,
    required int chapterNumber,
  }) async {
    try {
      final chapter = await api.fetchChapter(
        translationId: translationId,
        bookId: bookId,
        bookName: bookName,
        chapterNumber: chapterNumber,
      );
      await cache.saveChapter(translationId, chapter);
      return chapter;
    } catch (e) {
      // Offline fallback: if chapter exists in cache, return it
      final cached = await cache.getCachedChapter(
        translationId: translationId,
        bookId: bookId,
        chapterNumber: chapterNumber,
      );
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  /// Checks if a chapter is downloaded and available offline.
  /// Returns a set of all cached chapter numbers for [bookId] and [translationId].
  Future<Set<int>> getCachedChapterNumbers({
    required String translationId,
    required String bookId,
  }) {
    return cache.getCachedChapterNumbers(
      translationId: translationId,
      bookId: bookId,
    );
  }

  Future<bool> isChapterCached({
    required String translationId,
    required String bookId,
    required int chapterNumber,
  }) {
    return cache.hasChapter(
      translationId: translationId,
      bookId: bookId,
      chapterNumber: chapterNumber,
    );
  }

  /// Resolves the next chronological chapter in canonical order.
  ///
  /// If the current book ends, seamlessly transitions to Chapter 1 of the
  /// next book. If the canon ends, wraps around to Chapter 1 of the first book.
  Future<ChapterTarget> resolveNextChapter({
    required String translationId,
    required String currentBookId,
    required int currentChapter,
  }) async {
    final books = await getBooks(translationId);
    final bookIndex = books.indexWhere((b) => b.id == currentBookId);
    if (bookIndex < 0) {
      return ChapterTarget(
        bookId: currentBookId,
        bookName: '',
        chapterNumber: currentChapter + 1,
      );
    }

    final currentBook = books[bookIndex];

    if (currentChapter < currentBook.chapterCount) {
      return ChapterTarget(
        bookId: currentBook.id,
        bookName: currentBook.name,
        chapterNumber: currentChapter + 1,
      );
    }

    // Move to next book in canon
    final nextBookIndex = (bookIndex + 1) % books.length;
    final nextBook = books[nextBookIndex];
    return ChapterTarget(
      bookId: nextBook.id,
      bookName: nextBook.name,
      chapterNumber: 1,
    );
  }

  /// Resolves the previous chronological chapter in canonical order.
  ///
  /// If at Chapter 1 of a book, seamlessly transitions to the last chapter
  /// of the preceding book. If at the first book, wraps around to the last
  /// chapter of the final book.
  Future<ChapterTarget> resolvePreviousChapter({
    required String translationId,
    required String currentBookId,
    required int currentChapter,
  }) async {
    final books = await getBooks(translationId);
    final bookIndex = books.indexWhere((b) => b.id == currentBookId);
    if (bookIndex < 0) {
      return ChapterTarget(
        bookId: currentBookId,
        bookName: '',
        chapterNumber: (currentChapter - 1).clamp(1, 999),
      );
    }

    final currentBook = books[bookIndex];

    if (currentChapter > 1) {
      return ChapterTarget(
        bookId: currentBook.id,
        bookName: currentBook.name,
        chapterNumber: currentChapter - 1,
      );
    }

    // Move to previous book in canon
    final prevBookIndex = (bookIndex - 1 + books.length) % books.length;
    final prevBook = books[prevBookIndex];
    return ChapterTarget(
      bookId: prevBook.id,
      bookName: prevBook.name,
      chapterNumber: prevBook.chapterCount,
    );
  }
}
