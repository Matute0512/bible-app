import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bible_app/database/app_database.dart';
import 'package:bible_app/services/backup_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BackupService Tests', () {
    late AppDatabase db;
    const service = BackupService();

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('exportUserDataJson serializes annotations, history, and plans', () async {
      // 1. Insert sample annotation
      await db.into(db.verseAnnotations).insert(
            VerseAnnotationsCompanion.insert(
              id: 'JHN:3:16',
              bookId: 'JHN',
              chapterNumber: 3,
              verseNumber: 16,
              isFavorite: const Value(true),
              highlightColor: const Value('#FFD54F'),
              noteText: const Value('Versículo central de la redención'),
              tagsCsv: const Value('Evangelio'),
              originTranslationId: 'spa_rvg',
              bookNameSnapshot: 'Juan',
              verseTextSnapshot: 'Porque de tal manera amó Dios...',
              createdAtMs: 1700000000,
              updatedAtMs: 1700000000,
            ),
          );

      // 2. Insert sample history
      await db.into(db.readingHistory).insert(
            ReadingHistoryCompanion.insert(
              bookId: 'GEN',
              chapterNumber: 1,
              translationId: 'spa_rvg',
              readingDateIso: '2026-11-04',
              readAtMs: 1700000000,
              durationSeconds: const Value(120),
              source: const Value('daily_plan'),
            ),
          );

      // 3. Insert sample plan
      await db.into(db.userReadingPlans).insert(
            UserReadingPlansCompanion.insert(
              planId: 'salmos_30_dias',
              status: 'active',
              startedAtMs: 1700000000,
              completedDaysJson: const Value('[1,2,3]'),
            ),
          );

      // 4. Export JSON
      final jsonStr = await service.exportUserDataJson(db);
      expect(jsonStr.isNotEmpty, isTrue);

      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      expect(decoded['version'], 1);
      expect(decoded['app'], 'bible_app');

      final data = decoded['data'] as Map<String, dynamic>;
      final annotations = data['annotations'] as List;
      final history = data['history'] as List;
      final plans = data['plans'] as List;

      expect(annotations.length, 1);
      expect(annotations.first['id'], 'JHN:3:16');
      expect(annotations.first['bookId'], 'JHN');
      expect(annotations.first['isFavorite'], isTrue);
      expect(annotations.first['noteText'], 'Versículo central de la redención');

      expect(history.length, 1);
      expect(history.first['bookId'], 'GEN');
      expect(history.first['chapterNumber'], 1);

      expect(plans.length, 1);
      expect(plans.first['planId'], 'salmos_30_dias');
      expect(plans.first['completedDaysJson'], '[1,2,3]');
    });

    test('importUserDataJson restores data into fresh database faithfully', () async {
      final freshDb = AppDatabase(NativeDatabase.memory());
      addTearDown(freshDb.close);

      final backupPayload = jsonEncode({
        'version': 1,
        'app': 'bible_app',
        'exportedAt': '2026-11-04T12:00:00Z',
        'data': {
          'annotations': [
            {
              'id': 'PSA:23:1',
              'bookId': 'PSA',
              'chapterNumber': 23,
              'verseNumber': 1,
              'isFavorite': true,
              'highlightColor': '#81C784',
              'noteText': 'El Señor es mi pastor',
              'tagsCsv': 'Consuelo',
              'originTranslationId': 'spa_rvg',
              'bookNameSnapshot': 'Salmos',
              'verseTextSnapshot': 'El Señor es mi pastor; nada me faltará.',
              'createdAtMs': 1700001000,
              'updatedAtMs': 1700001000,
            },
            {
              'id': 'ROM:8:28',
              'bookId': 'ROM',
              'chapterNumber': 8,
              'verseNumber': 28,
              'isFavorite': false,
              'highlightColor': '#FFB74D',
              'noteText': 'A los que aman a Dios todas las cosas ayudan a bien',
              'tagsCsv': 'Promesas',
              'originTranslationId': 'spa_rvg',
              'bookNameSnapshot': 'Romanos',
              'verseTextSnapshot': 'Y sabemos que a los que aman a Dios...',
              'createdAtMs': 1700002000,
              'updatedAtMs': 1700002000,
            }
          ],
          'history': [
            {
              'bookId': 'PSA',
              'chapterNumber': 23,
              'translationId': 'spa_rvg',
              'readingDateIso': '2026-11-04',
              'readAtMs': 1700001000,
              'durationSeconds': 90,
              'source': 'thematic_plan',
              'planId': 'salmos_30_dias',
            }
          ],
          'plans': [
            {
              'planId': 'salmos_30_dias',
              'status': 'active',
              'startedAtMs': 1700001000,
              'completedAtMs': null,
              'completedDaysJson': '[1,4]',
            }
          ]
        }
      });

      final result = await service.importUserDataJson(freshDb, backupPayload);
      expect(result.annotationsCount, 2);
      expect(result.historyCount, 1);
      expect(result.plansCount, 1);
      expect(result.totalRecords, 4);

      // Verify records exist in database
      final annotations = await freshDb.select(freshDb.verseAnnotations).get();
      expect(annotations.length, 2);
      expect(annotations.any((a) => a.id == 'PSA:23:1'), isTrue);
      expect(annotations.any((a) => a.id == 'ROM:8:28'), isTrue);

      final history = await freshDb.select(freshDb.readingHistory).get();
      expect(history.length, 1);
      expect(history.first.bookId, 'PSA');
      expect(history.first.chapterNumber, 23);

      final plans = await freshDb.select(freshDb.userReadingPlans).get();
      expect(plans.length, 1);
      expect(plans.first.planId, 'salmos_30_dias');
      expect(plans.first.completedDaysJson, '[1,4]');
    });

    test('importUserDataJson throws FormatException on invalid payload', () async {
      expect(
        () => service.importUserDataJson(db, '{"invalid": true}'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
