import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/data/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('creates the initial preference with English defaults', () async {
    final preferences = await database.select(database.userPreferences).get();

    expect(preferences, hasLength(1));
    expect(preferences.single.displayLanguageTag, 'en');
    expect(preferences.single.selectedRegionId, isNull);
    expect(preferences.single.reducedMotion, isNull);
  });

  test('enforces unique local account identifiers', () async {
    await database
        .into(database.localAccounts)
        .insert(
          LocalAccountsCompanion.insert(
            accountId: 'account-1',
            loginIdentifier: 'member@example.test',
            createdAt: DateTime.utc(2026),
          ),
        );

    await expectLater(
      database
          .into(database.localAccounts)
          .insert(
            LocalAccountsCompanion.insert(
              accountId: 'account-2',
              loginIdentifier: 'member@example.test',
              createdAt: DateTime.utc(2026),
            ),
          ),
      throwsA(anything),
    );
  });

  test('allows only the singleton preferences row', () async {
    await expectLater(
      database
          .into(database.userPreferences)
          .insert(
            UserPreferencesCompanion.insert(
              preferenceId: const Value(2),
              updatedAt: DateTime.utc(2026),
            ),
          ),
      throwsA(anything),
    );
  });

  test('rejects invalid estimate values and completion states', () async {
    await expectLater(
      database
          .into(database.footprintEstimates)
          .insert(
            FootprintEstimatesCompanion.insert(
              estimateId: 'estimate-negative',
              createdAt: DateTime.utc(2026),
              periodStart: DateTime.utc(2025),
              periodEnd: DateTime.utc(2025, 12, 31),
              answers: '{}',
              estimateValue: -1,
              unit: 'kg CO2e',
              questionnaireVersion: '1',
              completionState: 'complete',
              assumptions: '[]',
            ),
          ),
      throwsA(anything),
    );

    await expectLater(
      database
          .into(database.footprintEstimates)
          .insert(
            FootprintEstimatesCompanion.insert(
              estimateId: 'estimate-invalid-state',
              createdAt: DateTime.utc(2026),
              periodStart: DateTime.utc(2025),
              periodEnd: DateTime.utc(2025, 12, 31),
              answers: '{}',
              estimateValue: 1,
              unit: 'kg CO2e',
              questionnaireVersion: '1',
              completionState: 'pending',
              assumptions: '[]',
            ),
          ),
      throwsA(anything),
    );
  });

  test('account deletion cascades to owned estimates', () async {
    await database
        .into(database.localAccounts)
        .insert(
          LocalAccountsCompanion.insert(
            accountId: 'account-1',
            loginIdentifier: 'member@example.test',
            createdAt: DateTime.utc(2026),
          ),
        );
    await database
        .into(database.footprintEstimates)
        .insert(
          FootprintEstimatesCompanion.insert(
            estimateId: 'estimate-1',
            ownerAccountId: const Value('account-1'),
            createdAt: DateTime.utc(2026),
            periodStart: DateTime.utc(2025),
            periodEnd: DateTime.utc(2025, 12, 31),
            answers: '{}',
            estimateValue: 42,
            unit: 'kg CO2e',
            questionnaireVersion: '1',
            completionState: 'complete',
            assumptions: '[]',
          ),
        );

    await (database.delete(
      database.localAccounts,
    )..where((account) => account.accountId.equals('account-1'))).go();

    expect(await database.select(database.footprintEstimates).get(), isEmpty);
  });

  test('rejects estimates referencing an unknown account', () async {
    await expectLater(
      database
          .into(database.footprintEstimates)
          .insert(
            FootprintEstimatesCompanion.insert(
              estimateId: 'estimate-orphaned',
              ownerAccountId: const Value('missing-account'),
              createdAt: DateTime.utc(2026),
              periodStart: DateTime.utc(2025),
              periodEnd: DateTime.utc(2025, 12, 31),
              answers: '{}',
              estimateValue: 1,
              unit: 'kg CO2e',
              questionnaireVersion: '1',
              completionState: 'complete',
              assumptions: '[]',
            ),
          ),
      throwsA(anything),
    );
  });
}
