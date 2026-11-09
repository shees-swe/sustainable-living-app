import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/features/account/data/password_hasher.dart';

void main() {
  const password = 'local-only-test-passphrase';
  late PasswordHasher hasher;

  setUp(() {
    hasher = PasswordHasher();
  });

  test('generates a unique cryptographic salt for every password hash', () async {
    final first = await hasher.hashPassword(password);
    final second = await hasher.hashPassword(password);

    expect(first.salt, isNot(equals(second.salt)));
    expect(first.verifier, isNot(equals(second.verifier)));
  });

  test('persists Argon2id algorithm version and floor parameters', () async {
    final hash = await hasher.hashPassword(password);

    expect(hash.algorithm, 'argon2id');
    expect(hash.algorithmVersion, isNotEmpty);
    expect(hash.memoryKiB, greaterThanOrEqualTo(19456));
    expect(hash.iterations, greaterThanOrEqualTo(2));
    expect(hash.parallelism, greaterThanOrEqualTo(1));
  });

  test('accepts the correct password and rejects an incorrect password', () async {
    final hash = await hasher.hashPassword(password);

    expect(await hasher.verifyPassword(password, hash), isTrue);
    expect(await hasher.verifyPassword('incorrect-passphrase', hash), isFalse);
  });

  test('persists only the verifier and never the plaintext password', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final hash = await hasher.hashPassword(password);
    await database.createAccountWithVerifier(
      account: LocalAccountsCompanion.insert(
        accountId: 'account-test',
        loginIdentifier: 'member@example.test',
        createdAt: DateTime.utc(2026),
      ),
      verifier: CredentialVerifiersCompanion.insert(
        accountId: 'account-test',
        algorithm: hash.algorithm,
        algorithmVersion: hash.algorithmVersion,
        salt: hash.salt,
        verifier: hash.verifier,
        memoryKiB: hash.memoryKiB,
        iterations: hash.iterations,
        parallelism: hash.parallelism,
        updatedAt: DateTime.utc(2026),
      ),
    );

    final accounts = await database.select(database.localAccounts).get();
    final verifiers = await database.select(database.credentialVerifiers).get();
    final persistedBytes = [
      ...verifiers.single.salt,
      ...verifiers.single.verifier,
    ];

    expect(accounts.single.loginIdentifier, 'member@example.test');
    expect(verifiers, hasLength(1));
    expect(persistedBytes, isNot(containsAll(utf8.encode(password))));
    expect(verifiers.single.toJson().keys, isNot(contains('password')));
    expect(accounts.single.toJson().keys, isNot(contains('password')));
  });
}
