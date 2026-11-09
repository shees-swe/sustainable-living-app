import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/features/account/data/account_repository.dart';
import 'package:sustainable_living_app/features/account/data/password_hasher.dart';

void main() {
  late AppDatabase database;
  late AccountRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = AccountRepository(
      database: database,
      passwordHasher: _TestHasher(),
      clock: () => DateTime.utc(2026, 11, 7),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'normalizes identifiers and preserves only a credential verifier',
    () async {
      final identity = await repository.register(
        loginIdentifier: '  Member@Example.Test ',
        password: 'a-valid-local-password',
      );

      expect(identity.loginIdentifier, 'member@example.test');
      expect(identity.createdAt, DateTime.utc(2026, 11, 7));
      final accounts = await database.select(database.localAccounts).get();
      final verifiers = await database
          .select(database.credentialVerifiers)
          .get();
      expect(accounts, hasLength(1));
      expect(accounts.single.loginIdentifier, 'member@example.test');
      expect(verifiers.single.algorithm, 'argon2id');
      expect(verifiers.single.memoryKiB, greaterThanOrEqualTo(19456));
      expect(verifiers.single.iterations, greaterThanOrEqualTo(2));
      expect(verifiers.single.parallelism, greaterThanOrEqualTo(1));
      final loggedIn = await repository.login(
        loginIdentifier: 'MEMBER@example.test',
        password: 'a-valid-local-password',
      );
      expect(loggedIn.accountId, identity.accountId);
    },
  );

  test(
    'rejects duplicate normalized identifiers and incomplete credentials',
    () async {
      await repository.register(
        loginIdentifier: 'member@example.test',
        password: 'a-valid-local-password',
      );

      await expectLater(
        repository.register(
          loginIdentifier: ' MEMBER@example.test ',
          password: 'another-valid-password',
        ),
        throwsA(isA<AccountAlreadyExists>()),
      );
      await expectLater(
        repository.register(
          loginIdentifier: '   ',
          password: 'another-valid-password',
        ),
        throwsA(isA<InvalidAccountIdentifier>()),
      );
      await expectLater(
        repository.register(
          loginIdentifier: 'other@example.test',
          password: 'short',
        ),
        throwsA(isA<InvalidAccountPassword>()),
      );
    },
  );

  test(
    'throttles failed local logins and clears failures after successful login',
    () async {
      await repository.register(
        loginIdentifier: 'member@example.test',
        password: 'a-valid-local-password',
      );

      for (
        var attempt = 0;
        attempt < AccountRepository.maxFailedLoginAttempts;
        attempt++
      ) {
        await expectLater(
          repository.login(
            loginIdentifier: 'member@example.test',
            password: 'wrong-password',
          ),
          throwsA(isA<InvalidAccountCredentials>()),
        );
      }
      await expectLater(
        repository.login(
          loginIdentifier: 'member@example.test',
          password: 'a-valid-local-password',
        ),
        throwsA(isA<AccountLoginThrottled>()),
      );
    },
  );

  test('deleting an account cascades its verifier and owned records', () async {
    final identity = await repository.register(
      loginIdentifier: 'member@example.test',
      password: 'a-valid-local-password',
    );
    await database.saveEstimate(
      FootprintEstimatesCompanion.insert(
        estimateId: 'estimate-1',
        ownerAccountId: Value(identity.accountId),
        createdAt: DateTime.utc(2026),
        periodStart: DateTime.utc(2026),
        periodEnd: DateTime.utc(2026, 12, 31),
        answers: '{}',
        estimateValue: 1,
        unit: 'kg CO2e/year',
        questionnaireVersion: '1',
        completionState: 'complete',
        assumptions: '[]',
      ),
    );

    await repository.deleteAccount(identity.accountId);

    expect(await database.select(database.localAccounts).get(), isEmpty);
    expect(await database.select(database.credentialVerifiers).get(), isEmpty);
    expect(await database.select(database.footprintEstimates).get(), isEmpty);
  });
}

class _TestHasher implements CredentialHasher {
  var _salt = 0;

  @override
  Future<PasswordHash> hashPassword(String password) async {
    _salt++;
    return PasswordHash(
      algorithm: 'argon2id',
      algorithmVersion: 'test',
      salt: Uint8List.fromList([_salt]),
      verifier: Uint8List.fromList(password.codeUnits),
      memoryKiB: 19456,
      iterations: 2,
      parallelism: 1,
    );
  }

  @override
  Future<bool> verifyPassword(String password, PasswordHash hash) async =>
      hash.verifier.toList().join(',') == password.codeUnits.join(',');
}
