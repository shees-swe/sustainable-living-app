import 'package:drift/drift.dart';

class ChallengeProgressRecords extends Table {
  TextColumn get challengeId => text()();

  DateTimeColumn get startedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {challengeId};
}
