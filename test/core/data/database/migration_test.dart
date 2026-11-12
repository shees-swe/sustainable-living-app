import 'package:drift_dev/api/migrations_native.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/data/database/app_database.dart';

void main() {
  test('creates and validates the initial database schema', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await database.select(database.userPreferences).get();
    expect(database.schemaVersion, 7);

    await database.validateDatabaseSchema();

    final foreignKeyViolations = await database
        .customSelect('PRAGMA foreign_key_check')
        .get();
    expect(foreignKeyViolations, isEmpty);
  });

  test(
    'upgrades a version 2 database with challenge progress and waste tables',
    () async {
      final executor = NativeDatabase.memory(
        setup: (database) {
          database.execute(
            'CREATE TABLE user_preferences ('
            'preference_id INTEGER NOT NULL CHECK (preference_id = 1), '
            "display_language_tag TEXT NOT NULL DEFAULT 'en', "
            'selected_region_id TEXT, reduced_motion INTEGER, '
            'updated_at INTEGER NOT NULL, PRIMARY KEY (preference_id))',
          );
          database.execute('PRAGMA user_version = 2');
        },
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

      expect(database.schemaVersion, 7);
      expect(
        await database.select(database.challengeProgressRecords).get(),
        hasLength(1),
      );
      expect(
        await database.select(database.challengeDayCompletions).get(),
        hasLength(1),
      );
      expect(await database.select(database.wasteLogEntries).get(), isEmpty);
    },
  );

  test('upgrades a version 3 database with the waste log table', () async {
    final executor = NativeDatabase.memory(
      setup: (database) {
        database.execute(
          'CREATE TABLE user_preferences ('
          'preference_id INTEGER NOT NULL CHECK (preference_id = 1), '
          "display_language_tag TEXT NOT NULL DEFAULT 'en', "
          'selected_region_id TEXT, reduced_motion INTEGER, '
          'updated_at INTEGER NOT NULL, PRIMARY KEY (preference_id))',
        );
        database.execute('PRAGMA user_version = 3');
      },
    );
    final database = AppDatabase.forTesting(executor);
    addTearDown(database.close);

    await database
        .into(database.wasteLogEntries)
        .insert(
          WasteLogEntriesCompanion.insert(
            entryId: 'waste-1',
            wasteDate: DateTime(2026, 11, 12),
            createdAt: DateTime.utc(2026, 11, 12),
            category: 'Plastic',
            amountKg: 1.25,
          ),
        );

    expect(database.schemaVersion, 7);
    final entry = await database.select(database.wasteLogEntries).getSingle();
    expect(entry.entryId, 'waste-1');
    expect(entry.category, 'Plastic');
    expect(entry.amountKg, 1.25);
  });

  test('upgrades version 4 preferences with weekly planner days', () async {
    final executor = NativeDatabase.memory(
      setup: (database) {
        database.execute(
          'CREATE TABLE user_preferences ('
          'preference_id INTEGER NOT NULL CHECK (preference_id = 1), '
          "display_language_tag TEXT NOT NULL DEFAULT 'en', "
          'selected_region_id TEXT, reduced_motion INTEGER, '
          'updated_at INTEGER NOT NULL, PRIMARY KEY (preference_id))',
        );
        database.execute(
          "INSERT INTO user_preferences VALUES (1, 'fr', 'PK', 1, 0)",
        );
        database.execute('PRAGMA user_version = 4');
      },
    );
    final database = AppDatabase.forTesting(executor);
    addTearDown(database.close);

    final preference = await database
        .select(database.userPreferences)
        .getSingle();
    expect(database.schemaVersion, 7);
    expect(preference.displayLanguageTag, 'fr');
    expect(preference.selectedRegionId, 'PK');
    expect(preference.reducedMotion, isTrue);
    expect(preference.recyclingCollectionDay, isNull);
    expect(preference.compostDay, isNull);
  });

  test('upgrades a version 5 database with the planned trips table', () async {
    final executor = NativeDatabase.memory(
      setup: (database) {
        database.execute(
          'CREATE TABLE user_preferences ('
          'preference_id INTEGER NOT NULL CHECK (preference_id = 1), '
          "display_language_tag TEXT NOT NULL DEFAULT 'en', "
          'selected_region_id TEXT, reduced_motion INTEGER, '
          'recycling_collection_day INTEGER, compost_day INTEGER, '
          'updated_at INTEGER NOT NULL, PRIMARY KEY (preference_id))',
        );
        database.execute('PRAGMA user_version = 5');
      },
    );
    final database = AppDatabase.forTesting(executor);
    addTearDown(database.close);

    await database
        .into(database.plannedTrips)
        .insert(
          PlannedTripsCompanion.insert(
            tripId: 'trip-1',
            title: 'Weekend by train',
            destination: 'York',
            transportMode: 'Train',
            createdAt: DateTime.utc(2026, 11, 12),
          ),
        );

    expect(database.schemaVersion, 7);
    final trip = await database.select(database.plannedTrips).getSingle();
    expect(trip.tripId, 'trip-1');
    expect(trip.title, 'Weekend by train');
    expect(trip.tripDate, isNull);
    expect(trip.notes, isNull);
  });

  test(
    'upgrades a version 6 database with the community journal table',
    () async {
      final executor = NativeDatabase.memory(
        setup: (database) {
          database.execute(
            'CREATE TABLE user_preferences ('
            'preference_id INTEGER NOT NULL CHECK (preference_id = 1), '
            "display_language_tag TEXT NOT NULL DEFAULT 'en', "
            'selected_region_id TEXT, reduced_motion INTEGER, '
            'recycling_collection_day INTEGER, compost_day INTEGER, '
            'updated_at INTEGER NOT NULL, PRIMARY KEY (preference_id))',
          );
          database.execute('PRAGMA user_version = 6');
        },
      );
      final database = AppDatabase.forTesting(executor);
      addTearDown(database.close);

      await database
          .into(database.communityJournalPosts)
          .insert(
            CommunityJournalPostsCompanion.insert(
              postId: 'post-1',
              title: 'A first step',
              body: 'I tried repairing a lamp.',
              createdAt: DateTime.utc(2026, 11, 12),
            ),
          );

      expect(database.schemaVersion, 7);
      final post = await database
          .select(database.communityJournalPosts)
          .getSingle();
      expect(post.postId, 'post-1');
      expect(post.title, 'A first step');
      expect(post.body, 'I tried repairing a lamp.');
    },
  );
}
