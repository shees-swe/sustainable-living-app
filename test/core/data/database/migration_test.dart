import 'package:drift_dev/api/migrations_native.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/data/database/app_database.dart';

void main() {
  test('creates and validates the initial database schema', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await database.select(database.userPreferences).get();
    expect(database.schemaVersion, 3);

    await database.validateDatabaseSchema();

    final foreignKeyViolations = await database
        .customSelect('PRAGMA foreign_key_check')
        .get();
    expect(foreignKeyViolations, isEmpty);
  });

  test(
    'upgrades a version 2 database with challenge progress tables',
    () async {
      final executor = NativeDatabase.memory(
        setup: (database) => database.execute('PRAGMA user_version = 2'),
      );
      final database = AppDatabase.forTesting(executor);
      addTearDown(database.close);

      await database
          .into(database.challengeProgressRecords)
          .insert(
            ChallengeProgressRecordsCompanion.insert(
              challengeId: 'plastic-free-week',
              startedAt: DateTime.utc(2026, 1, 1),
            ),
          );
      await database
          .into(database.challengeDayCompletions)
          .insert(
            ChallengeDayCompletionsCompanion.insert(
              challengeId: 'plastic-free-week',
              dayNumber: 1,
              completedAt: DateTime.utc(2026, 1, 1),
            ),
          );

      expect(database.schemaVersion, 3);
      expect(
        await database.select(database.challengeProgressRecords).get(),
        hasLength(1),
      );
      expect(
        await database.select(database.challengeDayCompletions).get(),
        hasLength(1),
      );
    },
  );
}
