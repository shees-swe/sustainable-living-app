import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/core/data/regions/foundation_references.dart';
import 'package:sustainable_living_app/core/data/regions/region_repository.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/features/carbon_footprint_tracker/data/activity_log_repository.dart';
import 'package:sustainable_living_app/features/carbon_footprint_tracker/domain/activity_log_recommendations.dart';
import 'package:sustainable_living_app/features/carbon_footprint_tracker/presentation/module_destination_screen.dart';
import 'package:sustainable_living_app/features/onboarding/data/estimate_demo_fixtures.dart';
import 'package:sustainable_living_app/features/onboarding/domain/footprint_estimate.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

import '../../support/text_layout_expectations.dart';

void main() {
  late AppDatabase database;
  late ActivityLogRepository repository;
  late List<EmissionFactor> factors;
  late FoundationReferences references;

  setUpAll(() async {
    final regionRepository = await RegionRepository.loadBundled();
    factors = emissionFactorsFromRegionPack(
      regionRepository.requireRegion('PK'),
    );
    references = await FoundationReferences.loadBundled();
  });

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = ActivityLogRepository(
      database: database,
      clock: () => DateTime.utc(2030, 11, 12),
    );
  });

  test(
    'scenario, average, lowest month, gap, and budget share use logged values',
    () async {
      await _addFixtures(repository, factors, 2030);
      final entries = await database.select(database.activityLogEntries).get();
      final recommendations = ActivityLogRecommendations.fromEntries(
        entries: entries,
        year: 2030,
        factors: factors,
        references: references,
      );

      expect(recommendations.peakMonth, 3);
      expect(recommendations.peakMonthKg, 86.75);
      expect(recommendations.scenarioSavingsKg, 8.68);
      expect(recommendations.averageMonthKg, 41.64);
      expect(recommendations.lowestMonth, 4);
      expect(recommendations.lowestMonthKg, 3.47);
      expect(recommendations.monthlyGapKg, 38.17);
      expect(recommendations.budgetShare, closeTo(124.92 / 2500, 0.000001));

      final incompatible = ActivityLogRecommendations.fromEntries(
        entries: entries,
        year: 2030,
        factors: const [],
        references: references,
      );
      expect(incompatible.budgetShare, isNull);
      await database.close();
    },
  );

  testWidgets('empty recommendations reuse the log empty state', (
    tester,
  ) async {
    await _openRecommendations(
      tester,
      repository,
      factors,
      references: references,
    );

    expect(
      find.text('No activities logged for this period yet.'),
      findsOneWidget,
    );
    expect(find.text('Scenario — not a promise'), findsNothing);
    expect(find.textContaining('At least'), findsNothing);

    await _closeRecommendationsTest(tester, database);
  });

  testWidgets('one month shows its scenario and budget without a spread line', (
    tester,
  ) async {
    final year = DateTime.now().year;
    await repository.addElectricity(
      date: DateTime(year, 6, 8),
      amountKwh: 20,
      regionId: 'PK',
      factors: factors,
    );
    await _openRecommendations(
      tester,
      repository,
      factors,
      references: references,
    );

    expect(find.text('Peak month: June'), findsOneWidget);
    expect(find.text('A 10% cut in June would have saved'), findsOneWidget);
    expect(find.text('0.69 kg CO2'), findsOneWidget);
    expect(
      find.text(
        'At least 0.3% of the 2.5 t CO2e/person/year budget by 2030 '
        '— from electricity alone.',
      ),
      findsOneWidget,
    );
    expect(find.text('Average across months with entries'), findsNothing);
    expect(find.text('Gap from average to lowest month'), findsNothing);

    await _closeRecommendationsTest(tester, database);
  });

  testWidgets('recommendations remain readable at 200 percent text size', (
    tester,
  ) async {
    await _addFixtures(repository, factors, DateTime.now().year);
    await _openRecommendations(
      tester,
      repository,
      factors,
      references: references,
      textScale: 2,
    );

    expectNoTextOverlapOrClipping(tester, 'Tracker Recommendations');
    expect(tester.takeException(), isNull);
    final budgetLine = findTextContaining('from electricity alone');
    await tester.scrollUntilVisible(
      budgetLine,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(budgetLine, findsOneWidget);
    expect(tester.takeException(), isNull);

    await _closeRecommendationsTest(tester, database);
  });
}

Future<void> _addFixtures(
  ActivityLogRepository repository,
  List<EmissionFactor> factors,
  int year,
) async {
  for (final activity in [
    (DateTime(year, 1, 14), 100.0),
    (DateTime(year, 3, 10), 200.0),
    (DateTime(year, 3, 3), 50.0),
    (DateTime(year, 4, 5), 10.0),
  ]) {
    await repository.addElectricity(
      date: activity.$1,
      amountKwh: activity.$2,
      regionId: 'PK',
      factors: factors,
    );
  }
}

Future<void> _openRecommendations(
  WidgetTester tester,
  ActivityLogRepository repository,
  List<EmissionFactor> factors, {
  required FoundationReferences references,
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    _TestApp(
      textScale: textScale,
      child: CarbonFootprintDestinationScreen(
        repository: repository,
        regionId: 'PK',
        factors: factors,
        references: references,
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('View recommendations'));
  final coverage = find.text(
    'These recommendations use your logged electricity only. '
    'They are scenarios based on your entries, not promises.',
  );
  for (
    var attempt = 0;
    attempt < 20 && coverage.evaluate().isEmpty;
    attempt++
  ) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(coverage, findsOneWidget);
  await tester.pump(const Duration(milliseconds: 150));
}

Future<void> _closeRecommendationsTest(
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
