import 'package:drift/drift.dart';

import 'local_accounts.dart';

class FootprintEstimates extends Table {
  TextColumn get estimateId => text()();

  TextColumn get ownerAccountId => text()
      .nullable()
      .references(LocalAccounts, #accountId, onDelete: KeyAction.cascade)();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get periodStart => dateTime()();

  DateTimeColumn get periodEnd => dateTime()();

  TextColumn get answers => text()();

  RealColumn get estimateValue =>
      real().customConstraint('NOT NULL CHECK (estimate_value >= 0)')();

  TextColumn get unit => text()();

  TextColumn get questionnaireVersion => text()();

  TextColumn get completionState => text().customConstraint(
    "NOT NULL CHECK (completion_state IN ('complete', 'incomplete'))",
  )();

  TextColumn get assumptions => text()();

  @override
  Set<Column<Object>> get primaryKey => {estimateId};
}
