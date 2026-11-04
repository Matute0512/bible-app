import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bible_app/models/reading_plan_definition.dart';
import 'package:bible_app/providers/thematic_plans_provider.dart';
import 'package:bible_app/screens/plans_screen.dart';
import 'package:bible_app/theme/bible_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockPlans = [
    const ReadingPlanDefinition(
      id: 'salmos_30_dias',
      title: 'Salmos para el Alma',
      subtitle: '30 días de oración y consuelo',
      description: 'Devocional por los salmos',
      category: 'Oración y Alabanza',
      durationDays: 30,
      iconName: 'menu_book',
      accentColorHex: '#8B5E34',
      days: [
        ReadingPlanDay(
          dayNumber: 1,
          title: 'Los dos caminos',
          bookId: 'PSA',
          bookName: 'Salmos',
          chapter: 1,
          theme: 'Bienaventuranza',
        ),
        ReadingPlanDay(
          dayNumber: 2,
          title: 'La gloria del Creador',
          bookId: 'PSA',
          bookName: 'Salmos',
          chapter: 8,
          theme: 'Dignidad humana',
        ),
      ],
    ),
    const ReadingPlanDefinition(
      id: 'conocer_a_jesus_21',
      title: 'Conocer a Jesús: Evangelio de Juan',
      subtitle: '21 días contemplando la vida de Cristo',
      description: 'Lectura de Juan',
      category: 'Evangelio',
      durationDays: 21,
      iconName: 'auto_stories',
      accentColorHex: '#2E5B88',
      days: [
        ReadingPlanDay(
          dayNumber: 1,
          title: 'Juan 1',
          bookId: 'JHN',
          bookName: 'Juan',
          chapter: 1,
          theme: 'El Verbo encarnado',
        ),
      ],
    ),
  ];

  group('PlansScreen Widget Tests', () {
    testWidgets('PlansScreen renders catalog cards and opens detail sheet', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            thematicPlansDefinitionsProvider.overrideWith(
              (ref) async => mockPlans,
            ),
            thematicPlansProgressProvider.overrideWith(
              (ref) => Stream.value({
                'salmos_30_dias': const ThematicPlanProgress(
                  planId: 'salmos_30_dias',
                  status: 'active',
                  startedAtMs: 1000,
                  completedDays: {1},
                ),
              }),
            ),
          ],
          child: MaterialApp(
            theme: BibleTheme.build(Brightness.light),
            home: const PlansScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify header and titles
      expect(find.text('Planes de Lectura'), findsOneWidget);
      expect(find.text('Recorridos Temáticos'), findsOneWidget);
      expect(find.text('PLAN ACTIVO'), findsOneWidget);

      // 2. Active plan card is rendered
      expect(find.text('Salmos para el Alma'), findsWidgets);

      // 3. Scroll to second catalog card
      final secondCardFinder = find.text('Conocer a Jesús: Evangelio de Juan');
      await tester.scrollUntilVisible(
        secondCardFinder,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(secondCardFinder, findsOneWidget);

      // 4. Tap on second card to open detail sheet
      await tester.tap(secondCardFinder);
      await tester.pumpAndSettle();

      // Verify bottom sheet opened with day checklist
      expect(find.text('Activar como principal'), findsOneWidget);
      expect(find.text('Día 1 · Juan 1'), findsOneWidget);
    });
  });
}
