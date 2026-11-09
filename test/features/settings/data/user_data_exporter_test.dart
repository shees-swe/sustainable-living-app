import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/features/settings/data/user_data_exporter.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'exports versioned allowlisted data and excludes credential material',
    () async {
      await database.createAccountWithVerifier(
        account: LocalAccountsCompanion.insert(
          accountId: 'account-1',
          loginIdentifier: 'member@example.test',
          createdAt: DateTime.utc(2026),
        ),
        verifier: CredentialVerifiersCompanion.insert(
          accountId: 'account-1',
          algorithm: 'argon2id',
          algorithmVersion: '19',
          salt: Uint8List.fromList([1, 2, 3]),
          verifier: Uint8List.fromList([4, 5, 6]),
          memoryKiB: 19456,
          iterations: 2,
          parallelism: 1,
          updatedAt: DateTime.utc(2026),
        ),
      );
      await database.saveEstimate(
        FootprintEstimatesCompanion.insert(
          estimateId: 'estimate-1',
          createdAt: DateTime.utc(2026),
          periodStart: DateTime.utc(2026),
          periodEnd: DateTime.utc(2026, 12, 31),
          answers:
              '{"questionnaireVersion":"1","periodYear":2026,"activities":[]}',
          estimateValue: 12.5,
          unit: 'kg CO2e/year',
          questionnaireVersion: '1',
          completionState: 'complete',
          assumptions: '["annualized"]',
        ),
      );

      final exported = await UserDataExporter(
        database: database,
        clock: () => DateTime.utc(2026, 11, 7),
      ).exportData();
      final userData = exported['userData']! as Map<String, Object?>;
      final encoded = jsonEncode(exported);

      expect(exported['exportSchemaVersion'], 1);
      expect(exported['createdAt'], '2026-11-07T00:00:00.000Z');
      expect((userData['accounts']! as List).single, {
        'accountId': 'account-1',
        'loginIdentifier': 'member@example.test',
        'createdAt': '2026-01-01T00:00:00.000Z',
      });
      final estimate =
          (userData['footprintEstimates']! as List).single
              as Map<String, Object?>;
      expect(estimate['estimateValue'], 12.5);
      expect(estimate['answers'], isA<Map<String, Object?>>());
      expect(estimate['assumptions'], ['annualized']);
      expect(encoded, isNot(contains('credentialVerifiers')));
      expect(encoded, isNot(contains('"salt"')));
      expect(encoded, isNot(contains('"verifier"')));
      expect(encoded, isNot(contains('password')));
    },
  );

  test('rejects malformed stored estimate JSON instead of producing an invalid export', () async {
    await database.saveEstimate(
      FootprintEstimatesCompanion.insert(
        estimateId: 'estimate-1',
        createdAt: DateTime.utc(2026),
        periodStart: DateTime.utc(2026),
        periodEnd: DateTime.utc(2026, 12, 31),
        answers: '[]',
        estimateValue: 0,
        unit: 'kg CO2e/year',
        questionnaireVersion: '1',
        completionState: 'incomplete',
        assumptions: '[]',
      ),
    );

    await expectLater(
      UserDataExporter(database: database).exportData(),
      throwsA(isA<FormatException>()),
    );
  });
}
