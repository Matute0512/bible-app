import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../database/app_database.dart';

/// Result summary of an import operation.
class BackupImportResult {
  final int annotationsCount;
  final int historyCount;
  final int plansCount;

  const BackupImportResult({
    required this.annotationsCount,
    required this.historyCount,
    required this.plansCount,
  });

  int get totalRecords => annotationsCount + historyCount + plansCount;
}

/// Service for exporting and importing personal devotional data in portable JSON.
class BackupService {
  const BackupService();

  /// Serializes all user study annotations, reading history, and plan progress
  /// into an organized JSON string.
  Future<String> exportUserDataJson(AppDatabase db) async {
    final annotations = await db.select(db.verseAnnotations).get();
    final history = await db.select(db.readingHistory).get();
    final plans = await db.select(db.userReadingPlans).get();

    final exportData = {
      'version': 1,
      'app': 'bible_app',
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'data': {
        'annotations': annotations
            .map((a) => {
                  'id': a.id,
                  'bookId': a.bookId,
                  'chapterNumber': a.chapterNumber,
                  'verseNumber': a.verseNumber,
                  'isFavorite': a.isFavorite,
                  'highlightColor': a.highlightColor,
                  'noteText': a.noteText,
                  'tagsCsv': a.tagsCsv,
                  'originTranslationId': a.originTranslationId,
                  'bookNameSnapshot': a.bookNameSnapshot,
                  'verseTextSnapshot': a.verseTextSnapshot,
                  'createdAtMs': a.createdAtMs,
                  'updatedAtMs': a.updatedAtMs,
                })
            .toList(),
        'history': history
            .map((h) => {
                  'bookId': h.bookId,
                  'chapterNumber': h.chapterNumber,
                  'translationId': h.translationId,
                  'readingDateIso': h.readingDateIso,
                  'readAtMs': h.readAtMs,
                  'durationSeconds': h.durationSeconds,
                  'source': h.source,
                  'planId': h.planId,
                })
            .toList(),
        'plans': plans
            .map((p) => {
                  'planId': p.planId,
                  'status': p.status,
                  'startedAtMs': p.startedAtMs,
                  'completedAtMs': p.completedAtMs,
                  'completedDaysJson': p.completedDaysJson,
                })
            .toList(),
      },
    };

    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  /// Restores user data from a valid JSON string inside a database transaction.
  Future<BackupImportResult> importUserDataJson(
    AppDatabase db,
    String jsonString,
  ) async {
    final dynamic decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic> || !decoded.containsKey('data')) {
      throw const FormatException('Archivo de respaldo con formato inválido.');
    }

    final data = decoded['data'] as Map<String, dynamic>;
    final rawAnnotations = data['annotations'] as List<dynamic>? ?? [];
    final rawHistory = data['history'] as List<dynamic>? ?? [];
    final rawPlans = data['plans'] as List<dynamic>? ?? [];

    await db.transaction(() async {
      // 1. Restore annotations
      for (final raw in rawAnnotations) {
        if (raw is Map<String, dynamic>) {
          final bookId = raw['bookId'] as String? ?? 'GEN';
          final ch = raw['chapterNumber'] as int? ?? 1;
          final v = raw['verseNumber'] as int? ?? 1;
          final id = raw['id'] as String? ?? '$bookId:$ch:$v';

          await db.into(db.verseAnnotations).insertOnConflictUpdate(
                VerseAnnotationsCompanion.insert(
                  id: id,
                  bookId: bookId,
                  chapterNumber: ch,
                  verseNumber: v,
                  isFavorite: Value(raw['isFavorite'] as bool? ?? false),
                  highlightColor: Value(raw['highlightColor'] as String?),
                  noteText: Value(raw['noteText'] as String?),
                  tagsCsv: Value(raw['tagsCsv'] as String?),
                  originTranslationId:
                      raw['originTranslationId'] as String? ?? 'spa_rvg',
                  bookNameSnapshot:
                      raw['bookNameSnapshot'] as String? ?? bookId,
                  verseTextSnapshot:
                      raw['verseTextSnapshot'] as String? ?? '',
                  createdAtMs: raw['createdAtMs'] as int? ??
                      DateTime.now().millisecondsSinceEpoch,
                  updatedAtMs: raw['updatedAtMs'] as int? ??
                      DateTime.now().millisecondsSinceEpoch,
                ),
              );
        }
      }

      // 2. Restore reading history
      for (final raw in rawHistory) {
        if (raw is Map<String, dynamic>) {
          await db.into(db.readingHistory).insert(
                ReadingHistoryCompanion.insert(
                  bookId: raw['bookId'] as String,
                  chapterNumber: raw['chapterNumber'] as int,
                  translationId: raw['translationId'] as String,
                  readingDateIso: raw['readingDateIso'] as String,
                  readAtMs: raw['readAtMs'] as int,
                  durationSeconds: Value(raw['durationSeconds'] as int? ?? 0),
                  source: Value(raw['source'] as String? ?? 'daily_plan'),
                  planId: Value(raw['planId'] as String?),
                ),
              );
        }
      }

      // 3. Restore reading plans
      for (final raw in rawPlans) {
        if (raw is Map<String, dynamic>) {
          await db.into(db.userReadingPlans).insertOnConflictUpdate(
                UserReadingPlansCompanion.insert(
                  planId: raw['planId'] as String,
                  status: raw['status'] as String? ?? 'pending',
                  startedAtMs: raw['startedAtMs'] as int? ??
                      DateTime.now().millisecondsSinceEpoch,
                  completedAtMs: Value(raw['completedAtMs'] as int?),
                  completedDaysJson: Value(
                    raw['completedDaysJson'] as String? ?? '[]',
                  ),
                ),
              );
        }
      }
    });

    return BackupImportResult(
      annotationsCount: rawAnnotations.length,
      historyCount: rawHistory.length,
      plansCount: rawPlans.length,
    );
  }

  /// Exports the backup to a file in the temporary directory and opens the
  /// platform share sheet so the user can save or send their backup.
  Future<void> shareBackupFile(AppDatabase db) async {
    final jsonStr = await exportUserDataJson(db);
    final tempDir = await getTemporaryDirectory();
    final nowIso = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final file = File('${tempDir.path}/bible_app_backup_$nowIso.json');
    await file.writeAsString(jsonStr, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: 'Copia de seguridad bible_app ($nowIso)',
        text: 'Respaldo de datos personales de bible_app.',
      ),
    );
  }
}
