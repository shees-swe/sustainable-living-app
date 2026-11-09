import '../domain/footprint_estimate.dart';
import '../domain/reference_value.dart';
import '../../../core/data/regions/foundation_references.dart';
import '../../../core/data/regions/region_pack_parser.dart';

class EstimateDemoRegion {
  const EstimateDemoRegion({
    required this.regionId,
    required this.labelKey,
    required this.period,
    required this.accountingBoundary,
    required this.factors,
    required this.source,
    required this.references,
    required this.demoOnly,
  });

  final String regionId;
  final String labelKey;
  final String period;
  final String accountingBoundary;
  final List<EmissionFactor> factors;
  final ReferenceSource source;
  final List<ReferenceValue> references;
  final bool demoOnly;
}

class OnboardingRouteData {
  const OnboardingRouteData({required this.region, required this.answers});

  final EstimateDemoRegion region;
  final FootprintAnswers answers;
}

class RegionalOnboardingRouteData {
  const RegionalOnboardingRouteData({
    required this.region,
    required this.references,
    required this.answers,
  });

  final RegionDataPack region;
  final FoundationReferences references;
  final FootprintAnswers answers;
}

List<EmissionFactor> emissionFactorsFromRegionPack(RegionDataPack pack) => pack
    .emissionFactors
    .map(
      (factor) => EmissionFactor(
        factorId: factor.factorId,
        category: factor.category,
        activityId: factor.activityId,
        value: factor.value,
        numeratorUnit: factor.numeratorUnit,
        denominatorUnit: factor.denominatorUnit,
        source: FactorSource(
          sourceId: factor.source.sourceId,
          title: factor.source.title,
          publisher: factor.source.publisher,
          publicationYear: factor.sourceYear,
          url: factor.source.url,
        ),
        validFrom: factor.validFrom,
        methodology: factor.methodology,
      ),
    )
    .toList(growable: false);

const foundationEstimateDemoRegions = [
  EstimateDemoRegion(
    regionId: 'demo-region',
    labelKey: 'regionDemoOnly',
    period: '2026',
    accountingBoundary: 'annual consumption footprint per person',
    factors: [
      EmissionFactor(
        factorId: 'demo-electricity',
        category: 'electricity',
        activityId: 'electricity',
        value: 0.25,
        numeratorUnit: 'kg CO2e',
        denominatorUnit: 'kWh',
        source: FactorSource(
          sourceId: 'foundation-demo',
          title: 'Demonstration fixture only',
          publisher: 'Foundation synthetic test data',
          publicationYear: 2026,
        ),
        validFrom: '2026-01-01',
        methodology: 'Synthetic fixture value; not an environmental claim.',
      ),
      EmissionFactor(
        factorId: 'demo-transport',
        category: 'transport',
        activityId: 'transport',
        value: 0.1,
        numeratorUnit: 'kg CO2e',
        denominatorUnit: 'km',
        source: FactorSource(
          sourceId: 'foundation-demo',
          title: 'Demonstration fixture only',
          publisher: 'Foundation synthetic test data',
          publicationYear: 2026,
        ),
        validFrom: '2026-01-01',
        methodology: 'Synthetic fixture value; not an environmental claim.',
      ),
    ],
    source: ReferenceSource(
      sourceId: 'foundation-demo',
      title: 'Demonstration fixture only',
      publisher: 'Foundation synthetic test data',
      publicationYear: 2026,
    ),
    references: [
      ReferenceValue(
        referenceId: 'regional-average',
        value: 1800,
        unit: 'kg CO2e/year',
        period: '2026',
        sourceId: 'foundation-demo',
        methodology: 'Synthetic fixture value; not a regional claim.',
        accountingBoundary: 'annual consumption footprint per person',
      ),
      ReferenceValue(
        referenceId: 'global-average',
        value: 2500,
        unit: 'kg CO2e/year',
        period: '2026',
        sourceId: 'foundation-demo',
        methodology: 'Synthetic fixture value; not a global claim.',
        accountingBoundary: 'annual consumption footprint per person',
      ),
      ReferenceValue(
        referenceId: 'temperature-budget-1-5c',
        value: 900,
        unit: 'kg CO2e/year',
        period: '2026',
        sourceId: 'foundation-demo',
        methodology: 'Synthetic fixture value; not a climate target.',
        accountingBoundary: 'annual consumption footprint per person',
      ),
    ],
    demoOnly: true,
  ),
];
