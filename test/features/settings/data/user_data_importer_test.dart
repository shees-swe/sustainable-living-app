import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/features/account/data/account_repository.dart';
import 'package:sustainable_living_app/features/account/data/password_hasher.dart';
import 'package:sustainable_living_app/features/carbon_footprint_tracker/data/activity_log_repository.dart';
import 'package:sustainable_living_app/features/community_journal/data/community_post_repository.dart';
import 'package:sustainable_living_app/features/eco_travel_suggestions/data/travel_trip_repository.dart';
import 'package:sustainable_living_app/features/onboarding/data/footprint_estimate_repository.dart';
import 'package:sustainable_living_app/features/onboarding/domain/footprint_calculator.dart';
import 'package:sustainable_living_app/features/onboarding/domain/footprint_estimate.dart';
import 'package:sustainable_living_app/features/settings/data/user_data_exporter.dart';
import 'package:sustainable_living_app/features/settings/data/user_data_importer.dart';
import 'package:sustainable_living_app/features/settings/data/user_preferences_repository.dart';
import 'package:sustainable_living_app/features/sustainable_living_challenges/data/challenge_progress_repository.dart';
import 'package:sustainable_living_app/features/waste_reduction_tracker/data/waste_log_repository.dart';
import 'package:sustainable_living_app/features/waste_reduction_tracker/domain/waste_category.dart';

void main() {
  late AppDatabase database;
  late UserDataExporter exporter;
  late UserDataImporter importer;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    exporter = UserDataExporter(
      database: database,
      clock: () => DateTime.utc(2026, 12, 31),
    );
    importer = UserDataImporter(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'export, clear-all, and import restore every exported dataset',
    () async {
      final now = DateTime.utc(2026, 3, 10);
      final account = AccountRepository(
        database: database,
        passwordHasher: const _TestCredentialHasher(),
        clock: () => now,
      );
      await account.register(
        loginIdentifier: 'member@example.test',
        password: 'valid-password',
      );

      const factor = EmissionFactor(
        factorId: 'test-electricity',
        category: 'electricity',
        activityId: 'electricity',
        value: 0.25,
        numeratorUnit: 'kg CO2e',
        denominatorUnit: 'kWh',
        source: FactorSource(
          sourceId: 'test-source',
          title: 'Test source',
          publicationYear: 2026,
        ),
        validFrom: '2026-01-01',
        methodology: 'Test factor.',
      );
      const answers = FootprintAnswers(
        questionnaireVersion: '1',
        periodYear: 2026,
        activities: [
          ActivityInput(activityId: 'electricity', amount: 100, unit: 'kWh'),
        ],
      );
      final estimate = const FootprintCalculator().calculate(
        answers: answers,
        factors: const [factor],
      ) as CompleteEstimate;
      await FootprintEstimateRepository(database: database)
          .saveCompleteEstimate(answers: answers, estimate: estimate);

      await ActivityLogRepository(
        database: database,
        clock: () => now,
      ).addElectricity(
        date: now,
        amountKwh: 20,
        regionId: 'demo-region',
        factors: const [factor],
      );
      await WasteLogRepository(
        database: database,
        clock: () => now,
      ).addEntry(date: now, category: WasteCategory.plastic, amountKg: 1.25);
      await TravelTripRepository(database: database, clock: () => now).addTrip(
        title: 'Weekend by train',
        destination: 'York',
        transportMode: 'Train',
        date: DateTime.utc(2026, 4, 1),
        notes: 'Pack light.',
      );
      await CommunityPostRepository(
        database: database,
        clock: () => now,
      ).addPost(title: 'Repaired a lamp', body: 'Fixed instead of replacing.');

      final challengeRepository = ChallengeProgressRepository(
        database: database,
        clock: () => now,
      );
      await challengeRepository.startChallenge('plastic-free-week');
      await challengeRepository.setDayCompleted(
        challengeId: 'plastic-free-week',
        totalDays: 7,
        dayNumber: 1,
        completed: true,
      );

      final preferences = UserPreferencesRepository(
        database: database,
        supportedRegionIds: const {'demo-region'},
        clock: () => now,
      );
      await preferences.selectRegion('demo-region');
      await preferences.setDisplayLanguageTag('en');
      await preferences.setWastePlannerDays(
        recyclingCollectionDay: DateTime.tuesday,
        compostDay: DateTime.friday,
      );

      final before = await exporter.exportData();
      await database.clearAllUserData();
      expect(await database.select(database.localAccounts).get(), isEmpty);
      await importer.importJson(jsonEncode(before));
      final after = await exporter.exportData();

      expect(after, before);
    },
  );

  test('rejects invalid files without changing pre-existing data', () async {
    await database
        .into(database.localAccounts)
        .insert(
          LocalAccountsCompanion.insert(
            accountId: 'existing',
            loginIdentifier: 'existing@example.test',
            createdAt: DateTime.utc(2026),
          ),
        );
    final before = await exporter.exportData();
    final wrongShape = Map<String, Object?>.from(before)..remove('userData');
    final unsupportedVersion = Map<String, Object?>.from(before)
      ..['exportSchemaVersion'] = 6;

    for (final source in [
      'not JSON',
      jsonEncode(wrongShape),
      jsonEncode(unsupportedVersion),
    ]) {
      await expectLater(importer.importJson(source), throwsFormatException);
      expect(await exporter.exportData(), before);
    }
  });
}

class _TestCredentialHasher implements CredentialHasher {
  const _TestCredentialHasher();

  @override
  Future<PasswordHash> hashPassword(String password) async => PasswordHash(
    algorithm: 'argon2id',
    algorithmVersion: 'argon2id-v19-cryptography_plus-3.0.0',
    salt: List<int>.filled(16, 1),
    verifier: List<int>.filled(32, 2),
    memoryKiB: 19456,
    iterations: 2,
    parallelism: 1,
  );

  @override
  Future<bool> verifyPassword(String password, PasswordHash hash) async =>
      false;
}
