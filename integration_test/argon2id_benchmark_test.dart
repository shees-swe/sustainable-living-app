import 'dart:convert';
import 'dart:math';

import 'package:cryptography_plus/cryptography_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('benchmarks the OWASP Argon2id floor on the target device', (
    tester,
  ) async {
    final algorithm = Argon2id(
      memory: 19456,
      iterations: 2,
      parallelism: 1,
      hashLength: 32,
    );
    final password = utf8.encode('benchmark-only-not-a-user-password');
    final salt = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    final timings = <int>[];

    await algorithm.deriveKey(
      secretKey: SecretKey(password),
      nonce: salt,
    );
    for (var sample = 0; sample < 3; sample++) {
      final stopwatch = Stopwatch()..start();
      await algorithm.deriveKey(
        secretKey: SecretKey(password),
        nonce: salt,
      );
      stopwatch.stop();
      timings.add(stopwatch.elapsedMilliseconds);
    }

    timings.sort();
    // The test runner records this result for the device benchmark evidence.
    // ignore: avoid_print
    print(
      'ARGON2ID_BENCHMARK device=Infinix_X678B Android_API_34 '
      'package=cryptography_plus_3.0.0 version=${algorithm.version} '
      'memoryKiB=19456 iterations=2 parallelism=1 hashLength=32 '
      'samplesMs=$timings medianMs=${timings[1]}',
    );
    expect(timings, hasLength(3));
    expect(timings.every((timing) => timing > 0), isTrue);
  });
}
