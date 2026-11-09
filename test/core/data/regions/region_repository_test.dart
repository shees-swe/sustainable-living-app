import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/data/regions/region_pack_parser.dart';
import 'package:sustainable_living_app/core/data/regions/region_repository.dart';

void main() {
  const parser = RegionPackParser();

  test('accepts a source-attributed override with canonical metadata', () {
    final repository = RegionRepository(packs: [parser.parseMap(_pack())]);

    final factor = repository.requireRegion('PK').emissionFactors.single;
    expect(repository.factorCatalogVersion, '1.0.0');
    expect(factor.factorId, 'electricity-grid');
    expect(factor.value, 0.347);
    expect(factor.sourceId, factor.source.sourceId);
    expect(factor.sourceYear, factor.source.publicationYear);
  });

  test('rejects unknown factor IDs and catalog version mismatches', () {
    final unknownFactor = _pack();
    (unknownFactor['emissionFactors']! as List).single['factorId'] =
        'unregistered-factor';
    expect(
      () => RegionRepository(packs: [parser.parseMap(unknownFactor)]),
      throwsA(isA<FormatException>()),
    );

    final wrongCatalog = _pack()..['factorCatalogVersion'] = '2.0.0';
    expect(
      () => RegionRepository(packs: [parser.parseMap(wrongCatalog)]),
      throwsA(isA<FormatException>()),
    );
  });

  test(
    'rejects silent metadata redefinition across canonical factor identity',
    () {
      final redefinedFactor = _pack();
      (redefinedFactor['emissionFactors']! as List).single['denominatorUnit'] =
          'km';
      expect(
        () => RegionRepository(packs: [parser.parseMap(redefinedFactor)]),
        throwsA(isA<FormatException>()),
      );
    },
  );

  test('does not silently substitute when a requested region is missing', () {
    final repository = RegionRepository(packs: [parser.parseMap(_pack())]);

    expect(repository.regionById('XX'), isNull);
    expect(() => repository.requireRegion('XX'), throwsA(isA<UnknownRegion>()));
  });
}

Map<String, Object?> _pack() => {
  'schemaVersion': 1,
  'packId': 'pakistan',
  'packVersion': '1.0.0',
  'factorCatalogVersion': '1.0.0',
  'region': {
    'regionId': 'PK',
    'nameKey': 'regionPakistan',
    'currencyCode': 'PKR',
  },
  'contentAsOf': '2026-11-07',
  'sources': [
    {
      'sourceId': 'ember-yearly-electricity-2025',
      'title': 'Yearly Electricity Data',
      'publisher': 'Ember',
      'publicationYear': 2025,
      'attribution': 'Ember Yearly Electricity Data, 2025 release.',
    },
    {
      'sourceId': 'global-carbon-budget-2025',
      'title': 'Global Carbon Budget 2025',
      'publisher': 'Our World in Data / Global Carbon Project',
      'publicationYear': 2025,
      'attribution': 'Our World in Data / Global Carbon Budget 2025.',
    },
  ],
  'regionalAverage': {
    'value': 0.72,
    'unit': 't CO2/person',
    'period': '2024',
    'sourceId': 'global-carbon-budget-2025',
    'methodology': 'Cited regional average.',
    'accountingBoundary': 'Cited emissions per capita.',
  },
  'emissionFactors': [
    {
      'factorId': 'electricity-grid',
      'category': 'electricity',
      'activityId': 'electricity',
      'value': 0.347,
      'numeratorUnit': 'kg CO2',
      'denominatorUnit': 'kWh',
      'sourceId': 'ember-yearly-electricity-2025',
      'sourceYear': 2025,
      'validFrom': '2025-01-01',
      'methodology': 'Pakistan grid electricity factor.',
      'geographyId': 'PK',
    },
  ],
  'transportModes': <Map<String, Object?>>[],
  'recipes': <Map<String, Object?>>[],
};
