import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bible_app/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('StudyDao', () {
    test('toggleFavorite marks and unmarks verse as favorite', () async {
      final dao = db.studyDao;

      final isFav1 = await dao.toggleFavorite(
        bookId: 'GEN',
        chapterNumber: 1,
        verseNumber: 1,
        originTranslationId: 'spa_rvg',
        bookNameSnapshot: 'Génesis',
        verseTextSnapshot: 'En el principio...',
      );
      expect(isFav1, isTrue);

      final annotation = await dao.getAnnotation(
        bookId: 'GEN',
        chapterNumber: 1,
        verseNumber: 1,
      );
      expect(annotation, isNotNull);
      expect(annotation!.isFavorite, isTrue);
      expect(annotation.bookId, 'GEN');

      // Toggle off
      final isFav2 = await dao.toggleFavorite(
        bookId: 'GEN',
        chapterNumber: 1,
        verseNumber: 1,
        originTranslationId: 'spa_rvg',
        bookNameSnapshot: 'Génesis',
        verseTextSnapshot: 'En el principio...',
      );
      expect(isFav2, isFalse);

      // Cleared row removes automatically since no highlight or note
      final after = await dao.getAnnotation(
        bookId: 'GEN',
        chapterNumber: 1,
        verseNumber: 1,
      );
      expect(after, isNull);
    });

    test('setHighlight assigns color and clears when null', () async {
      final dao = db.studyDao;

      await dao.setHighlight(
        bookId: 'JHN',
        chapterNumber: 3,
        verseNumber: 16,
        highlightColor: 'ochre',
        originTranslationId: 'spa_rvg',
        bookNameSnapshot: 'Juan',
        verseTextSnapshot: 'Porque de tal manera...',
      );

      var annotation = await dao.getAnnotation(
        bookId: 'JHN',
        chapterNumber: 3,
        verseNumber: 16,
      );
      expect(annotation, isNotNull);
      expect(annotation!.highlightColor, 'ochre');
      expect(annotation.hasHighlight, isTrue);

      // Clear highlight
      await dao.setHighlight(
        bookId: 'JHN',
        chapterNumber: 3,
        verseNumber: 16,
        highlightColor: null,
        originTranslationId: 'spa_rvg',
        bookNameSnapshot: 'Juan',
        verseTextSnapshot: 'Porque de tal manera...',
      );

      annotation = await dao.getAnnotation(
        bookId: 'JHN',
        chapterNumber: 3,
        verseNumber: 16,
      );
      expect(annotation, isNull);
    });

    test('saveNote persists note and preserves favorite and highlight', () async {
      final dao = db.studyDao;

      // 1. Set highlight
      await dao.setHighlight(
        bookId: 'ROM',
        chapterNumber: 8,
        verseNumber: 28,
        highlightColor: 'olive',
        originTranslationId: 'spa_rvg',
        bookNameSnapshot: 'Romanos',
        verseTextSnapshot: 'Y sabemos que a los que aman a Dios...',
      );

      // 2. Add note
      await dao.saveNote(
        bookId: 'ROM',
        chapterNumber: 8,
        verseNumber: 28,
        noteText: 'Promesa fundamental de providencia',
        tagsCsv: 'promesa,fe',
        originTranslationId: 'spa_rvg',
        bookNameSnapshot: 'Romanos',
        verseTextSnapshot: 'Y sabemos que a los que aman a Dios...',
      );

      final annotation = await dao.getAnnotation(
        bookId: 'ROM',
        chapterNumber: 8,
        verseNumber: 28,
      );
      expect(annotation, isNotNull);
      expect(annotation!.highlightColor, 'olive');
      expect(annotation.noteText, 'Promesa fundamental de providencia');
      expect(annotation.tags, ['promesa', 'fe']);

      // 3. Chapter annotations map includes ROM 8:28
      final chapterMap = await dao.getAnnotationsForChapter(
        bookId: 'ROM',
        chapterNumber: 8,
      );
      expect(chapterMap.containsKey(28), isTrue);
      expect(chapterMap[28]!.noteText, contains('providencia'));
    });

    test('Canonical coordinates work across translations', () async {
      final dao = db.studyDao;

      // User creates note while reading in spa_rvg
      await dao.saveNote(
        bookId: 'PSA',
        chapterNumber: 23,
        verseNumber: 1,
        noteText: 'El Señor es mi pastor',
        originTranslationId: 'spa_rvg',
        bookNameSnapshot: 'Salmos',
        verseTextSnapshot: 'Jehová es mi pastor; nada me faltará.',
      );

      // Reading in spa_blm: coordinate is PSA 23:1
      final found = await dao.getAnnotation(
        bookId: 'PSA',
        chapterNumber: 23,
        verseNumber: 1,
      );
      expect(found, isNotNull);
      expect(found!.noteText, 'El Señor es mi pastor');
    });
  });
}

