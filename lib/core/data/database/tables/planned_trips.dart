import 'package:drift/drift.dart';

class PlannedTrips extends Table {
  TextColumn get tripId => text()();

  TextColumn get title => text()();

  TextColumn get destination => text()();

  TextColumn get transportMode => text()();

  DateTimeColumn get tripDate => dateTime().nullable()();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {tripId};
}
