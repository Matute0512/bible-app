import 'package:flutter_test/flutter_test.dart';
import 'package:bible_app/utils/text_normalizer.dart';
import 'package:bible_app/models/bible_book.dart';

void main() {
  group('TextNormalizer', () {
    test('toTitleCase converts ALL CAPS words to Title Case', () {
      expect(TextNormalizer.toTitleCase('GÉNESIS'), equals('Génesis'));
      expect(TextNormalizer.toTitleCase('SAN MATEO'), equals('San Mateo'));
      expect(TextNormalizer.toTitleCase('1 CORINTIOS'), equals('1 Corintios'));
      expect(TextNormalizer.toTitleCase('2 REYES'), equals('2 Reyes'));
      expect(TextNormalizer.toTitleCase('CANTAR DE LOS CANTARES'), equals('Cantar de los Cantares'));
    });

    test('toTitleCase preserves already title-cased names', () {
      expect(TextNormalizer.toTitleCase('Tobit'), equals('Tobit'));
      expect(TextNormalizer.toTitleCase('Judit'), equals('Judit'));
      expect(TextNormalizer.toTitleCase('1 Macabeos'), equals('1 Macabeos'));
    });

    test('normalizeForSearch strips diacritics and converts to lowercase', () {
      expect(TextNormalizer.normalizeForSearch('Génesis'), equals('genesis'));
      expect(TextNormalizer.normalizeForSearch('Éxodo'), equals('exodo'));
      expect(TextNormalizer.normalizeForSearch('SAN MATEO'), equals('san mateo'));
      expect(TextNormalizer.normalizeForSearch('Espíritu'), equals('espiritu'));
      expect(TextNormalizer.normalizeForSearch('Corazón'), equals('corazon'));
    });
  });

  group('BibleBook.displayName', () {
    test('formats all-caps BLM book names to Title Case', () {
      const book1 = BibleBook(
        id: 'GEN',
        name: 'GÉNESIS',
        chapterCount: 50,
        order: 1,
      );
      expect(book1.displayName, equals('Génesis'));

      const book2 = BibleBook(
        id: '1CO',
        name: '1 CORINTIOS',
        chapterCount: 16,
        order: 46,
      );
      expect(book2.displayName, equals('1 Corintios'));
    });

    test('keeps title-cased deuterocanonical book names intact', () {
      const book = BibleBook(
        id: 'TOB',
        name: 'Tobit',
        chapterCount: 14,
        order: 17,
      );
      expect(book.displayName, equals('Tobit'));
    });
  });
}

