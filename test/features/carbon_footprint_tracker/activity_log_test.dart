import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/core/data/regions/region_repository.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/features/carbon_footprint_tracker/data/activity_log_repository.dart';
import 'package:sustainable_living_app/features/carbon_footprint_tracker/presentation/module_destination_screen.dart';
import 'package:sustainable_living_app/features/onboarding/data/estimate_demo_fixtures.dart';
import 'package:sustainable_living_app/features/onboarding/domain/footprint_estimate.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

import '../../support/text_layout_expectations.dart';

void main() {
  late AppDatabase database;
  late ActivityLogRepository repository;
  late List<EmissionFactor> factors;

  setUpAll(() async {
    final regionRepository = await RegionRepository.loadBundled();
    factors = emissionFactorsFromRegionPack(
      regionRepository.requireRegion('PK'),
    );
  });

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = ActivityLogRepository(
      database: database,
      clock: () => DateTime.utc(2026, 11, 12),
    );
  });

  testWidgets(
    'calculates cited electricity kg, lists newest first, sums the period, and deletes',
    (tester) async {
      final now = DateTime.now();
      await repository.addElectricity(
        date: DateTime(now.year, now.month, now.day - 2),
        amountKwh: 1,
        regionId: 'PK',
        factors: factors,
      );
      await repository.addElectricity(
        date: DateTime(now.year, now.month, now.day),
        amountKwh: 2,
        regionId: 'PK',
        factors: factors,
      );

      final stored = await database.select(database.activityLogEntries).get();
      expect(
        stored.map((entry) => entry.emissionsKg),
        containsAll([1 * factors.single.value, 2 * factors.single.value]),
      );
      expect(
        stored.fold<double>(0, (total, entry) => total + entry.emissionsKg),
        3 * factors.single.value,
      );

      await tester.pumpWidget(
        _TestApp(
          child: CarbonFootprintDestinationScreen(
            repository: repository,
            regionId: 'PK',
            factors: factors,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2.00 kWh'), findsOneWidget);
      expect(find.text('1.00 kWh'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('2.00 kWh')).dy,
        lessThan(tester.getTopLeft(find.text('1.00 kWh')).dy),
      );
      expect(find.text('1.04 kg CO2'), findsOneWidget);

      await tester.tap(find.byTooltip('Delete activity').first);
      await tester.pumpAndSettle();

      expect(
        await database.select(database.activityLogEntries).get(),
        hasLength(1),
      );
      expect(find.text('2.00 kWh'), findsNothing);
      expect(find.text('0.35 kg CO2'), findsOneWidget);
      await _closeTrackerTest(tester, database);
    },
  );

  testWidgets('transport and food are visible but disabled in the picker', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        child: CarbonFootprintDestinationScreen(
          repository: repository,
          regionId: 'PK',
          factors: factors,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add activity'));
    await tester.pumpAndSettle();

    expect(find.text('Transport'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Factor not available yet.'), findsNWidgets(2));
    for (final category in ['Transport', 'Food']) {
      final tile = tester.widget<ListTile>(
        find.ancestor(of: find.text(category), matching: find.byType(ListTile)),
      );
      expect(tile.enabled, isFalse);
    }

    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();
    expect(find.text('Add electricity'), findsNothing);

    await tester.tap(find.text('Home energy — electricity'));
    await tester.pumpAndSettle();
    final amountField = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const ValueKey('trackerAmountField')),
        matching: find.byType(TextField),
      ),
    );
    expect(amountField.style?.fontFamily, startsWith('IBMPlexMono'));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await _closeTrackerTest(tester, database);
  });

  testWidgets('screen remains readable at 200 percent text size', (
    tester,
  ) async {
    await repository.addElectricity(
      date: DateTime.now(),
      amountKwh: 100,
      regionId: 'PK',
      factors: factors,
    );
    await tester.pumpWidget(
      _TestApp(
        textScale: 2,
        child: CarbonFootprintDestinationScreen(
          repository: repository,
          regionId: 'PK',
          factors: factors,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expectNoTextOverlapOrClipping(tester, 'Carbon Footprint Tracker');
    expect(tester.takeException(), isNull);
    await _closeTrackerTest(tester, database);
  });

  test('activity survives closing and reopening the local database', () async {
    addTearDown(database.close);
    final directory = await Directory.systemTemp.createTemp('tracker-db-');
    final path = p.join(directory.path, 'activity.sqlite');
    var fileDatabase = AppDatabase.forTesting(NativeDatabase(File(path)));
    await ActivityLogRepository(database: fileDatabase).addElectricity(
      date: DateTime(2026, 11, 12),
      amountKwh: 12,
      regionId: 'PK',
      factors: factors,
    );
    await fileDatabase.close();

    fileDatabase = AppDatabase.forTesting(NativeDatabase(File(path)));
    addTearDown(() async {
      await fileDatabase.close();
      await directory.delete(recursive: true);
    });
    final reopened = await fileDatabase
        .select(fileDatabase.activityLogEntries)
        .getSingle();

    expect(reopened.amount, 12);
    expect(reopened.emissionsKg, 12 * factors.single.value);
    expect(reopened.regionId, 'PK');
  });
}

Future<void> _closeTrackerTest(
  WidgetTester tester,
  AppDatabase database,
) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
  await database.close();
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child, this.textScale = 1});

  final Widget child;
  final double textScale;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.light,
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: child,
    ),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
  );
}
