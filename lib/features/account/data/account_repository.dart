import 'dart:math';

import '../../../core/data/database/app_database.dart';
import 'password_hasher.dart';

class AccountRepository {
  factory AccountRepository({
    required AppDatabase database,
    required CredentialHasher passwordHasher,
    DateTime Function()? clock,
  }) => AccountRepository._(database, passwordHasher, clock);

  AccountRepository._(
    this._database,
    this._passwordHasher,
    DateTime Function()? clock,
  ) : _clock = clock ?? DateTime.now;

  static const int maxFailedLoginAttempts = 5;
  static const Duration loginLockoutDuration = Duration(minutes: 5);
  static const int minimumPasswordLength = 8;

  final AppDatabase _database;
  final CredentialHasher _passwordHasher;
  final DateTime Function() _clock;
  final Map<String, _LoginFailureState> _loginFailures = {};

  Future<AccountIdentity> register({
    required String loginIdentifier,
    required String password,
  }) async {
    final normalizedIdentifier = normalizeLoginIdentifier(loginIdentifier);
    _validateIdentifier(normalizedIdentifier);
    _validatePassword(password);

    final existing =
        await (_database.select(_database.localAccounts)..where(
              (account) => account.loginIdentifier.equals(normalizedIdentifier),
            ))
            .getSingleOrNull();
    if (existing != null) {
      throw const AccountAlreadyExists();
    }

    final passwordHash = await _passwordHasher.hashPassword(password);
    final accountId = _newAccountId();
    final createdAt = _clock().toUtc();
    await _database.createAccountWithVerifier(
      account: LocalAccountsCompanion.insert(
        accountId: accountId,
        loginIdentifier: normalizedIdentifier,
        createdAt: createdAt,
      ),
      verifier: CredentialVerifiersCompanion.insert(
        accountId: accountId,
        algorithm: passwordHash.algorithm,
        algorithmVersion: passwordHash.algorithmVersion,
        salt: passwordHash.salt,
        verifier: passwordHash.verifier,
        memoryKiB: passwordHash.memoryKiB,
        iterations: passwordHash.iterations,
        parallelism: passwordHash.parallelism,
        updatedAt: createdAt,
      ),
    );
    return AccountIdentity(
      accountId: accountId,
      loginIdentifier: normalizedIdentifier,
      createdAt: createdAt,
    );
  }

  Future<AccountIdentity> login({
    required String loginIdentifier,
    required String password,
  }) async {
    final normalizedIdentifier = normalizeLoginIdentifier(loginIdentifier);
    _validateIdentifier(normalizedIdentifier);
    final now = _clock().toUtc();
    final failureState = _loginFailures[normalizedIdentifier];
    if (failureState?.lockedUntil case final lockedUntil?
        when now.isBefore(lockedUntil)) {
      throw AccountLoginThrottled(lockedUntil);
    }
    if (failureState?.lockedUntil != null) {
      _loginFailures.remove(normalizedIdentifier);
    }

    final account =
        await (_database.select(
              _database.localAccounts,
            )..where((row) => row.loginIdentifier.equals(normalizedIdentifier)))
            .getSingleOrNull();
    if (account == null) {
      _recordFailedLogin(normalizedIdentifier, now);
      throw const InvalidAccountCredentials();
    }

    final verifier =
        await (_database.select(_database.credentialVerifiers)
              ..where((row) => row.accountId.equals(account.accountId)))
            .getSingleOrNull();
    if (verifier == null) {
      throw const FormatException(
        'The local account is missing its credential verifier.',
      );
    }

    final hash = PasswordHash(
      algorithm: verifier.algorithm,
      algorithmVersion: verifier.algorithmVersion,
      salt: verifier.salt,
      verifier: verifier.verifier,
      memoryKiB: verifier.memoryKiB,
      iterations: verifier.iterations,
      parallelism: verifier.parallelism,
    );
    if (!await _passwordHasher.verifyPassword(password, hash)) {
      _recordFailedLogin(normalizedIdentifier, now);
      throw const InvalidAccountCredentials();
    }

    _loginFailures.remove(normalizedIdentifier);
    return AccountIdentity(
      accountId: account.accountId,
      loginIdentifier: account.loginIdentifier,
      createdAt: account.createdAt,
    );
  }

  Future<void> deleteAccount(String accountId) =>
      _database.deleteAccount(accountId);

  static String normalizeLoginIdentifier(String loginIdentifier) =>
      loginIdentifier.trim().toLowerCase();

  void _recordFailedLogin(String identifier, DateTime now) {
    final previous = _loginFailures[identifier];
    final attempts = (previous?.attempts ?? 0) + 1;
    final lockedUntil = attempts >= maxFailedLoginAttempts
        ? now.add(loginLockoutDuration)
        : null;
    _loginFailures[identifier] = _LoginFailureState(
      attempts: attempts,
      lockedUntil: lockedUntil,
    );
  }

  void _validateIdentifier(String identifier) {
    if (identifier.isEmpty || identifier.length > 320) {
      throw const InvalidAccountIdentifier();
    }
  }

  void _validatePassword(String password) {
    if (password.length < minimumPasswordLength) {
      throw const InvalidAccountPassword();
    }
  }

  String _newAccountId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final value = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${value.substring(0, 8)}-${value.substring(8, 12)}-'
        '${value.substring(12, 16)}-${value.substring(16, 20)}-'
        '${value.substring(20)}';
  }
}

class AccountIdentity {
  const AccountIdentity({
    required this.accountId,
    required this.loginIdentifier,
    required this.createdAt,
  });

  final String accountId;
  final String loginIdentifier;
  final DateTime createdAt;
}

class AccountAlreadyExists implements Exception {
  const AccountAlreadyExists();
}

class InvalidAccountCredentials implements Exception {
  const InvalidAccountCredentials();
}

class AccountLoginThrottled implements Exception {
  const AccountLoginThrottled(this.retryAt);

  final DateTime retryAt;
}

class InvalidAccountIdentifier implements Exception {
  const InvalidAccountIdentifier();
}

class InvalidAccountPassword implements Exception {
  const InvalidAccountPassword();
}

class _LoginFailureState {
  const _LoginFailureState({required this.attempts, this.lockedUntil});

  final int attempts;
  final DateTime? lockedUntil;
}
