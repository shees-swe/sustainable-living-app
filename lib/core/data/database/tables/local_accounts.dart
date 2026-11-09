import 'package:drift/drift.dart';

@TableIndex(
  name: 'local_accounts_login_identifier_unique',
  columns: {#loginIdentifier},
  unique: true,
)
class LocalAccounts extends Table {
  TextColumn get accountId => text()();

  TextColumn get loginIdentifier => text().withLength(min: 1, max: 320)();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {accountId};
}
