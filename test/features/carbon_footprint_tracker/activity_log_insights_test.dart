import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/core/data/regions/region_repository.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/features/carbon_footprint_tracker/data/activity_log_repository.dart';
import 'package:sustainable_living_app/features/carbon_footprint_tracker/domain/activity_log_insights.dart';
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

  test(
    'monthly totals reconcile, shares are correct, and rankings are true',
    () async {
      addTearDown(database.close);
      final year = DateTime.now().year;
      for (final activity in [
        (DateTime(year, 1, 14), 100.0),
        (DateTime(year, 3, 10), 200.0),
        (DateTime(year, 3, 3), 50.0),
        (DateTime(year, 4, 5), 10.0),
        (DateTime(year - 1, 12, 31), 1000.0),
      ]) {
        await repository.addElectricity(
          date: activity.$1,
          amountKwh: activity.$2,
          regionId: 'PK',
          factors: factors,
        );
      }

      final entries = await database.select(database.activityLogEntries).get();
      final insights = ActivityLogInsights.fromEntries(
        entries: entries,
        year: year,
      );

      expect(insights.months.map((month) => month.month), [1, 3, 4]);
      expect(
        insights.months.fold<int>(0, (total, month) => total + month.kgCents),
        insights.yearTotalCents,
      );
      expect(insights.yearTotalCents, 12492);
      expect(insights.months[0].kg, 34.7);
      expect(insights.months[1].kg, 86.75);
      expect(insights.months[2].kg, 3.47);
      expect(insights.months[0].share, closeTo(34.7 / 124.92, 0.000001));
      expect(insights.months[1].share, closeTo(86.75 / 124.92, 0.000001));
      expect(insights.months[2].share, closeTo(3.47 / 124.92, 0.000001));
      expect(insights.highestMonth, 3);
      expect(insights.highestMonthKg, 86.75);
      expect(insights.topContributions.map((entry) => entry.amount), [
        200,
        100,
        50,
      ]);
    },
  );

  testWidgets(
    'empty insights reuse the log empty state without zeros or bars',
    (tester) async {
      await _openInsights(tester, repository: repository, factors: factors);

      expect(
        find.text('No activities logged for this period yet.'),
        findsOneWidget,
      );
      expect(
        find.textContaining('These insights include logged electricity only.'),
        findsOneWidget,
      );
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(
        find.byKey(const ValueKey('trackerInsightsYearTotal')),
        findsNothing,
      );

      await _closeInsightsTest(tester, database);
    },
  );

  testWidgets('one active month shows only its bar and true top contribution', (
    tester,
  ) async {
    final year = DateTime.now().year;
    await repository.addElectricity(
      date: DateTime(year, 6, 8),
      amountKwh: 20,
      regionId: 'PK',
      factors: factors,
    );
    await _openInsights(tester, repository: repository, factors: factors);

    expect(find.text('June'), findsOneWidget);
    expect(find.text('100.0% of year'), findsOneWidget);
    expect(find.text('Highest month: June — 6.94 kg CO2'), findsOneWidget);
    expect(find.text('20.00 kWh · 6.940 kg CO2'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('January'), findsNothing);
    expect(find.textContaining('trend'), findsNothing);

    await _closeInsightsTest(tester, database);
  });

  testWidgets('insights remain readable at 200 percent text size', (
    tester,
  ) async {
    final year = DateTime.now().year;
    await repository.addElectricity(
      date: DateTime(year, 2, 8),
      amountKwh: 12.5,
      regionId: 'PK',
      factors: factors,
    );
    await repository.addElectricity(
      date: DateTime(year, 9, 8),
      amountKwh: 92.5,
      regionId: 'PK',
      factors: factors,
    );
    await _openInsights(
      tester,
      repository: repository,
      factors: factors,
      textScale: 2,
    );

    expectNoTextOverlapOrClipping(tester, 'Tracker Insights');
    expect(tester.takeException(), isNull);

    await _closeInsightsTest(tester, database);
  });
}

Future<void> _openInsights(
  WidgetTester tester, {
  required ActivityLogRepository repository,
  required List<EmissionFactor> factors,
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    _TestApp(
      textScale: textScale,
      child: CarbonFootprintDestinationScreen(
        repository: repository,
        regionId: 'PK',
        factors: factors,
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('View insights'));
  await tester.pumpAndSettle();
}

Future<void> _closeInsightsTest(
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
