import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/app/router.dart';
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/features/account/data/account_repository.dart';
import 'package:sustainable_living_app/features/account/data/password_hasher.dart';
import 'package:sustainable_living_app/features/account/presentation/account_screen.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

import '../../support/text_layout_expectations.dart';

void main() {
  late AppDatabase database;
  late AccountRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = AccountRepository(
      database: database,
      passwordHasher: _FakePasswordHasher(),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('registers normalized identifiers and rejects duplicates', () async {
    final account = await repository.register(
      loginIdentifier: '  Member@Example.Test ',
      password: 'a-valid-local-password',
    );

    expect(account.loginIdentifier, 'member@example.test');
    await expectLater(
      repository.register(
        loginIdentifier: 'member@example.test',
        password: 'another-valid-password',
      ),
      throwsA(isA<AccountAlreadyExists>()),
    );
    expect(await database.select(database.localAccounts).get(), hasLength(1));
  });

  test(
    'login succeeds locally, rejects bad credentials, and throttles attempts',
    () async {
      await repository.register(
        loginIdentifier: 'member@example.test',
        password: 'correct-local-password',
      );

      expect(
        (await repository.login(
          loginIdentifier: ' MEMBER@example.test ',
          password: 'correct-local-password',
        )).loginIdentifier,
        'member@example.test',
      );
      await expectLater(
        repository.login(
          loginIdentifier: 'member@example.test',
          password: 'wrong-password',
        ),
        throwsA(isA<InvalidAccountCredentials>()),
      );

      for (
        var attempt = 0;
        attempt < AccountRepository.maxFailedLoginAttempts - 1;
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
          password: 'correct-local-password',
        ),
        throwsA(isA<AccountLoginThrottled>()),
      );
    },
  );

  testWidgets(
    'registration and login are optional and public routes stay open',
    (tester) async {
      await tester.pumpWidget(
        _TestApp(child: AccountScreen(repository: repository)),
      );

      expect(
        find.text('Account is optional. You can browse as a guest.'),
        findsOneWidget,
      );
      expect(find.text('Register'), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      final router = createAppRouter(initialLocation: '/carbon-footprint');
      addTearDown(router.dispose);
      await tester.pumpWidget(_TestApp(router: router));
      await tester.pumpAndSettle();
      expect(
        router.routeInformationProvider.value.uri.path,
        '/carbon-footprint',
      );
      expect(find.text('Carbon Footprint Tracker'), findsOneWidget);
      expect(
        find.text('No activities logged for this period yet.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('account remains readable at Very Large text', (tester) async {
    await tester.pumpWidget(
      _TestApp(textScale: 2, child: AccountScreen(repository: repository)),
    );

    expect(
      find.text('Account is optional. You can browse as a guest.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('accountIdentifier')), findsOneWidget);
    expect(find.byKey(const ValueKey('accountPassword')), findsOneWidget);
    expect(find.byKey(const ValueKey('accountSubmit')), findsOneWidget);
    expectNoTextOverlapOrClipping(tester, 'Account');
    expect(tester.takeException(), isNull);
  });

  testWidgets('account form reports registration and login errors locally', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(child: AccountScreen(repository: repository)),
    );

    await tester.enterText(
      find.byKey(const ValueKey('accountIdentifier')),
      'member@example.test',
    );
    await tester.enterText(
      find.byKey(const ValueKey('accountPassword')),
      'a-valid-local-password',
    );
    await tester.tap(find.text('Create local account'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Account created on this device.'), findsOneWidget);

    await tester.tap(find.text('Log in').last);
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey('accountPassword')),
      'wrong-password',
    );
    await tester.tap(find.byKey(const ValueKey('accountSubmit')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Identifier or password is incorrect.'), findsOneWidget);
  });
}

class _FakePasswordHasher implements CredentialHasher {
  var _saltCounter = 0;

  @override
  Future<PasswordHash> hashPassword(String password) async {
    _saltCounter++;
    return PasswordHash(
      algorithm: 'argon2id',
      algorithmVersion: 'test',
      salt: Uint8List.fromList([_saltCounter]),
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

class _TestApp extends StatelessWidget {
  const _TestApp({this.child, this.router, this.textScale = 1});

  final Widget? child;
  final RouterConfig<Object>? router;
  final double textScale;

  @override
  Widget build(BuildContext context) {
    final app = router == null
        ? MaterialApp(
            theme: AppTheme.light,
            home: child,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
          )
        : MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
          );
    return ProviderScope(child: app);
  }
}
