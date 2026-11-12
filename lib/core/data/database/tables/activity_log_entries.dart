import 'package:drift/drift.dart';

class ActivityLogEntries extends Table {
  TextColumn get activityId => text()();

  DateTimeColumn get activityDate => dateTime()();

  DateTimeColumn get createdAt => dateTime()();

  TextColumn get category => text()();

  RealColumn get amount =>
      real().customConstraint('NOT NULL CHECK (amount >= 0)')();

  TextColumn get unit => text()();

  RealColumn get emissionsKg =>
      real().customConstraint('NOT NULL CHECK (emissions_kg >= 0)')();

  TextColumn get regionId => text()();

  TextColumn get factorId => text()();

  @override
  Set<Column<Object>> get primaryKey => {activityId};
}
