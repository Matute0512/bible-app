import 'verse.dart';

/// A chapter of a Bible book together with the verses it contains.
class BibleChapter {
  const BibleChapter({
    required this.bookId,
    required this.bookName,
    required this.chapterNumber,
    required this.verses,
  });

  /// API id of the book this chapter belongs to (e.g. `LUK`).
  final String bookId;

  /// Human-readable book name, as returned by the translation.
  final String bookName;

  /// 1-based chapter number within the book.
  final int chapterNumber;

  /// The verses of the chapter, in reading order.
  final List<Verse> verses;

  /// Short reference for display and semantics, e.g. `Lucas 4`.
  String get reference => '$bookName $chapterNumber';

  /// Parses a chapter from a `*.simple.json` payload.
  ///
  /// The live API returns `chapter` as an object:
  ///
  /// ```json
  /// {
  ///   "chapter": {
  ///     "number": 4,
  ///     "content": [
  ///       { "type": "verse", "number": 1, "text": "..." }
  ///     ]
  ///   }
  /// }
  /// ```
  ///
  /// Only items with `type == 'verse'` are kept; headings and line breaks are
  /// skipped. As a defensive fallback, a payload where `chapter` is a bare
  /// list of `{ "number": ..., "text": ... }` objects is also accepted.
  factory BibleChapter.fromSimpleJson(
    Map<String, dynamic> json, {
    required String bookId,
    required String bookName,
    required int chapterNumber,
  }) {
    final chapter = json['chapter'];
    final List<Verse> verses;

    if (chapter is List) {
      verses = chapter
          .whereType<Map<String, dynamic>>()
          .map(Verse.fromJson)
          .toList(growable: false);
    } else if (chapter is Map<String, dynamic>) {
      final content = chapter['content'];
      verses = content is List
          ? content
              .whereType<Map<String, dynamic>>()
              .where((item) => item['type'] == null || item['type'] == 'verse')
              .map(Verse.fromJson)
              .toList(growable: false)
          : const [];
    } else {
      verses = const [];
    }

    return BibleChapter(
      bookId: bookId,
      bookName: bookName,
      chapterNumber: chapterNumber,
      verses: verses,
    );
  }
}
