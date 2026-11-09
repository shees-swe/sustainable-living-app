import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/app/app.dart';
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/core/data/regions/foundation_references.dart';
import 'package:sustainable_living_app/core/data/regions/region_repository.dart';
import 'package:sustainable_living_app/features/onboarding/data/estimate_demo_fixtures.dart';
import 'package:sustainable_living_app/features/onboarding/data/footprint_estimate_repository.dart';
import 'package:sustainable_living_app/features/onboarding/domain/footprint_calculator.dart';
import 'package:sustainable_living_app/features/onboarding/domain/footprint_estimate.dart';

void main() {
  late RegionRepository regionRepository;
  late FoundationReferences foundationReferences;

  setUpAll(() async {
    regionRepository = await RegionRepository.loadBundled();
    foundationReferences = await FoundationReferences.loadBundled();
  });

  testWidgets('first launch offers guest onboarding before Home', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await database.close();
    });

    await tester.pumpWidget(
      SustainableLivingApp(
        database: database,
        regionRepository: regionRepository,
        foundationReferences: foundationReferences,
      ),
    );
    await _pumpUntilVisible(tester, find.text('Choose a region'));
    await _pumpUntilVisible(tester, find.text('Demo region (demo only)'));

    expect(find.text('Demo region (demo only)'), findsOneWidget);
    expect(find.text('Annual electricity use (kWh)'), findsNothing);
    expect(find.text('Sign in'), findsNothing);
  });

  testWidgets('startup restores a saved guest estimate without an account', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = FootprintEstimateRepository(database: database);
    final region = foundationEstimateDemoRegions.single;
    const answers = FootprintAnswers(
      questionnaireVersion: '1',
      periodYear: 2026,
      activities: [
        ActivityInput(activityId: 'electricity', amount: 100, unit: 'kWh'),
        ActivityInput(activityId: 'transport', amount: 200, unit: 'km'),
      ],
    );
    final estimate = const FootprintCalculator().calculate(
      answers: answers,
      factors: region.factors,
    ) as CompleteEstimate;
    await repository.saveCompleteEstimate(answers: answers, estimate: estimate);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await database.close();
    });
    await tester.pumpWidget(
      SustainableLivingApp(
        database: database,
        regionRepository: regionRepository,
        foundationReferences: foundationReferences,
      ),
    );
    await _pumpUntilVisible(tester, find.text('Sustainable Living Guide'));
    expect(find.text('Choose a region'), findsNothing);
    await _pumpUntilVisible(tester, find.text('View your saved estimate'));

    expect(find.text('Sustainable Living Guide'), findsOneWidget);
    expect(find.text('Sign in'), findsNothing);

    await tester.tap(find.text('View your saved estimate'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await _pumpUntilVisible(
      tester,
      find.text('DEMO ONLY — not a verified estimate'),
    );

    expect(find.text('Your estimated footprint'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Factors used in this estimate'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Factors used in this estimate'), findsOneWidget);
    expect(find.textContaining('Publication year: 2026'), findsWidgets);
  });
}

Future<void> _pumpUntilVisible(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 30; attempt++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
  fail('Widget did not appear: $finder');
}
