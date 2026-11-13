import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/core/data/regions/foundation_references.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/features/onboarding/data/estimate_demo_fixtures.dart';
import 'package:sustainable_living_app/features/onboarding/data/footprint_estimate_repository.dart';
import 'package:sustainable_living_app/features/onboarding/domain/footprint_estimate.dart';
import 'package:sustainable_living_app/features/onboarding/presentation/estimate_result_screen.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

import '../../../support/text_layout_expectations.dart';

void main() {
  late AppDatabase database;
  late FoundationReferences references;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    references = await FoundationReferences.loadBundled();
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('shows an honest lower-bound share of the cited budget', (
    tester,
  ) async {
    await _pumpResult(tester, database: database, references: references);

    expect(_plainText('at least 1.8% of the 1.5° budget'), findsOneWidget);
    final bar = tester.widget<LinearProgressIndicator>(
      find.byKey(const ValueKey('budgetShareBar')),
    );
    expect(bar.value, closeTo(0.018, 0.000001));
    expect(_plainText('2.5 t CO2e/person/year by 2030'), findsOneWidget);
    expect(find.textContaining('1.5-Degree Lifestyles'), findsOneWidget);
    expect(
      find.textContaining(
        'International Institute for Global Environmental Strategies',
      ),
      findsOneWidget,
    );
  });

  testWidgets('caps only the visual fill, not a share above the budget', (
    tester,
  ) async {
    await _pumpResult(
      tester,
      database: database,
      references: references,
      activities: const [
        ActivityInput(activityId: 'electricity', amount: 11000, unit: 'kWh'),
      ],
    );

    expect(_plainText('at least 110.0% of the 1.5° budget'), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(
            find.byKey(const ValueKey('budgetShareBar')),
          )
          .value,
      1,
    );
  });

  testWidgets('category amounts and bars reconcile to the displayed total', (
    tester,
  ) async {
    await _pumpResult(tester, database: database, references: references);

    final electricity = tester.widget<Text>(
      find.byKey(const ValueKey('categoryAmount-electricity')),
    );
    final transport = tester.widget<Text>(
      find.byKey(const ValueKey('categoryAmount-transport')),
    );
    final electricityAmount = _amount(electricity);
    final transportAmount = _amount(transport);
    expect(electricityAmount + transportAmount, 45);
    expect(electricityAmount, 25);
    expect(transportAmount, 20);
    expect(
      tester
          .widget<LinearProgressIndicator>(
            find.byKey(const ValueKey('categoryShareBar-electricity')),
          )
          .value,
      closeTo(25 / 45, 0.000001),
    );
    expect(
      tester
          .widget<LinearProgressIndicator>(
            find.byKey(const ValueKey('categoryShareBar-transport')),
          )
          .value,
      closeTo(20 / 45, 0.000001),
    );
    expect(_plainText('45.00 kg CO2e/year'), findsOneWidget);
  });

  testWidgets('coverage lists included and excluded available categories', (
    tester,
  ) async {
    await _pumpResult(
      tester,
      database: database,
      references: references,
      activities: const [
        ActivityInput(activityId: 'electricity', amount: 100, unit: 'kWh'),
      ],
    );

    final coverage = find.byKey(const ValueKey('estimateCoveragePanel'));
    expect(
      find.descendant(of: coverage, matching: find.text('Electricity')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: coverage, matching: find.text('Transport')),
      findsOneWidget,
    );
    expect(find.text('Included categories'), findsOneWidget);
    expect(find.text('Not included from available factors'), findsOneWidget);
  });

  testWidgets('demo labels remain visible on every result panel', (
    tester,
  ) async {
    await _pumpResult(tester, database: database, references: references);

    expect(find.text('DEMO ONLY — not a verified estimate'), findsOneWidget);
    for (final section in [
      'Lifestyle budget share',
      'Category breakdown',
      'Estimate coverage',
      'Factors used in this estimate',
    ]) {
      await _scrollUntilBuilt(tester, find.text(section));
      final headingRow = find
          .ancestor(of: find.text(section), matching: find.byType(Row))
          .first;
      expect(
        find.descendant(of: headingRow, matching: find.text('DEMO ONLY')),
        findsOneWidget,
      );
    }
    expect(find.text('Regional average'), findsNothing);
    expect(find.text('Global average'), findsNothing);
    expect(find.textContaining('EPA'), findsNothing);
    expect(find.byType(Skeletonizer), findsNothing);
  });

  testWidgets('result remains readable at Very Large text', (tester) async {
    await _pumpResult(
      tester,
      database: database,
      references: references,
      textScale: 2,
    );

    for (final section in [
      'Lifestyle budget share',
      'Category breakdown',
      'Estimate coverage',
      'Factors used in this estimate',
    ]) {
      await _scrollUntilBuilt(tester, find.text(section));
      expectNoTextOverlapOrClipping(
        tester,
        'Estimate result body: $section',
        within: find.byType(ListView),
      );
    }
    expectNoTextOverlapOrClipping(
      tester,
      'Estimate result AppBar',
      within: find.byType(AppBar),
    );
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpResult(
  WidgetTester tester, {
  required AppDatabase database,
  required FoundationReferences references,
  List<ActivityInput> activities = const [
    ActivityInput(activityId: 'electricity', amount: 100, unit: 'kWh'),
    ActivityInput(activityId: 'transport', amount: 200, unit: 'km'),
  ],
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    _TestApp(
      textScale: textScale,
      child: EstimateResultScreen(
        repository: FootprintEstimateRepository(database: database),
        onboardingData: OnboardingRouteData(
          region: foundationEstimateDemoRegions.single,
          answers: FootprintAnswers(
            questionnaireVersion: '1',
            periodYear: 2026,
            regionId: 'demo-region',
            activities: activities,
          ),
        ),
        foundationReferences: references,
      ),
    ),
  );
  for (var attempt = 0; attempt < 20; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (find.text('Your estimated footprint').evaluate().isNotEmpty) {
      await tester.pump(const Duration(milliseconds: 120));
      return;
    }
  }
  fail('The estimate result panels did not finish loading.');
}

Future<void> _scrollUntilBuilt(WidgetTester tester, Finder target) async {
  final scrollable = find.byType(Scrollable).first;
  for (var attempt = 0; attempt < 30; attempt++) {
    if (target.evaluate().isNotEmpty) return;
    await tester.drag(scrollable, const Offset(0, -300));
    await tester.pump();
  }
  fail('Could not scroll to $target.');
}

Finder _plainText(String value) => find.byWidgetPredicate(
  (widget) =>
      widget is Text &&
      (widget.data == value || widget.textSpan?.toPlainText() == value),
);

double _amount(Text text) {
  final value = text.textSpan!.toPlainText().split(' ').first;
  return double.parse(value);
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child, required this.textScale});

  final Widget child;
  final double textScale;

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
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
  );
}
