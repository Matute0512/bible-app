import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../models/reading_plan_definition.dart';
import 'app_providers.dart';

/// Loads all curated thematic reading plans from the local asset.
final thematicPlansDefinitionsProvider =
    FutureProvider<List<ReadingPlanDefinition>>((ref) async {
  final jsonString =
      await rootBundle.loadString('assets/data/reading_plans.json');
  final data = jsonDecode(jsonString) as Map<String, dynamic>;
  final list = data['plans'] as List<dynamic>? ?? [];
  return list
      .map((p) => ReadingPlanDefinition.fromJson(p as Map<String, dynamic>))
      .toList();
});

/// Watches user progress on all thematic plans from the local database.
final thematicPlansProgressProvider =
    StreamProvider<Map<String, ThematicPlanProgress>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.historyDao.watchAllUserReadingPlans().map((rows) {
    final map = <String, ThematicPlanProgress>{};
    for (final row in rows) {
      final days = ThematicPlanProgress.parseCompletedDaysJson(
        row.completedDaysJson,
      );
      map[row.planId] = ThematicPlanProgress(
        planId: row.planId,
        status: row.status,
        startedAtMs: row.startedAtMs,
        completedAtMs: row.completedAtMs,
        completedDays: days,
      );
    }
    return map;
  });
});

/// Represents an active thematic plan paired with its current progress.
class ActiveThematicPlan {
  final ReadingPlanDefinition plan;
  final ThematicPlanProgress progress;

  const ActiveThematicPlan({required this.plan, required this.progress});

  ReadingPlanDay? get currentOrNextDay {
    final nextDayNum = progress.nextPendingDay(plan.durationDays);
    if (nextDayNum != null) {
      return plan.getDay(nextDayNum);
    }
    return plan.days.isNotEmpty ? plan.days.last : null;
  }
}

/// Provider that returns the currently active thematic plan, if any.
final activeThematicPlanProvider = Provider<ActiveThematicPlan?>((ref) {
  final defsAsync = ref.watch(thematicPlansDefinitionsProvider);
  final progressAsync = ref.watch(thematicPlansProgressProvider);

  final defs = defsAsync.value;
  final progressMap = progressAsync.value;

  if (defs == null || progressMap == null) return null;

  for (final plan in defs) {
    final prog = progressMap[plan.id];
    if (prog != null && prog.isActive) {
      return ActiveThematicPlan(plan: plan, progress: prog);
    }
  }

  return null;
});

/// Watches the recent reading history records from the database.
final readingHistoryRecordsProvider =
    StreamProvider<List<ReadingHistoryData>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.historyDao.watchReadingHistoryList(limit: 100);
});

/// State controller / notifier for managing thematic reading plan actions.
class ThematicPlansNotifier {
  final AppDatabase _db;

  ThematicPlansNotifier(this._db);

  /// Activates a plan, pausing any previously active plan.
  Future<void> activatePlan(String planId) async {
    await _db.historyDao.setPlanStatus(planId, 'active');
  }

  /// Pauses an active plan without losing any completed days.
  Future<void> pausePlan(String planId) async {
    await _db.historyDao.setPlanStatus(planId, 'pending');
  }

  /// Marks a specific day completed in a plan.
  Future<void> markDayCompleted(
    String planId,
    int dayNumber, {
    int? totalDays,
  }) async {
    await _db.historyDao.markPlanDayCompleted(
      planId,
      dayNumber,
      totalDays: totalDays,
    );
  }

  /// Unmarks a day in a plan.
  Future<void> unmarkDayCompleted(String planId, int dayNumber) async {
    await _db.historyDao.unmarkPlanDayCompleted(planId, dayNumber);
  }

  /// Resets all progress on a plan back to 0 days.
  Future<void> resetPlan(String planId) async {
    await _db.historyDao.resetPlan(planId);
  }
}

final thematicPlansControllerProvider = Provider<ThematicPlansNotifier>((ref) {
  final db = ref.watch(databaseProvider);
  return ThematicPlansNotifier(db);
});
