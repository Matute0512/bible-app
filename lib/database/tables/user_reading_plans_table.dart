import 'package:drift/drift.dart';

/// Progress state of active, pending, or completed reading plans.
class UserReadingPlans extends Table {
  TextColumn get planId => text()();
  TextColumn get status => text()(); // pending | active | completed
  IntColumn get startedAtMs => integer()();
  IntColumn get completedAtMs => integer().nullable()();
  TextColumn get completedDaysJson => text().withDefault(const Constant('[]'))();

  @override
  Set<Column> get primaryKey => {planId};
}

