import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/features/onboarding/data/footprint_estimate_repository.dart';
import 'package:sustainable_living_app/features/onboarding/domain/footprint_calculator.dart';
import 'package:sustainable_living_app/features/onboarding/domain/footprint_estimate.dart';

void main() {
  late AppDatabase database;
  late FootprintEstimateRepository repository;

  const factor = EmissionFactor(
    factorId: 'demo-electricity',
    category: 'electricity',
    activityId: 'electricity',
    value: 0.25,
    numeratorUnit: 'kg CO2e',
    denominatorUnit: 'kWh',
    source: FactorSource(
      sourceId: 'demo-source',
      title: 'Demonstration fixture only',
      publicationYear: 2026,
    ),
    validFrom: '2026-01-01',
    methodology: 'Synthetic test value.',
  );
  const answers = FootprintAnswers(
    questionnaireVersion: '1',
    periodYear: 2026,
    activities: [
      ActivityInput(activityId: 'electricity', amount: 100, unit: 'kWh'),
    ],
  );

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = FootprintEstimateRepository(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'persists and hydrates a complete guest estimate without an account',
    () async {
      final result = FootprintCalculator().calculate(
        answers: answers,
        factors: const [factor],
      ) as CompleteEstimate;

      await repository.saveCompleteEstimate(answers: answers, estimate: result);
      final hydrated = await repository.loadLatestCompleteEstimate(
        factors: const [factor],
      );

      expect(hydrated?.value, 25);
      expect(
        hydrated?.factorsUsed.single.source.title,
        'Demonstration fixture only',
      );
      expect(await database.select(database.localAccounts).get(), isEmpty);
      expect(
        await database.select(database.footprintEstimates).get(),
        hasLength(1),
      );
    },
  );

  test('does not restore a saved estimate under a different region', () async {
    const pakistanAnswers = FootprintAnswers(
      questionnaireVersion: '1',
      periodYear: 2026,
      regionId: 'PK',
      activities: [
        ActivityInput(activityId: 'electricity', amount: 100, unit: 'kWh'),
      ],
    );
    final result = FootprintCalculator().calculate(
      answers: pakistanAnswers,
      factors: const [factor],
    ) as CompleteEstimate;
    await repository.saveCompleteEstimate(
      answers: pakistanAnswers,
      estimate: result,
    );

    expect(await repository.loadLatestEstimateRegionId(), 'PK');
    expect(
      await repository.loadLatestCompleteEstimate(
        factors: const [factor],
        expectedRegionId: 'demo-region',
      ),
      isNull,
    );
    expect(
      (await repository.loadLatestCompleteEstimate(
        factors: const [factor],
        expectedRegionId: 'PK',
      ))?.value,
      25,
    );
  });

  test('does not persist incomplete answers as a zero estimate', () async {
    const incompleteAnswers = FootprintAnswers(
      questionnaireVersion: '1',
      periodYear: 2026,
      activities: [
        ActivityInput(activityId: 'electricity', amount: null, unit: 'kWh'),
      ],
    );
    final result = FootprintCalculator().calculate(
      answers: incompleteAnswers,
      factors: const [factor],
    );

    expect(result, isA<IncompleteEstimate>());
    expect(
      await repository.loadLatestCompleteEstimate(factors: const [factor]),
      isNull,
    );
    expect(await database.select(database.footprintEstimates).get(), isEmpty);
  });
}
