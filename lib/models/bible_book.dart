/// A book of the Bible as returned by the `books.json` endpoint.
class BibleBook {
  const BibleBook({
    required this.id,
    required this.name,
    required this.chapterCount,
    required this.order,
  });

  /// API id used in chapter URL paths (e.g. `LUK`).
  final String id;

  /// Display name in the translation's language (e.g. `Lucas`).
  final String name;

  /// Number of chapters the book contains.
  final int chapterCount;

  /// Position of the book within the translation's canon (1-based).
  final int order;

  /// Parses a book from one element of the `books` array.
  factory BibleBook.fromJson(Map<String, dynamic> json) => BibleBook(
        id: json['id'] as String,
        name: json['name'] as String,
        chapterCount: json['numberOfChapters'] as int,
        order: json['order'] as int,
      );
}
