import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/features/settings/data/user_data_deleter.dart';
import 'package:sustainable_living_app/features/settings/data/user_data_exporter.dart';
import 'package:sustainable_living_app/features/settings/presentation/privacy_policy_screen.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'Android and iOS exclude the local database from platform backups',
    () async {
      final manifest = await File('android/app/src/main/AndroidManifest.xml')
          .readAsString();
      final androidRules = await File(
        'android/app/src/main/res/xml/backup_rules.xml',
      ).readAsString();
      final androidTransferRules = await File(
        'android/app/src/main/res/xml/data_extraction_rules.xml',
      ).readAsString();
      final appStartup = await File('lib/app/app.dart').readAsString();
      final databaseSource = await File(
        'lib/core/data/database/app_database.dart',
      ).readAsString();
      final iosHandler = await File('ios/Runner/AppDelegate.swift')
          .readAsString();

      expect(manifest, contains('android:allowBackup="false"'));
      expect(androidRules, contains('<exclude domain="database" path="." />'));
      expect(
        androidRules,
        contains('<exclude domain="sharedpref" path="." />'),
      );
      expect(
        androidTransferRules,
        contains('<exclude domain="database" path="." />'),
      );
      expect(
        appStartup,
        contains('await AppDatabase.excludeDatabaseFromBackup();'),
      );
      expect(databaseSource, contains('TargetPlatform.iOS'));
      expect(iosHandler, contains('isExcludedFromBackupKey'));
    },
  );

  testWidgets('privacy policy is available offline and readable', (
    tester,
  ) async {
    await tester.pumpWidget(const _TestApp(child: PrivacyPolicyScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Privacy policy'), findsOneWidget);
    expect(
      find.textContaining('Your data stays on this device'),
      findsOneWidget,
    );
    expect(find.textContaining('Export and deletion'), findsOneWidget);
  });

  test(
    'exports an allowlisted snapshot without credential verifiers',
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
          assumptions: '[]',
        ),
      );

      final exported = await UserDataExporter(database: database).exportData();
      final encoded = jsonEncode(exported);
      final userData = exported['userData'] as Map<String, Object?>;
      final account =
          (userData['accounts'] as List).single as Map<String, Object?>;
      final estimate =
          (userData['footprintEstimates'] as List).single
              as Map<String, Object?>;

      expect(exported['exportSchemaVersion'], 1);
      expect(account['loginIdentifier'], 'member@example.test');
      expect(estimate['estimateValue'], 12.5);
      expect(encoded, isNot(contains('credentialVerifiers')));
      expect(encoded, isNot(contains('"salt"')));
      expect(encoded, isNot(contains('"verifier"')));
      expect(encoded, isNot(contains('password')));
    },
  );

  test('cancelled deletion leaves account, data, and database open', () async {
    await _insertAccountWithData(database);
    var closeCalls = 0;
    var fileDeletionCalls = 0;
    var guestResetCalls = 0;
    final deleter = UserDataDeleter(
      database: database,
      closeDatabase: () async => closeCalls++,
      deleteDatabaseFiles: () async => fileDeletionCalls++,
      onGuestReset: () async => guestResetCalls++,
    );

    final result = await deleter.deleteAllUserData(confirmed: false);

    expect(result, UserDataDeletionResult.cancelled);
    expect(await database.select(database.localAccounts).get(), hasLength(1));
    expect(
      await database.select(database.footprintEstimates).get(),
      hasLength(1),
    );
    expect(closeCalls, 0);
    expect(fileDeletionCalls, 0);
    expect(guestResetCalls, 0);
  });

  test('confirmed deletion cascades rows, resets guest preferences, and closes storage', () async {
    await _insertAccountWithData(database);
    var closeCalls = 0;
    var fileDeletionCalls = 0;
    var guestResetCalls = 0;
    final deleter = UserDataDeleter(
      database: database,
      closeDatabase: () async => closeCalls++,
      deleteDatabaseFiles: () async => fileDeletionCalls++,
      onGuestReset: () async => guestResetCalls++,
    );

    final result = await deleter.deleteAllUserData(confirmed: true);

    expect(result, UserDataDeletionResult.deleted);
    expect(await database.select(database.localAccounts).get(), isEmpty);
    expect(await database.select(database.credentialVerifiers).get(), isEmpty);
    expect(await database.select(database.footprintEstimates).get(), isEmpty);
    final preferences =
        (await database.select(database.userPreferences).get()).single;
    expect(preferences.displayLanguageTag, 'en');
    expect(preferences.selectedRegionId, isNull);
    expect(preferences.reducedMotion, isNull);
    expect(closeCalls, 1);
    expect(fileDeletionCalls, 1);
    expect(guestResetCalls, 1);
  });
}

Future<void> _insertAccountWithData(AppDatabase database) async {
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
      salt: Uint8List.fromList([7, 8, 9]),
      verifier: Uint8List.fromList([10, 11, 12]),
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
      answers: '{}',
      estimateValue: 12,
      unit: 'kg CO2e/year',
      questionnaireVersion: '1',
      completionState: 'complete',
      assumptions: '[]',
    ),
  );
  await database.savePreferences(
    UserPreferencesCompanion(
      preferenceId: const Value(1),
      displayLanguageTag: const Value('fr'),
      selectedRegionId: const Value('region-test'),
      reducedMotion: const Value(true),
      updatedAt: Value(DateTime.utc(2026)),
    ),
  );
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.light,
    home: child,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
  );
}
