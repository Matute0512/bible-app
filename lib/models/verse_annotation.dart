import 'package:flutter/foundation.dart';

/// Supported editorial highlight colors.
enum HighlightColor {
  ochre('ochre', 'Ocre'),
  olive('olive', 'Oliva'),
  terracotta('terracotta', 'Terracota'),
  indigo('indigo', 'Índigo');

  const HighlightColor(this.code, this.label);

  final String code;
  final String label;

  static HighlightColor? fromCode(String? code) {
    if (code == null) return null;
    for (final color in values) {
      if (color.code == code.toLowerCase()) return color;
    }
    return null;
  }
}

/// Domain model representing a user highlight, favorite, or personal study note
/// attached to a specific biblical verse.
@immutable
class VerseAnnotation {
  const VerseAnnotation({
    required this.id,
    required this.bookId,
    required this.chapterNumber,
    required this.verseNumber,
    this.isFavorite = false,
    this.highlightColor,
    this.noteText,
    this.tagsCsv,
    required this.originTranslationId,
    required this.bookNameSnapshot,
    required this.verseTextSnapshot,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Canonical coordinate identifier, e.g. "GEN:1:1".
  final String id;
  final String bookId;
  final int chapterNumber;
  final int verseNumber;
  final bool isFavorite;

  /// Highlight color name: 'ochre' | 'olive' | 'terracotta' | 'indigo' | null
  final String? highlightColor;

  /// User note content.
  final String? noteText;

  /// Comma-separated tags, e.g. "esperanza,oracion".
  final String? tagsCsv;

  /// Translation used when the annotation was first created.
  final String originTranslationId;

  /// Book display name snapshot when annotated (e.g. "Génesis").
  final String bookNameSnapshot;

  /// Verse text snapshot when annotated.
  final String verseTextSnapshot;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Helper key for coordinate map indexing.
  static String coordinateId(
    String bookId,
    int chapterNumber,
    int verseNumber,
  ) => '$bookId:$chapterNumber:$verseNumber';

  bool get hasHighlight => highlightColor != null && highlightColor!.isNotEmpty;

  bool get hasNote => noteText != null && noteText!.trim().isNotEmpty;

  bool get hasAnnotation => isFavorite || hasHighlight || hasNote;

  List<String> get tags {
    if (tagsCsv == null || tagsCsv!.trim().isEmpty) return const [];
    return tagsCsv!
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }

  VerseAnnotation copyWith({
    String? id,
    String? bookId,
    int? chapterNumber,
    int? verseNumber,
    bool? isFavorite,
    String? Function()? highlightColor,
    String? Function()? noteText,
    String? Function()? tagsCsv,
    String? originTranslationId,
    String? bookNameSnapshot,
    String? verseTextSnapshot,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VerseAnnotation(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      verseNumber: verseNumber ?? this.verseNumber,
      isFavorite: isFavorite ?? this.isFavorite,
      highlightColor: highlightColor != null
          ? highlightColor()
          : this.highlightColor,
      noteText: noteText != null ? noteText() : this.noteText,
      tagsCsv: tagsCsv != null ? tagsCsv() : this.tagsCsv,
      originTranslationId: originTranslationId ?? this.originTranslationId,
      bookNameSnapshot: bookNameSnapshot ?? this.bookNameSnapshot,
      verseTextSnapshot: verseTextSnapshot ?? this.verseTextSnapshot,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerseAnnotation &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          bookId == other.bookId &&
          chapterNumber == other.chapterNumber &&
          verseNumber == other.verseNumber &&
          isFavorite == other.isFavorite &&
          highlightColor == other.highlightColor &&
          noteText == other.noteText &&
          tagsCsv == other.tagsCsv &&
          originTranslationId == other.originTranslationId &&
          bookNameSnapshot == other.bookNameSnapshot &&
          verseTextSnapshot == other.verseTextSnapshot;

  @override
  int get hashCode =>
      id.hashCode ^
      bookId.hashCode ^
      chapterNumber.hashCode ^
      verseNumber.hashCode ^
      isFavorite.hashCode ^
      highlightColor.hashCode ^
      noteText.hashCode ^
      tagsCsv.hashCode ^
      originTranslationId.hashCode ^
      bookNameSnapshot.hashCode ^
      verseTextSnapshot.hashCode;

  @override
  String toString() =>
      'VerseAnnotation($id, fav: $isFavorite, hl: $highlightColor, hasNote: $hasNote)';
}
