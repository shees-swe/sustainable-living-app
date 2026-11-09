import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/features/onboarding/domain/reference_comparison.dart';
import 'package:sustainable_living_app/features/onboarding/domain/reference_value.dart';

void main() {
  const service = ReferenceComparisonService();
  const estimate = EstimateComparisonBasis(
    value: 1500,
    unit: 'kg CO2e/year',
    period: '2026',
    accountingBoundary: 'annual consumption footprint per person',
  );
  const source = ReferenceSource(
    sourceId: 'demo-reference',
    title: 'Demonstration fixture only',
    publisher: 'Foundation test fixture',
    publicationYear: 2026,
  );

  test(
    'returns a sourced value only when period, units, and boundary match',
    () {
      const reference = ReferenceValue(
        referenceId: 'global-average',
        value: 2000,
        unit: 'kg CO2e/year',
        period: '2026',
        sourceId: 'demo-reference',
        methodology: 'Synthetic fixture methodology.',
        accountingBoundary: 'annual consumption footprint per person',
      );

      final result = service.compare(
        estimate: estimate,
        reference: reference,
        sources: const {'demo-reference': source},
      );

      expect(result.status, ReferenceComparisonStatus.available);
      expect(result.value, 2000);
      expect(result.source, source);
    },
  );

  test('returns unavailable when accounting boundaries differ', () {
    const reference = ReferenceValue(
      referenceId: 'global-average',
      value: 2000,
      unit: 'kg CO2e/year',
      period: '2026',
      sourceId: 'demo-reference',
      methodology: 'Synthetic fixture methodology.',
      accountingBoundary: 'territorial CO2 only',
    );

    final result = service.compare(
      estimate: estimate,
      reference: reference,
      sources: const {'demo-reference': source},
    );

    expect(result.status, ReferenceComparisonStatus.unavailable);
    expect(result.value, isNull);
  });

  test('returns unavailable for period, unit, source, or value mismatch', () {
    final references = [
      const ReferenceValue(
        referenceId: 'global-average',
        value: 2000,
        unit: 'kg CO2e/year',
        period: '2025',
        sourceId: 'demo-reference',
        methodology: 'Fixture.',
        accountingBoundary: 'annual consumption footprint per person',
      ),
      const ReferenceValue(
        referenceId: 'global-average',
        value: 2000,
        unit: 'tonnes CO2e/year',
        period: '2026',
        sourceId: 'demo-reference',
        methodology: 'Fixture.',
        accountingBoundary: 'annual consumption footprint per person',
      ),
      const ReferenceValue(
        referenceId: 'global-average',
        value: 2000,
        unit: 'kg CO2e/year',
        period: '2026',
        sourceId: 'missing-source',
        methodology: 'Fixture.',
        accountingBoundary: 'annual consumption footprint per person',
      ),
      const ReferenceValue.unavailable(
        referenceId: 'global-average',
        reason: 'No verified fixture value.',
      ),
    ];

    for (final reference in references) {
      final result = service.compare(
        estimate: estimate,
        reference: reference,
        sources: const {'demo-reference': source},
      );

      expect(result.status, ReferenceComparisonStatus.unavailable);
      expect(result.value, isNull);
    }
  });

  test('never substitutes a missing selected region reference', () {
    const regionalReference = ReferenceValue.unavailable(
      referenceId: 'regional-average',
      reason: 'No region has been verified.',
    );

    final result = service.compare(
      estimate: estimate,
      reference: regionalReference,
      sources: const {'demo-reference': source},
    );

    expect(result.status, ReferenceComparisonStatus.unavailable);
    expect(result.value, isNull);
    expect(result.reason, 'No region has been verified.');
  });
}
