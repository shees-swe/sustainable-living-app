import 'package:drift/drift.dart';

import 'local_accounts.dart';

class CredentialVerifiers extends Table {
  TextColumn get accountId => text().references(
    LocalAccounts,
    #accountId,
    onDelete: KeyAction.cascade,
  )();

  TextColumn get algorithm =>
      text().customConstraint("NOT NULL CHECK (algorithm = 'argon2id')")();

  TextColumn get algorithmVersion => text()();

  BlobColumn get salt => blob().unique()();

  BlobColumn get verifier => blob()();

  IntColumn get memoryKiB =>
      integer().customConstraint('NOT NULL CHECK (memory_ki_b >= 19456)')();

  IntColumn get iterations =>
      integer().customConstraint('NOT NULL CHECK (iterations >= 2)')();

  IntColumn get parallelism =>
      integer().customConstraint('NOT NULL CHECK (parallelism >= 1)')();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {accountId};
}
