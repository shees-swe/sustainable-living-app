import 'package:drift/drift.dart';

class UserPreferences extends Table {
  IntColumn get preferenceId =>
      integer().customConstraint('NOT NULL CHECK (preference_id = 1)')();

  TextColumn get displayLanguageTag =>
      text().withDefault(const Constant('en'))();

  TextColumn get selectedRegionId => text().nullable()();

  BoolColumn get reducedMotion => boolean().nullable()();

  IntColumn get recyclingCollectionDay => integer().nullable()();

  IntColumn get compostDay => integer().nullable()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {preferenceId};
}
