import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/features/onboarding/domain/footprint_calculator.dart';
import 'package:sustainable_living_app/features/onboarding/domain/footprint_estimate.dart';

void main() {
  const calculator = FootprintCalculator();

  const electricityFactor = EmissionFactor(
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
    methodology: 'Synthetic test value; not an environmental claim.',
  );
  const transportFactor = EmissionFactor(
    factorId: 'demo-transport',
    category: 'transport',
    activityId: 'transport',
    value: 0.1,
    numeratorUnit: 'kg CO2e',
    denominatorUnit: 'km',
    source: FactorSource(
      sourceId: 'demo-source',
      title: 'Demonstration fixture only',
      publicationYear: 2026,
    ),
    validFrom: '2026-01-01',
    methodology: 'Synthetic test value; not an environmental claim.',
  );

  test(
    'calculates annual CO2e using matching factors without early rounding',
    () {
      final result = calculator.calculate(
        answers: const FootprintAnswers(
          questionnaireVersion: '1',
          periodYear: 2026,
          activities: [
            ActivityInput(
              activityId: 'electricity',
              amount: 100.5,
              unit: 'kWh',
            ),
            ActivityInput(activityId: 'transport', amount: 200.25, unit: 'km'),
          ],
        ),
        factors: const [electricityFactor, transportFactor],
      );

      expect(result, isA<CompleteEstimate>());
      final estimate = result as CompleteEstimate;
      expect(estimate.unit, 'kg CO2e/year');
      expect(estimate.value, closeTo(45.15, 1e-10));
      expect(estimate.factorsUsed, [electricityFactor, transportFactor]);
      expect(estimate.categoryTotals.map((item) => item.category).toList(), [
        'electricity',
        'transport',
      ]);
      expect(estimate.categoryTotals[0].value, 25.125);
      expect(estimate.categoryTotals[1].value, closeTo(20.025, 1e-10));
      expect(
        estimate.categoryTotals.fold<double>(
          0,
          (sum, category) => sum + category.value,
        ),
        closeTo(estimate.value, 1e-10),
      );
      expect(estimate.displayValue, '45.15');
    },
  );

  test('preserves a cited kg CO factor unit without labelling it CO2e', () {
    const pakistanElectricityFactor = EmissionFactor(
      factorId: 'electricity-grid',
      category: 'electricity',
      activityId: 'electricity',
      value: 0.347,
      numeratorUnit: 'kg CO2',
      denominatorUnit: 'kWh',
      source: FactorSource(
        sourceId: 'ember-yearly-electricity-2025',
        title: 'Yearly Electricity Data',
        publisher: 'Ember',
        publicationYear: 2025,
      ),
      validFrom: '2025-01-01',
      methodology: 'Cited Pakistan grid factor.',
    );
    final result = calculator.calculate(
      answers: const FootprintAnswers(
        questionnaireVersion: '1',
        periodYear: 2025,
        regionId: 'PK',
        activities: [
          ActivityInput(activityId: 'electricity', amount: 100, unit: 'kWh'),
        ],
      ),
      factors: const [pakistanElectricityFactor],
    ) as CompleteEstimate;

    expect(result.value, closeTo(34.7, 1e-10));
    expect(result.unit, 'kg CO2/year');
    expect(result.factorsUsed.single.source.publicationYear, 2025);
  });

  test('does not combine CO2 and CO2e factors', () {
    const co2Factor = EmissionFactor(
      factorId: 'co2-electricity',
      category: 'electricity',
      activityId: 'electricity',
      value: 0.347,
      numeratorUnit: 'kg CO2',
      denominatorUnit: 'kWh',
      source: FactorSource(
        sourceId: 'source',
        title: 'Source',
        publicationYear: 2025,
      ),
      validFrom: '2025-01-01',
      methodology: 'Cited CO2 factor.',
    );
    expect(
      () => calculator.calculate(
        answers: const FootprintAnswers(
          questionnaireVersion: '1',
          periodYear: 2025,
          activities: [
            ActivityInput(activityId: 'electricity', amount: 1, unit: 'kWh'),
            ActivityInput(activityId: 'transport', amount: 1, unit: 'km'),
          ],
        ),
        factors: const [co2Factor, transportFactor],
      ),
      throwsA(isA<UnavailableEstimateFactor>()),
    );
  });

  test('rejects negative and non-finite activity input', () {
    for (final amount in <double>[-1, double.nan, double.infinity]) {
      expect(
        () => calculator.calculate(
          answers: FootprintAnswers(
            questionnaireVersion: '1',
            periodYear: 2026,
            activities: [
              ActivityInput(
                activityId: 'electricity',
                amount: amount,
                unit: 'kWh',
              ),
            ],
          ),
          factors: const [electricityFactor],
        ),
        throwsA(isA<InvalidEstimateInput>()),
      );
    }
  });

  test(
    'returns an incomplete estimate without treating missing answers as zero',
    () {
      final result = calculator.calculate(
        answers: const FootprintAnswers(
          questionnaireVersion: '1',
          periodYear: 2026,
          activities: [
            ActivityInput(activityId: 'electricity', amount: null, unit: 'kWh'),
          ],
        ),
        factors: const [electricityFactor],
      );

      expect(result, isA<IncompleteEstimate>());
      expect((result as IncompleteEstimate).missingActivityIds, [
        'electricity',
      ]);
    },
  );

  test(
    'returns unavailable instead of using an invalid or mismatched factor',
    () {
      expect(
        () => calculator.calculate(
          answers: const FootprintAnswers(
            questionnaireVersion: '1',
            periodYear: 2026,
            activities: [
              ActivityInput(activityId: 'electricity', amount: 10, unit: 'kWh'),
            ],
          ),
          factors: const [],
        ),
        throwsA(isA<UnavailableEstimateFactor>()),
      );

      expect(
        () => calculator.calculate(
          answers: const FootprintAnswers(
            questionnaireVersion: '1',
            periodYear: 2026,
            activities: [
              ActivityInput(activityId: 'electricity', amount: 10, unit: 'kWh'),
            ],
          ),
          factors: const [transportFactor],
        ),
        throwsA(isA<UnavailableEstimateFactor>()),
      );
    },
  );

  test('rejects factors with unsupported units or invalid values', () {
    final invalidUnit = EmissionFactor(
      factorId: 'bad-unit',
      category: 'electricity',
      activityId: 'electricity',
      value: 1,
      numeratorUnit: 'points',
      denominatorUnit: 'kWh',
      source: electricityFactor.source,
      validFrom: '2026-01-01',
      methodology: 'Invalid unit.',
    );
    final invalidValue = EmissionFactor(
      factorId: 'bad-value',
      category: 'electricity',
      activityId: 'electricity',
      value: -1,
      numeratorUnit: 'kg CO2e',
      denominatorUnit: 'kWh',
      source: electricityFactor.source,
      validFrom: '2026-01-01',
      methodology: 'Invalid value.',
    );

    for (final factor in [invalidUnit, invalidValue]) {
      expect(
        () => calculator.calculate(
          answers: const FootprintAnswers(
            questionnaireVersion: '1',
            periodYear: 2026,
            activities: [
              ActivityInput(activityId: 'electricity', amount: 10, unit: 'kWh'),
            ],
          ),
          factors: [factor],
        ),
        throwsA(isA<UnavailableEstimateFactor>()),
      );
    }
  });
}
