import 'package:drift/drift.dart';

import 'challenge_progress_records.dart';

class ChallengeDayCompletions extends Table {
  TextColumn get challengeId => text().references(
    ChallengeProgressRecords,
    #challengeId,
    onDelete: KeyAction.cascade,
  )();

  IntColumn get dayNumber =>
      integer().customConstraint('NOT NULL CHECK (day_number >= 1)')();

  DateTimeColumn get completedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {challengeId, dayNumber};
}
