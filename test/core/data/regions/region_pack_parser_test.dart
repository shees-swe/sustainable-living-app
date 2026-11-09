import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/data/regions/region_pack_parser.dart';

void main() {
  const parser = RegionPackParser();

  test('parses a versioned pack and resolves cited factor provenance', () {
    final pack = parser.parseMap(_validPack());

    expect(pack.schemaVersion, 1);
    expect(pack.packVersion, '1.0.0');
    expect(pack.factorCatalogVersion, '1.0.0');
    expect(pack.region.regionId, 'PK');
    expect(pack.region.currencyCode, 'PKR');
    expect(pack.emissionFactors, hasLength(1));
    final factor = pack.emissionFactors.single;
    expect(factor.factorId, 'electricity-grid');
    expect(factor.value, 0.347);
    expect(factor.source.sourceId, 'ember-yearly-electricity-2025');
    expect(factor.source.publicationYear, 2025);
    expect(factor.validFrom, '2025-01-01');
    expect(pack.regionalAverage.value, 0.72);
    expect(pack.regionalAverage.period, '2024');
  });

  test(
    'rejects unsupported schema, malformed pack version, and incomplete fields',
    () {
      final invalidSchema = _validPack()..['schemaVersion'] = 2;
      expect(
        () => parser.parseMap(invalidSchema),
        throwsA(isA<RegionPackParseException>()),
      );

      final invalidVersion = _validPack()..['packVersion'] = 'latest';
      expect(
        () => parser.parseMap(invalidVersion),
        throwsA(isA<RegionPackParseException>()),
      );

      final incomplete = _validPack()..remove('contentAsOf');
      expect(
        () => parser.parseMap(incomplete),
        throwsA(isA<RegionPackParseException>()),
      );
    },
  );

  test('rejects missing factor provenance, incompatible units, and bad validity dates', () {
    final missingProvenance = _validPack();
    (missingProvenance['emissionFactors']! as List).single.remove('sourceYear');
    expect(
      () => parser.parseMap(missingProvenance),
      throwsA(isA<RegionPackParseException>()),
    );

    final incompatibleUnits = _validPack();
    (incompatibleUnits['emissionFactors']! as List).single['denominatorUnit'] =
        'mile';
    expect(
      () => parser.parseMap(incompatibleUnits),
      throwsA(isA<RegionPackParseException>()),
    );

    final invalidDate = _validPack();
    (invalidDate['emissionFactors']! as List).single['validFrom'] =
        '2024-13-40';
    expect(
      () => parser.parseMap(invalidDate),
      throwsA(isA<RegionPackParseException>()),
    );
  });

  test('rejects unresolved factor, transport, recipe, and average sources', () {
    final missingFactorSource = _validPack();
    (missingFactorSource['emissionFactors']! as List).single['sourceId'] =
        'not-in-sources';
    expect(
      () => parser.parseMap(missingFactorSource),
      throwsA(isA<RegionPackParseException>()),
    );

    final missingTransportFactor = _validPack();
    missingTransportFactor['transportModes'] = [
      {'modeId': 'car', 'labelKey': 'car', 'factorId': 'missing-factor'},
    ];
    expect(
      () => parser.parseMap(missingTransportFactor),
      throwsA(isA<RegionPackParseException>()),
    );

    final missingRecipeSource = _validPack();
    missingRecipeSource['recipes'] = [
      {
        'recipeId': 'meal',
        'nameKey': 'meal',
        'sourceIds': ['missing-source'],
      },
    ];
    expect(
      () => parser.parseMap(missingRecipeSource),
      throwsA(isA<RegionPackParseException>()),
    );

    final missingAverageSource = _validPack()
      ..['regionalAverage'] = {
        ..._validPack()['regionalAverage']! as Map<String, Object?>,
        'sourceId': 'missing-average-source',
      };
    expect(
      () => parser.parseMap(missingAverageSource),
      throwsA(isA<RegionPackParseException>()),
    );
  });

  test('parses JSON and permits unavailable transport and recipe data', () {
    final pack = parser.parseJson(jsonEncode(_validPack()));

    expect(pack.transportModes, isEmpty);
    expect(pack.recipes, isEmpty);
  });
}

Map<String, Object?> _validPack() => {
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
    'methodology': 'Consumption-based fossil CO2 emissions per capita.',
    'accountingBoundary':
        'Fossil CO2 emissions per person; not a household CO2e footprint.',
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
      'methodology': 'Pakistan grid emissions intensity, 2025 validity year.',
      'geographyId': 'PK',
    },
  ],
  'transportModes': <Map<String, Object?>>[],
  'recipes': <Map<String, Object?>>[],
};
