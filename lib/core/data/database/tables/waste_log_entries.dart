import 'package:drift/drift.dart';

class WasteLogEntries extends Table {
  TextColumn get entryId => text()();

  DateTimeColumn get wasteDate => dateTime()();

  DateTimeColumn get createdAt => dateTime()();

  TextColumn get category => text().customConstraint(
    "NOT NULL CHECK (category IN ('Plastic', 'Paper & cardboard', 'Glass', 'Metal', 'Organic', 'Other'))",
  )();

  RealColumn get amountKg =>
      real().customConstraint('NOT NULL CHECK (amount_kg > 0)')();

  @override
  Set<Column<Object>> get primaryKey => {entryId};
}
