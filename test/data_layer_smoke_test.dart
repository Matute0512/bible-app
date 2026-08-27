import 'dart:convert';
import 'dart:io';

import 'package:bible_app/models/bible_book.dart';
import 'package:bible_app/models/bible_chapter.dart';
import 'package:bible_app/services/reading_plan_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Smoke tests that validate the data layer against real responses captured
/// from the Free Use Bible API (kept under `test/fixtures/`).
void main() {
  Map<String, dynamic> readJson(String fileName) {
    final file = File('test/fixtures/$fileName');
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  group('BibleBook parsing (live spa_rvg, 66 books)', () {
    test('parses id, name, chapterCount and order', () {
      final json = readJson('spa_rvg_books.json');
      final books = (json['books'] as List)
          .map((e) => BibleBook.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(books.length, 66);
      expect(books.first.id, 'GEN');
      expect(books.first.name, contains('Génesis'));
      expect(books.first.chapterCount, 50);
      expect(books.first.order, 1);

      final luke = books.firstWhere((b) => b.id == 'LUK');
      expect(luke.name, contains('Lucas'));
      expect(luke.chapterCount, 24);
    });
  });

  group('Catholic canon filter (live spa_blm, 81 books)', () {
    test('keeps exactly the 73 books of the Catholic canon', () {
      final json = readJson('spa_blm_books.json');
      final books = (json['books'] as List)
          .map((e) => BibleBook.fromJson(e as Map<String, dynamic>))
          .toList();
      expect(books.length, 81);

      final canonical = books
          .where((b) => ReadingPlanService.catholicCanonBookIds.contains(b.id))
          .toList();
      expect(canonical.length, 73);

      const excluded = {'ESG', '3MA', '4MA', '1ES', '2ES', 'MAN', 'PS2', 'DAG'};
      for (final id in excluded) {
        expect(canonical.any((b) => b.id == id), isFalse,
            reason: '$id should have been excluded');
      }

      const deuterocanonical = {'TOB', 'JDT', 'WIS', 'SIR', 'BAR', '1MA', '2MA'};
      for (final id in deuterocanonical) {
        expect(canonical.any((b) => b.id == id), isTrue,
            reason: '$id should have been kept');
      }
    });
  });

  group('BibleChapter parsing (live LUK/4.simple.json)', () {
    test('parses all 44 verses with number and text', () {
      final json = readJson('luk4_simple.json');
      final chapter = BibleChapter.fromSimpleJson(
        json,
        bookId: 'LUK',
        bookName: 'Lucas',
        chapterNumber: 4,
      );

      expect(chapter.verses.length, 44);
      expect(chapter.verses.first.number, 1);
      expect(chapter.verses.first.text, startsWith('Y Jesús'));
      expect(chapter.reference, 'Lucas 4');
    });

    test('tolerates the simpler { "chapter": [ {number, text} ] } shape', () {
      final chapter = BibleChapter.fromSimpleJson(
        {
          'chapter': [
            {'number': 1, 'text': 'Texto del versículo uno.'},
            {'number': 2, 'text': 'Texto del versículo dos.'},
          ],
        },
        bookId: 'LUK',
        bookName: 'Lucas',
        chapterNumber: 4,
      );

      expect(chapter.verses.length, 2);
      expect(chapter.verses[1].number, 2);
    });
  });
}
