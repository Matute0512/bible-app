import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bible_app/database/app_database.dart';
import 'package:bible_app/repositories/study_repository.dart';

void main() {
  late AppDatabase db;
  late StudyRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = StudyRepository(studyDao: db.studyDao);
  });

  tearDown(() async {
    await db.close();
  });

  group('StudyRepository', () {
    test('toggleFavorite updates favorite status and retrieves it', () async {
      final isFav = await repository.toggleFavorite(
        bookId: 'GEN',
        chapterNumber: 1,
        verseNumber: 1,
        originTranslationId: 'spa_rvg',
        bookNameSnapshot: 'Génesis',
        verseTextSnapshot: 'En el principio...',
      );
      expect(isFav, isTrue);

      final favs = await repository.getAllFavorites();
      expect(favs.length, 1);
      expect(favs.first.bookId, 'GEN');
      expect(favs.first.verseNumber, 1);
    });

    test('setHighlight and saveNote create combined annotation and filter properly', () async {
      // Highlight verse 1
      await repository.setHighlight(
        bookId: 'PSA',
        chapterNumber: 23,
        verseNumber: 1,
        highlightColor: 'ochre',
        originTranslationId: 'spa_rvg',
        bookNameSnapshot: 'Salmos',
        verseTextSnapshot: 'Jehová es mi pastor...',
      );

      // Add note to verse 1
      await repository.saveNote(
        bookId: 'PSA',
        chapterNumber: 23,
        verseNumber: 1,
        noteText: 'Confianza plena',
        originTranslationId: 'spa_rvg',
        bookNameSnapshot: 'Salmos',
        verseTextSnapshot: 'Jehová es mi pastor...',
      );

      // Highlight verse 2 with terracotta
      await repository.setHighlight(
        bookId: 'PSA',
        chapterNumber: 23,
        verseNumber: 2,
        highlightColor: 'terracotta',
        originTranslationId: 'spa_rvg',
        bookNameSnapshot: 'Salmos',
        verseTextSnapshot: 'En lugares de delicados pastos...',
      );

      final chapterAnnotations = await repository.getAnnotationsForChapter(
        bookId: 'PSA',
        chapterNumber: 23,
      );
      expect(chapterAnnotations.length, 2);
      expect(chapterAnnotations[1]!.highlightColor, 'ochre');
      expect(chapterAnnotations[1]!.noteText, 'Confianza plena');
      expect(chapterAnnotations[2]!.highlightColor, 'terracotta');

      final ochreHighlights = await repository.getHighlights(color: 'ochre');
      expect(ochreHighlights.length, 1);
      expect(ochreHighlights.first.verseNumber, 1);

      final allNotes = await repository.getAllNotes();
      expect(allNotes.length, 1);
      expect(allNotes.first.noteText, 'Confianza plena');
    });
  });
}
