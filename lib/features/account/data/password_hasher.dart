import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography_plus/cryptography_plus.dart';

abstract interface class CredentialHasher {
  Future<PasswordHash> hashPassword(String password);

  Future<bool> verifyPassword(String password, PasswordHash hash);
}

class PasswordHash {
  PasswordHash({
    required this.algorithm,
    required this.algorithmVersion,
    required List<int> salt,
    required List<int> verifier,
    required this.memoryKiB,
    required this.iterations,
    required this.parallelism,
  }) : salt = Uint8List.fromList(salt),
       verifier = Uint8List.fromList(verifier);

  final String algorithm;
  final String algorithmVersion;
  final Uint8List salt;
  final Uint8List verifier;
  final int memoryKiB;
  final int iterations;
  final int parallelism;
}

class PasswordHasher implements CredentialHasher {
  const PasswordHasher({
    this.memoryKiB = minimumMemoryKiB,
    this.iterations = minimumIterations,
    this.parallelism = minimumParallelism,
  });

  static const int minimumMemoryKiB = 19456;
  static const int minimumIterations = 2;
  static const int minimumParallelism = 1;
  static const int outputLength = 32;
  static const int saltLength = 16;
  static const int argon2Version = 19;
  static const String storedAlgorithmVersion =
      'argon2id-v19-cryptography_plus-3.0.0';

  final int memoryKiB;
  final int iterations;
  final int parallelism;

  @override
  Future<PasswordHash> hashPassword(String password) async {
    _validateParameters();
    if (password.isEmpty) {
      throw ArgumentError.value(password, 'password', 'Must not be empty.');
    }

    final salt = _generateSalt();
    final verifier = await _derive(password, salt);
    return PasswordHash(
      algorithm: 'argon2id',
      algorithmVersion: storedAlgorithmVersion,
      salt: salt,
      verifier: verifier,
      memoryKiB: memoryKiB,
      iterations: iterations,
      parallelism: parallelism,
    );
  }

  @override
  Future<bool> verifyPassword(String password, PasswordHash hash) async {
    _validateStoredHash(hash);
    if (password.isEmpty) return false;
    final derived = await _derive(
      password,
      hash.salt,
      memoryKiB: hash.memoryKiB,
      iterations: hash.iterations,
      parallelism: hash.parallelism,
    );
    return SecretKey(derived) == SecretKey(hash.verifier);
  }

  Future<Uint8List> _derive(
    String password,
    List<int> salt, {
    int? memoryKiB,
    int? iterations,
    int? parallelism,
  }) async {
    final algorithm = Argon2id(
      memory: memoryKiB ?? this.memoryKiB,
      iterations: iterations ?? this.iterations,
      parallelism: parallelism ?? this.parallelism,
      hashLength: outputLength,
    );
    final key = await algorithm.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
    return Uint8List.fromList(await key.extractBytes());
  }

  List<int> _generateSalt() {
    final random = Random.secure();
    return List<int>.generate(saltLength, (_) => random.nextInt(256));
  }

  void _validateParameters() {
    if (memoryKiB < minimumMemoryKiB ||
        iterations < minimumIterations ||
        parallelism < minimumParallelism) {
      throw ArgumentError(
        'Argon2id parameters must meet or exceed the OWASP minimum.',
      );
    }
  }

  void _validateStoredHash(PasswordHash hash) {
    if (hash.algorithm != 'argon2id' ||
        hash.algorithmVersion != storedAlgorithmVersion ||
        hash.memoryKiB < minimumMemoryKiB ||
        hash.iterations < minimumIterations ||
        hash.parallelism < minimumParallelism ||
        hash.salt.length != saltLength ||
        hash.verifier.length != outputLength) {
      throw const FormatException('Stored Argon2id verifier is invalid.');
    }
  }
}
