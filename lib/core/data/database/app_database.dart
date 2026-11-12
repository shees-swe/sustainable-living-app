import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/credential_verifiers.dart';
import 'tables/challenge_day_completions.dart';
import 'tables/challenge_progress_records.dart';
import 'tables/activity_log_entries.dart';
import 'tables/footprint_estimates.dart';
import 'tables/local_accounts.dart';
import 'tables/user_preferences.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    LocalAccounts,
    CredentialVerifiers,
    UserPreferences,
    FootprintEstimates,
    ActivityLogEntries,
    ChallengeProgressRecords,
    ChallengeDayCompletions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: databaseName));

  AppDatabase.forTesting(super.executor);

  static const String databaseName = 'sustainable_living_app';
  static const MethodChannel _privacyChannel = MethodChannel(
    'app.sustainablelivingguide/privacy',
  );

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await into(userPreferences).insert(
        UserPreferencesCompanion.insert(
          preferenceId: const Value(1),
          updatedAt: DateTime.now().toUtc(),
        ),
      );
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(activityLogEntries);
      }
      if (from < 3) {
        await migrator.createTable(challengeProgressRecords);
        await migrator.createTable(challengeDayCompletions);
      }
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> createAccountWithVerifier({
    required LocalAccountsCompanion account,
    required CredentialVerifiersCompanion verifier,
  }) {
    return transaction(() async {
      await into(localAccounts).insert(account);
      await into(credentialVerifiers).insert(verifier);
    });
  }

  Future<void> deleteAccount(String accountId) {
    return transaction(() async {
      await (delete(
        localAccounts,
      )..where((account) => account.accountId.equals(accountId))).go();
    });
  }

  Future<void> savePreferences(UserPreferencesCompanion preferences) {
    return transaction(() async {
      await into(userPreferences).insertOnConflictUpdate(preferences);
    });
  }

  Future<void> saveEstimate(FootprintEstimatesCompanion estimate) {
    return transaction(() async {
      await into(footprintEstimates).insertOnConflictUpdate(estimate);
    });
  }

  Future<T> readConsistentSnapshot<T>(Future<T> Function() read) {
    return transaction(read);
  }

  Future<void> clearAllUserData() {
    return transaction(() async {
      await delete(footprintEstimates).go();
      await delete(activityLogEntries).go();
      await delete(challengeDayCompletions).go();
      await delete(challengeProgressRecords).go();
      await delete(localAccounts).go();
      await into(userPreferences).insertOnConflictUpdate(
        UserPreferencesCompanion.insert(
          preferenceId: const Value(1),
          displayLanguageTag: const Value('en'),
          selectedRegionId: const Value(null),
          reducedMotion: const Value(null),
          updatedAt: DateTime.now().toUtc(),
        ),
      );
    });
  }

  static Future<void> deleteDatabaseFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final databasePath = p.join(directory.path, '$databaseName.sqlite');
    for (final suffix in ['', '-wal', '-shm', '-journal']) {
      final file = File('$databasePath$suffix');
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  static Future<void> excludeDatabaseFromBackup() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;

    final directory = await getApplicationDocumentsDirectory();
    final databasePath = p.join(directory.path, '$databaseName.sqlite');
    final paths = <String>[];
    for (final suffix in ['', '-wal', '-shm', '-journal']) {
      final file = File('$databasePath$suffix');
      if (await file.exists()) {
        paths.add(file.path);
      }
    }
    if (paths.isEmpty) {
      throw StateError(
        'The local database file is unavailable for backup exclusion.',
      );
    }
    await _privacyChannel.invokeMethod<void>('excludeFromBackup', paths);
  }
}
