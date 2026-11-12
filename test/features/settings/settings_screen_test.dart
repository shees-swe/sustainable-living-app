import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/features/settings/data/user_data_deleter.dart';
import 'package:sustainable_living_app/features/settings/data/user_data_exporter.dart';
import 'package:sustainable_living_app/features/settings/presentation/settings_screen.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

import '../../support/text_layout_expectations.dart';

void main() {
  late AppDatabase database;
  late int guestResetCalls;
  late int guestReturnCalls;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    guestResetCalls = 0;
    guestReturnCalls = 0;
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('settings remains readable at Very Large text', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        settings: _settings(
          database: database,
          onGuestReset: () async => guestResetCalls++,
          onGuestReturn: () async => guestReturnCalls++,
        ),
        textScale: 2,
      ),
    );

    expect(find.text('Privacy and personal data'), findsOneWidget);
    expect(find.text('Privacy policy'), findsOneWidget);
    expectNoTextOverlapOrClipping(tester, 'Settings');
    expect(tester.takeException(), isNull);
  });

  testWidgets('shares the allowlisted export and reports the share result', (
    tester,
  ) async {
    Map<String, Object?>? sharedExport;
    await tester.pumpWidget(
      _TestApp(
        settings: _settings(
          database: database,
          onGuestReset: () async => guestResetCalls++,
          onGuestReturn: () async => guestReturnCalls++,
          shareExport: (export) async {
            sharedExport = export;
            return const ShareResult('done', ShareResultStatus.success);
          },
        ),
      ),
    );

    await tester.tap(find.text('Export my data'));
    await tester.pumpAndSettle();

    expect(sharedExport?['exportSchemaVersion'], 5);
    expect(sharedExport?['userData'], isA<Map<String, Object?>>());
    expect(find.text('The data export was shared.'), findsOneWidget);
  });

  testWidgets(
    'cancelling deletion preserves data and does not reset guest state',
    (tester) async {
      await database
          .into(database.localAccounts)
          .insert(
            LocalAccountsCompanion.insert(
              accountId: 'account-1',
              loginIdentifier: 'member@example.test',
              createdAt: DateTime.utc(2026),
            ),
          );
      await tester.pumpWidget(
        _TestApp(
          settings: _settings(
            database: database,
            onGuestReset: () async => guestResetCalls++,
            onGuestReturn: () async => guestReturnCalls++,
          ),
        ),
      );

      await tester.tap(find.text('Delete local data'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(await database.select(database.localAccounts).get(), hasLength(1));
      expect(guestResetCalls, 0);
      expect(guestReturnCalls, 0);
      expect(
        find.text('Deletion cancelled. Your data was not changed.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('confirmed deletion clears data and returns to guest state', (
    tester,
  ) async {
    await database
        .into(database.localAccounts)
        .insert(
          LocalAccountsCompanion.insert(
            accountId: 'account-1',
            loginIdentifier: 'member@example.test',
            createdAt: DateTime.utc(2026),
          ),
        );
    await tester.pumpWidget(
      _TestApp(
        settings: _settings(
          database: database,
          onGuestReset: () async => guestResetCalls++,
          onGuestReturn: () async => guestReturnCalls++,
        ),
      ),
    );

    await tester.tap(find.text('Delete local data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete my data'));
    await tester.pumpAndSettle();

    expect(await database.select(database.localAccounts).get(), isEmpty);
    expect(guestResetCalls, 1);
    expect(guestReturnCalls, 1);
    expect(
      find.text('Local data deleted. Returning to guest Home.'),
      findsNWidgets(2),
    );
  });
}

SettingsScreen _settings({
  required AppDatabase database,
  required Future<void> Function() onGuestReset,
  required Future<void> Function() onGuestReturn,
  Future<ShareResult> Function(Map<String, Object?> export)? shareExport,
}) {
  return SettingsScreen(
    exporter: UserDataExporter(database: database),
    deleter: UserDataDeleter(
      database: database,
      closeDatabase: () async {},
      deleteDatabaseFiles: () async {},
      onGuestReset: onGuestReset,
    ),
    onGuestReturn: onGuestReturn,
    shareExport: shareExport,
  );
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.settings, this.textScale = 1});

  final SettingsScreen settings;
  final double textScale;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.light,
    home: settings,
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
}
