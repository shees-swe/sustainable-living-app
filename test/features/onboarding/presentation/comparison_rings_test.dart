import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/features/onboarding/data/estimate_demo_fixtures.dart';
import 'package:sustainable_living_app/features/onboarding/domain/footprint_calculator.dart';
import 'package:sustainable_living_app/features/onboarding/domain/footprint_estimate.dart';
import 'package:sustainable_living_app/features/onboarding/domain/reference_comparison.dart';
import 'package:sustainable_living_app/features/onboarding/domain/reference_value.dart';
import 'package:sustainable_living_app/features/onboarding/presentation/comparison_rings.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

void main() {
  final region = foundationEstimateDemoRegions.single;
  final estimate = FootprintCalculator().calculate(
    answers: const FootprintAnswers(
      questionnaireVersion: '1',
      periodYear: 2026,
      activities: [
        ActivityInput(activityId: 'electricity', amount: 100, unit: 'kWh'),
      ],
    ),
    factors: [region.factors.first],
  ) as CompleteEstimate;

  testWidgets('available ring exposes exact values and source details', (
    tester,
  ) async {
    final comparison = const ReferenceComparisonService().compare(
      estimate: EstimateComparisonBasis(
        value: 25,
        unit: 'kg CO2e/year',
        period: '2026',
        accountingBoundary: 'annual consumption footprint per person',
      ),
      reference: region.references.first,
      sources: {region.source.sourceId: region.source},
    );

    await tester.pumpWidget(
      _TestApp(
        child: ComparisonRing(
          label: 'Regional average',
          estimate: estimate,
          comparison: comparison,
        ),
      ),
    );

    expect(find.byType(PieChart), findsOneWidget);
    expect(find.text('Your estimate: 25.00 kg CO2e/year'), findsOneWidget);
    expect(find.text('Reference: 1800.00 kg CO2e/year'), findsOneWidget);
    expect(find.text('Period: 2026'), findsOneWidget);
    expect(find.text('Publication year: 2026'), findsOneWidget);
    expect(find.textContaining('Demonstration fixture only'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        RegExp('Regional average\\. 25\\.00 kg CO2e/year; reference'),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'reduced motion renders the ring at its target without animating',
    (tester) async {
      final comparison = const ReferenceComparisonService().compare(
        estimate: EstimateComparisonBasis(
          value: 25,
          unit: 'kg CO2e/year',
          period: '2026',
          accountingBoundary: 'annual consumption footprint per person',
        ),
        reference: region.references.first,
        sources: {region.source.sourceId: region.source},
      );

      await tester.pumpWidget(
        _TestApp(
          disableAnimations: true,
          child: ComparisonRing(
            label: 'Regional average',
            estimate: estimate,
            comparison: comparison,
          ),
        ),
      );

      final targetRatio = estimate.value / 1800;
      final animation = find
          .ancestor(
            of: find.byType(PieChart),
            matching: find.byType(AnimatedBuilder),
          )
          .evaluate()
          .map((element) => element.widget)
          .whereType<AnimatedBuilder>()
          .map((builder) => builder.animation)
          .whereType<AnimationController>()
          .firstWhere(
            (controller) => (controller.value - targetRatio).abs() < 1e-9,
          );
      expect(animation.value, closeTo(targetRatio, 1e-9));
      expect(animation.isAnimating, isFalse);
    },
  );

  testWidgets('unavailable references are not drawn as zero-value rings', (
    tester,
  ) async {
    const unavailable = ReferenceComparisonResult.unavailable(
      reason: 'Missing selected region reference.',
    );

    await tester.pumpWidget(
      _TestApp(
        child: ComparisonRing(
          label: 'Regional average',
          estimate: estimate,
          comparison: unavailable,
        ),
      ),
    );

    expect(find.byType(PieChart), findsNothing);
    expect(find.text('Comparison unavailable'), findsOneWidget);
    expect(find.text('Reference: 0.00 kg CO2e/year'), findsNothing);
  });

  testWidgets('factor disclosure shows the actual rate, source, and year', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        child: CalculationFactorDisclosure(factors: estimate.factorsUsed),
      ),
    );

    expect(find.text('Electricity: 0.25 kg CO2e per kWh'), findsOneWidget);
    expect(find.textContaining('Demonstration fixture only'), findsOneWidget);
    expect(find.textContaining('Publication year: 2026'), findsOneWidget);
    expect(
      find.textContaining('Factor valid from: 2026-01-01'),
      findsOneWidget,
    );
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child, this.disableAnimations = false});

  final Widget child;
  final bool disableAnimations;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: child),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(disableAnimations: disableAnimations),
      child: child!,
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
