import 'dart:convert';

class RegionPackParser {
  const RegionPackParser();

  RegionDataPack parseJson(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const RegionPackParseException(
        'A regional pack must be a JSON object.',
      );
    }
    return parseMap(decoded);
  }

  RegionDataPack parseMap(Map<String, Object?> source) {
    _keys(source, const {
      'schemaVersion',
      'packId',
      'packVersion',
      'factorCatalogVersion',
      'region',
      'contentAsOf',
      'sources',
      'regionalAverage',
      'emissionFactors',
      'transportModes',
      'recipes',
    }, 'regional pack');
    if (_integer(source, 'schemaVersion', 'regional pack') != 1) {
      throw const RegionPackParseException(
        'Unsupported regional pack schema version.',
      );
    }
    final packId = _string(source, 'packId', 'regional pack');
    final packVersion = _string(source, 'packVersion', 'regional pack');
    final catalogVersion = _string(
      source,
      'factorCatalogVersion',
      'regional pack',
    );
    if (!_semver.hasMatch(packVersion) || !_semver.hasMatch(catalogVersion)) {
      throw const RegionPackParseException(
        'Pack and factor catalog versions must be semantic versions.',
      );
    }

    final regionJson = _object(source, 'region', 'regional pack');
    _keys(regionJson, const {'regionId', 'nameKey', 'currencyCode'}, 'region');
    final region = RegionPackMetadata(
      regionId: _string(regionJson, 'regionId', 'region'),
      nameKey: _string(regionJson, 'nameKey', 'region'),
      currencyCode: _string(regionJson, 'currencyCode', 'region'),
    );
    if (region.regionId.length < 2 ||
        !_currencyCode.hasMatch(region.currencyCode)) {
      throw const RegionPackParseException(
        'Region identity or ISO currency code is invalid.',
      );
    }

    final sources = <String, RegionPackSource>{};
    for (final item in _array(source, 'sources', 'regional pack')) {
      final itemMap = _asObject(item, 'source');
      _keys(itemMap, const {
        'sourceId',
        'title',
        'publisher',
        'publicationYear',
        'attribution',
        'url',
        'license',
      }, 'source');
      final sourceId = _string(itemMap, 'sourceId', 'source');
      final publicationYear = _integer(itemMap, 'publicationYear', 'source');
      final url = _optionalString(itemMap, 'url', 'source');
      if (publicationYear < 1900 ||
          (url != null && Uri.tryParse(url)?.hasAbsolutePath != true) ||
          (url != null && Uri.tryParse(url)?.hasScheme != true)) {
        throw RegionPackParseException(
          'Source "$sourceId" has invalid provenance.',
        );
      }
      if (sources.containsKey(sourceId)) {
        throw RegionPackParseException('Duplicate source ID "$sourceId".');
      }
      sources[sourceId] = RegionPackSource(
        sourceId: sourceId,
        title: _string(itemMap, 'title', 'source'),
        publisher: _string(itemMap, 'publisher', 'source'),
        publicationYear: publicationYear,
        attribution: _string(itemMap, 'attribution', 'source'),
        url: url,
        license: _optionalString(itemMap, 'license', 'source'),
      );
    }
    if (sources.isEmpty) {
      throw const RegionPackParseException(
        'A regional pack requires at least one source.',
      );
    }

    final averageJson = _object(source, 'regionalAverage', 'regional pack');
    _keys(averageJson, const {
      'value',
      'unit',
      'period',
      'sourceId',
      'methodology',
      'accountingBoundary',
      'uncertainty',
    }, 'regional average');
    final average = RegionPackReference(
      value: _number(averageJson, 'value', 'regional average'),
      unit: _string(averageJson, 'unit', 'regional average'),
      period: _string(averageJson, 'period', 'regional average'),
      sourceId: _string(averageJson, 'sourceId', 'regional average'),
      methodology: _string(averageJson, 'methodology', 'regional average'),
      accountingBoundary: _string(
        averageJson,
        'accountingBoundary',
        'regional average',
      ),
      uncertainty: _optionalString(
        averageJson,
        'uncertainty',
        'regional average',
      ),
    );
    _requireSource(sources, average.sourceId, 'regional average');

    final factors = <RegionPackFactor>[];
    final factorIds = <String>{};
    for (final item in _array(source, 'emissionFactors', 'regional pack')) {
      final itemMap = _asObject(item, 'factor');
      _keys(itemMap, const {
        'factorId',
        'category',
        'activityId',
        'value',
        'numeratorUnit',
        'denominatorUnit',
        'sourceId',
        'sourceYear',
        'validFrom',
        'validTo',
        'methodology',
        'geographyId',
      }, 'factor');
      final factorId = _string(itemMap, 'factorId', 'factor');
      final category = _string(itemMap, 'category', 'factor');
      final numeratorUnit = _string(itemMap, 'numeratorUnit', 'factor');
      final denominatorUnit = _string(itemMap, 'denominatorUnit', 'factor');
      final sourceId = _string(itemMap, 'sourceId', 'factor');
      final sourceYear = _integer(itemMap, 'sourceYear', 'factor');
      final validFrom = _string(itemMap, 'validFrom', 'factor');
      final validTo = _optionalString(itemMap, 'validTo', 'factor');
      if (!const {
            'electricity',
            'transport',
            'food',
            'waste',
            'other',
          }.contains(category) ||
          !const {'kg CO2', 'kg CO2e'}.contains(numeratorUnit) ||
          !const {'kWh', 'km'}.contains(denominatorUnit) ||
          sourceYear < 1900 ||
          !_validDate(validFrom) ||
          (validTo != null && !_validDate(validTo)) ||
          (validTo != null && validTo.compareTo(validFrom) < 0)) {
        throw RegionPackParseException(
          'Factor "$factorId" has invalid units or validity.',
        );
      }
      _requireSource(sources, sourceId, 'factor "$factorId"');
      if (sources[sourceId]!.publicationYear != sourceYear) {
        throw RegionPackParseException(
          'Factor "$factorId" source year does not match its cited source.',
        );
      }
      if (!factorIds.add(factorId)) {
        throw RegionPackParseException('Duplicate factor ID "$factorId".');
      }
      factors.add(
        RegionPackFactor(
          factorId: factorId,
          category: category,
          activityId: _string(itemMap, 'activityId', 'factor'),
          value: _number(itemMap, 'value', 'factor'),
          numeratorUnit: numeratorUnit,
          denominatorUnit: denominatorUnit,
          sourceId: sourceId,
          source: sources[sourceId]!,
          sourceYear: sourceYear,
          validFrom: validFrom,
          validTo: validTo,
          methodology: _string(itemMap, 'methodology', 'factor'),
          geographyId: _optionalString(itemMap, 'geographyId', 'factor'),
        ),
      );
    }
    if (factors.isEmpty) {
      throw const RegionPackParseException(
        'A regional pack requires at least one factor.',
      );
    }

    final transportModes = <RegionPackTransportMode>[];
    for (final item in _array(source, 'transportModes', 'regional pack')) {
      final itemMap = _asObject(item, 'transport mode');
      _keys(itemMap, const {
        'modeId',
        'labelKey',
        'factorId',
      }, 'transport mode');
      final factorId = _string(itemMap, 'factorId', 'transport mode');
      if (!factorIds.contains(factorId)) {
        throw RegionPackParseException(
          'Transport mode references unknown factor "$factorId".',
        );
      }
      transportModes.add(
        RegionPackTransportMode(
          modeId: _string(itemMap, 'modeId', 'transport mode'),
          labelKey: _string(itemMap, 'labelKey', 'transport mode'),
          factorId: factorId,
        ),
      );
    }

    final recipes = <RegionPackRecipe>[];
    for (final item in _array(source, 'recipes', 'regional pack')) {
      final itemMap = _asObject(item, 'recipe');
      _keys(itemMap, const {
        'recipeId',
        'nameKey',
        'sourceIds',
        'emissionFactorId',
      }, 'recipe');
      final sourceIds = _stringArray(itemMap, 'sourceIds', 'recipe');
      if (sourceIds.isEmpty) {
        throw const RegionPackParseException(
          'A recipe requires at least one source.',
        );
      }
      for (final sourceId in sourceIds) {
        _requireSource(sources, sourceId, 'recipe');
      }
      final emissionFactorId = _optionalString(
        itemMap,
        'emissionFactorId',
        'recipe',
      );
      if (emissionFactorId != null && !factorIds.contains(emissionFactorId)) {
        throw RegionPackParseException(
          'Recipe references unknown factor "$emissionFactorId".',
        );
      }
      recipes.add(
        RegionPackRecipe(
          recipeId: _string(itemMap, 'recipeId', 'recipe'),
          nameKey: _string(itemMap, 'nameKey', 'recipe'),
          sourceIds: sourceIds,
          emissionFactorId: emissionFactorId,
        ),
      );
    }

    final contentAsOf = _string(source, 'contentAsOf', 'regional pack');
    if (!_validDate(contentAsOf)) {
      throw const RegionPackParseException(
        'Pack contentAsOf must be an ISO date.',
      );
    }

    return RegionDataPack(
      schemaVersion: 1,
      packId: packId,
      packVersion: packVersion,
      factorCatalogVersion: catalogVersion,
      region: region,
      contentAsOf: contentAsOf,
      sources: Map.unmodifiable(sources),
      regionalAverage: average,
      emissionFactors: List.unmodifiable(factors),
      transportModes: List.unmodifiable(transportModes),
      recipes: List.unmodifiable(recipes),
    );
  }
}

class RegionDataPack {
  const RegionDataPack({
    required this.schemaVersion,
    required this.packId,
    required this.packVersion,
    required this.factorCatalogVersion,
    required this.region,
    required this.contentAsOf,
    required this.sources,
    required this.regionalAverage,
    required this.emissionFactors,
    required this.transportModes,
    required this.recipes,
  });

  final int schemaVersion;
  final String packId;
  final String packVersion;
  final String factorCatalogVersion;
  final RegionPackMetadata region;
  final String contentAsOf;
  final Map<String, RegionPackSource> sources;
  final RegionPackReference regionalAverage;
  final List<RegionPackFactor> emissionFactors;
  final List<RegionPackTransportMode> transportModes;
  final List<RegionPackRecipe> recipes;
}

class RegionPackMetadata {
  const RegionPackMetadata({
    required this.regionId,
    required this.nameKey,
    required this.currencyCode,
  });

  final String regionId;
  final String nameKey;
  final String currencyCode;
}

class RegionPackSource {
  const RegionPackSource({
    required this.sourceId,
    required this.title,
    required this.publisher,
    required this.publicationYear,
    required this.attribution,
    this.url,
    this.license,
  });

  final String sourceId;
  final String title;
  final String publisher;
  final int publicationYear;
  final String attribution;
  final String? url;
  final String? license;
}

class RegionPackReference {
  const RegionPackReference({
    required this.value,
    required this.unit,
    required this.period,
    required this.sourceId,
    required this.methodology,
    required this.accountingBoundary,
    this.uncertainty,
  });

  final double value;
  final String unit;
  final String period;
  final String sourceId;
  final String methodology;
  final String accountingBoundary;
  final String? uncertainty;
}

class RegionPackFactor {
  const RegionPackFactor({
    required this.factorId,
    required this.category,
    required this.activityId,
    required this.value,
    required this.numeratorUnit,
    required this.denominatorUnit,
    required this.sourceId,
    required this.source,
    required this.sourceYear,
    required this.validFrom,
    required this.methodology,
    this.validTo,
    this.geographyId,
  });

  final String factorId;
  final String category;
  final String activityId;
  final double value;
  final String numeratorUnit;
  final String denominatorUnit;
  final String sourceId;
  final RegionPackSource source;
  final int sourceYear;
  final String validFrom;
  final String? validTo;
  final String methodology;
  final String? geographyId;
}

class RegionPackTransportMode {
  const RegionPackTransportMode({
    required this.modeId,
    required this.labelKey,
    required this.factorId,
  });

  final String modeId;
  final String labelKey;
  final String factorId;
}

class RegionPackRecipe {
  const RegionPackRecipe({
    required this.recipeId,
    required this.nameKey,
    required this.sourceIds,
    this.emissionFactorId,
  });

  final String recipeId;
  final String nameKey;
  final List<String> sourceIds;
  final String? emissionFactorId;
}

class RegionPackParseException implements Exception {
  const RegionPackParseException(this.message);

  final String message;

  @override
  String toString() => 'RegionPackParseException: $message';
}

final _semver = RegExp(r'^[0-9]+\.[0-9]+\.[0-9]+$');
final _currencyCode = RegExp(r'^[A-Z]{3}$');

void _keys(Map<String, Object?> object, Set<String> allowed, String label) {
  for (final key in object.keys) {
    if (!allowed.contains(key)) {
      throw RegionPackParseException(
        '$label contains unsupported field "$key".',
      );
    }
  }
}

Map<String, Object?> _object(
  Map<String, Object?> parent,
  String key,
  String label,
) {
  final value = parent[key];
  if (value is! Map<String, Object?>) {
    throw RegionPackParseException('$label.$key must be an object.');
  }
  return value;
}

Map<String, Object?> _asObject(Object? value, String label) {
  if (value is! Map<String, Object?>) {
    throw RegionPackParseException('$label must be an object.');
  }
  return value;
}

List<Object?> _array(Map<String, Object?> parent, String key, String label) {
  final value = parent[key];
  if (value is! List<Object?>) {
    throw RegionPackParseException('$label.$key must be an array.');
  }
  return value;
}

String _string(Map<String, Object?> object, String key, String label) {
  final value = object[key];
  if (value is! String || value.trim().isEmpty) {
    throw RegionPackParseException('$label.$key must be a non-empty string.');
  }
  return value;
}

String? _optionalString(Map<String, Object?> object, String key, String label) {
  if (!object.containsKey(key) || object[key] == null) return null;
  return _string(object, key, label);
}

int _integer(Map<String, Object?> object, String key, String label) {
  final value = object[key];
  if (value is! int) {
    throw RegionPackParseException('$label.$key must be an integer.');
  }
  return value;
}

double _number(Map<String, Object?> object, String key, String label) {
  final value = object[key];
  if (value is! num || !value.isFinite || value < 0) {
    throw RegionPackParseException(
      '$label.$key must be finite and nonnegative.',
    );
  }
  return value.toDouble();
}

List<String> _stringArray(
  Map<String, Object?> object,
  String key,
  String label,
) {
  final values = _array(object, key, label);
  if (values.any((value) => value is! String || value.trim().isEmpty)) {
    throw RegionPackParseException(
      '$label.$key must contain non-empty strings.',
    );
  }
  return values.cast<String>();
}

void _requireSource(
  Map<String, RegionPackSource> sources,
  String sourceId,
  String label,
) {
  if (!sources.containsKey(sourceId)) {
    throw RegionPackParseException(
      '$label references unknown source "$sourceId".',
    );
  }
}

bool _validDate(String value) {
  final date = DateTime.tryParse(value);
  return date != null &&
      date.toIso8601String().startsWith(value) &&
      RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value);
}
