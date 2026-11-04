import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bible_app/database/app_database.dart';
import 'package:bible_app/models/reading_plan_definition.dart';
import 'package:bible_app/providers/thematic_plans_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Thematic Reading Plans Models & Serialization Tests', () {
    test('ReadingPlanDay parses json correctly and produces reference', () {
      final json = {
        'dayNumber': 4,
        'title': 'El buen Pastor',
        'bookId': 'PSA',
        'bookName': 'Salmos',
        'chapter': 23,
        'theme': 'Confianza y cuidado en el valle',
      };

      final day = ReadingPlanDay.fromJson(json);
      expect(day.dayNumber, 4);
      expect(day.reference, 'Salmos 23');
      expect(day.theme, 'Confianza y cuidado en el valle');
      expect(day.toJson(), json);
    });

    test('ReadingPlanDefinition parses 4 curated plans from JSON', () {
      final json = {
        'id': 'salmos_30_dias',
        'title': 'Salmos para el Alma',
        'subtitle': '30 días de oración',
        'description': 'Devocional por los salmos',
        'category': 'Oración y Alabanza',
        'durationDays': 30,
        'iconName': 'menu_book',
        'accentColorHex': '#8B5E34',
        'days': [
          {
            'dayNumber': 1,
            'title': 'Los dos caminos',
            'bookId': 'PSA',
            'bookName': 'Salmos',
            'chapter': 1,
            'theme': 'Bienaventuranza',
          },
          {
            'dayNumber': 2,
            'title': 'La gloria del Creador',
            'bookId': 'PSA',
            'bookName': 'Salmos',
            'chapter': 8,
            'theme': 'Dignidad humana',
          },
        ],
      };

      final plan = ReadingPlanDefinition.fromJson(json);
      expect(plan.id, 'salmos_30_dias');
      expect(plan.durationDays, 30);
      expect(plan.days.length, 2);
      expect(plan.getDay(1)?.reference, 'Salmos 1');
      expect(plan.getDay(2)?.reference, 'Salmos 8');
      expect(plan.getDay(99), isNull);
    });

    test('ThematicPlanProgress computes progress math and encodes/decodes days', () {
      final days = {1, 2, 4};
      final jsonStr = ThematicPlanProgress.encodeCompletedDays(days);
      expect(jsonStr, '[1,2,4]');

      final decoded = ThematicPlanProgress.parseCompletedDaysJson(jsonStr);
      expect(decoded, {1, 2, 4});

      final progress = ThematicPlanProgress(
        planId: 'salmos_30_dias',
        status: 'active',
        startedAtMs: 1000,
        completedDays: decoded,
      );

      expect(progress.isActive, isTrue);
      expect(progress.isCompleted, isFalse);
      expect(progress.completedCount, 3);
      expect(progress.fraction(30), closeTo(0.1, 0.001));
      expect(progress.percentage(30), closeTo(10.0, 0.01));
      expect(progress.isDayCompleted(1), isTrue);
      expect(progress.isDayCompleted(3), isFalse);
      expect(progress.nextPendingDay(30), 3);
    });
  });

  group('Thematic Reading Plans DAO & Persistence Tests', () {
    late AppDatabase db;
    late ThematicPlansNotifier controller;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      controller = ThematicPlansNotifier(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('Activating plan A, progressing, then switching to plan B preserves progress independently', () async {
      final dao = db.historyDao;

      // 1. Activate plan A (Salmos 30 dias)
      await controller.activatePlan('salmos_30_dias');
      var planA = await dao.getUserReadingPlan('salmos_30_dias');
      expect(planA, isNotNull);
      expect(planA!.status, 'active');

      // Complete days 1, 2, 3 in plan A
      await controller.markDayCompleted('salmos_30_dias', 1, totalDays: 30);
      await controller.markDayCompleted('salmos_30_dias', 2, totalDays: 30);
      await controller.markDayCompleted('salmos_30_dias', 3, totalDays: 30);

      planA = await dao.getUserReadingPlan('salmos_30_dias');
      var daysA = ThematicPlanProgress.parseCompletedDaysJson(planA!.completedDaysJson);
      expect(daysA, {1, 2, 3});

      // 2. Activate plan B (conocer_a_jesus_21)
      await controller.activatePlan('conocer_a_jesus_21');
      var planB = await dao.getUserReadingPlan('conocer_a_jesus_21');
      expect(planB, isNotNull);
      expect(planB!.status, 'active');

      // Plan A should now be 'pending' but with its 3 days completely intact!
      planA = await dao.getUserReadingPlan('salmos_30_dias');
      expect(planA!.status, 'pending');
      daysA = ThematicPlanProgress.parseCompletedDaysJson(planA.completedDaysJson);
      expect(daysA, {1, 2, 3});

      // 3. Complete days 1 and 2 in plan B
      await controller.markDayCompleted('conocer_a_jesus_21', 1, totalDays: 21);
      await controller.markDayCompleted('conocer_a_jesus_21', 2, totalDays: 21);

      planB = await dao.getUserReadingPlan('conocer_a_jesus_21');
      final daysB = ThematicPlanProgress.parseCompletedDaysJson(planB!.completedDaysJson);
      expect(daysB, {1, 2});

      // Verify Plan A remained unaltered
      planA = await dao.getUserReadingPlan('salmos_30_dias');
      expect(ThematicPlanProgress.parseCompletedDaysJson(planA!.completedDaysJson), {1, 2, 3});
    });

    test('Completing all days in a plan transitions status to completed', () async {
      final dao = db.historyDao;
      const planId = 'esperanza_paz_14';
      const totalDays = 14;

      await controller.activatePlan(planId);

      for (int i = 1; i <= totalDays; i++) {
        await controller.markDayCompleted(planId, i, totalDays: totalDays);
      }

      final plan = await dao.getUserReadingPlan(planId);
      expect(plan, isNotNull);
      expect(plan!.status, 'completed');
      expect(plan.completedAtMs, isNotNull);

      final days = ThematicPlanProgress.parseCompletedDaysJson(plan.completedDaysJson);
      expect(days.length, 14);

      // Unmarking a day reverts status back to active
      await controller.unmarkDayCompleted(planId, 14);
      final reverted = await dao.getUserReadingPlan(planId);
      expect(reverted!.status, 'active');
      expect(reverted.completedAtMs, isNull);
      expect(ThematicPlanProgress.parseCompletedDaysJson(reverted.completedDaysJson).length, 13);
    });

    test('Resetting plan clears its completed days and removes record', () async {
      final dao = db.historyDao;
      const planId = 'sabiduria_proverbios_31';

      await controller.activatePlan(planId);
      await controller.markDayCompleted(planId, 1, totalDays: 31);
      await controller.markDayCompleted(planId, 2, totalDays: 31);

      var plan = await dao.getUserReadingPlan(planId);
      expect(plan, isNotNull);

      await controller.resetPlan(planId);
      plan = await dao.getUserReadingPlan(planId);
      expect(plan, isNull);
    });
  });

  group('Curated reading_plans.json Asset Integrity Test', () {
    test('assets/data/reading_plans.json contains 4 valid curated plans with canonical references', () async {
      final jsonStr = await rootBundle.loadString('assets/data/reading_plans.json');
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      final plans = (decoded['plans'] as List).map((p) => ReadingPlanDefinition.fromJson(p)).toList();

      expect(plans.length, 4);

      final ids = plans.map((p) => p.id).toSet();
      expect(ids, containsAll([
        'salmos_30_dias',
        'conocer_a_jesus_21',
        'sabiduria_proverbios_31',
        'esperanza_paz_14',
      ]));

      // Verify each plan has valid days count matching its durationDays
      for (final plan in plans) {
        expect(plan.days.length, plan.durationDays);
        for (final day in plan.days) {
          expect(day.bookId.isNotEmpty, isTrue);
          expect(day.bookName.isNotEmpty, isTrue);
          expect(day.chapter, greaterThan(0));
          expect(day.dayNumber, greaterThan(0));
        }
      }
    });
  });
}
