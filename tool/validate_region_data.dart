import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  const contractsPath = 'specs/001-app-foundation/contracts';
  const regionDirectory = 'assets/data/regions';
  final regionSchema = await _readJson(
    '$contractsPath/regional-data-pack.schema.json',
  );
  final referenceSchema = await _readJson(
    '$contractsPath/foundation-references.schema.json',
  );
  final index = await _readJson('$regionDirectory/index.json');
  final referenceData = await _readJson(
    'assets/data/foundation-references.json',
  );
  final errors = <String>[];

  final referencePath = 'assets/data/foundation-references.json';
  _validate(
    schema: referenceSchema,
    rootSchema: referenceSchema,
    value: referenceData,
    path: referencePath,
    errors: errors,
  );
  _validateReferenceSources(referenceData, referencePath, errors);

  final packPaths = (index['packFiles'] as List<dynamic>).cast<String>();
  final allPackPaths = [
    ...packPaths,
    'deliverables/test-data/regions/pakistan.json',
  ];
  for (final packPath in allPackPaths) {
    final pack = await _readJson(packPath);
    _validate(
      schema: regionSchema,
      rootSchema: regionSchema,
      value: pack,
      path: packPath,
      errors: errors,
    );
    _validatePackSources(pack, packPath, errors);
  }
  final deliveredReferencesPath =
      'deliverables/test-data/foundation-references.json';
  final deliveredReferences = await _readJson(deliveredReferencesPath);
  _validate(
    schema: referenceSchema,
    rootSchema: referenceSchema,
    value: deliveredReferences,
    path: deliveredReferencesPath,
    errors: errors,
  );
  _validateReferenceSources(
    deliveredReferences,
    deliveredReferencesPath,
    errors,
  );

  if (errors.isNotEmpty) {
    stderr.writeln(errors.join('\n'));
    exitCode = 1;
    return;
  }

  stdout.writeln(
    'Validated ${allPackPaths.length} regional fixture(s) and foundation '
    'reference set(s) against their JSON schemas and source references.',
  );
}

Future<Map<String, dynamic>> _readJson(String path) async {
  final decoded = jsonDecode(await File(path).readAsString());
  if (decoded is! Map<String, dynamic>) {
    throw FormatException('Expected a JSON object in $path.');
  }
  return decoded;
}

void _validate({
  required Map<String, dynamic> schema,
  required Map<String, dynamic> rootSchema,
  required Object? value,
  required String path,
  required List<String> errors,
}) {
  final reference = schema[r'$ref'];
  if (reference is String) {
    final referencedSchema = _resolveReference(rootSchema, reference);
    if (referencedSchema == null) {
      errors.add('$path: unresolved schema reference $reference');
    } else {
      _validate(
        schema: referencedSchema,
        rootSchema: rootSchema,
        value: value,
        path: path,
        errors: errors,
      );
    }
    return;
  }

  final type = schema['type'];
  if (type is String && !_matchesType(type, value)) {
    errors.add('$path: expected $type');
    return;
  }

  if (schema.containsKey('const') && schema['const'] != value) {
    errors.add('$path: expected constant ${schema['const']}');
  }
  final enumValues = schema['enum'];
  if (enumValues is List && !enumValues.contains(value)) {
    errors.add('$path: value is not in the allowed enum');
  }

  if (value is Map<String, dynamic>) {
    final properties = schema['properties'] is Map<String, dynamic>
        ? schema['properties'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final required = schema['required'];
    if (required is List) {
      for (final key in required.whereType<String>()) {
        if (!value.containsKey(key)) {
          errors.add('$path.$key: required field missing');
        }
      }
    }
    if (schema['additionalProperties'] == false) {
      for (final key in value.keys) {
        if (!properties.containsKey(key)) {
          errors.add('$path.$key: additional property is not allowed');
        }
      }
    }
    for (final entry in properties.entries) {
      final childSchema = entry.value;
      if (value.containsKey(entry.key) && childSchema is Map<String, dynamic>) {
        _validate(
          schema: childSchema,
          rootSchema: rootSchema,
          value: value[entry.key],
          path: '$path.${entry.key}',
          errors: errors,
        );
      }
    }
  }

  if (value is List) {
    final minItems = schema['minItems'];
    if (minItems is int && value.length < minItems) {
      errors.add('$path: expected at least $minItems item(s)');
    }
    final itemSchema = schema['items'];
    if (itemSchema is Map<String, dynamic>) {
      for (var index = 0; index < value.length; index++) {
        _validate(
          schema: itemSchema,
          rootSchema: rootSchema,
          value: value[index],
          path: '$path[$index]',
          errors: errors,
        );
      }
    }
  }

  if (value is String) {
    final minLength = schema['minLength'];
    if (minLength is int && value.runes.length < minLength) {
      errors.add('$path: expected at least $minLength character(s)');
    }
    final pattern = schema['pattern'];
    if (pattern is String && !RegExp(pattern).hasMatch(value)) {
      errors.add('$path: value does not match pattern $pattern');
    }
    final format = schema['format'];
    if (format == 'date' && !_isDate(value)) {
      errors.add('$path: expected an ISO date');
    }
    if (format == 'uri' && !_isUri(value)) {
      errors.add('$path: expected an absolute URI');
    }
  }

  if (value is num) {
    final minimum = schema['minimum'];
    if (minimum is num && value < minimum) {
      errors.add('$path: value must be at least $minimum');
    }
  }
}

Map<String, dynamic>? _resolveReference(
  Map<String, dynamic> rootSchema,
  String reference,
) {
  if (!reference.startsWith('#/')) return null;
  Object? value = rootSchema;
  for (final part in reference.substring(2).split('/')) {
    final key = part.replaceAll('~1', '/').replaceAll('~0', '~');
    if (value is! Map<String, dynamic> || !value.containsKey(key)) return null;
    value = value[key];
  }
  return value is Map<String, dynamic> ? value : null;
}

bool _matchesType(String type, Object? value) => switch (type) {
  'object' => value is Map<String, dynamic>,
  'array' => value is List,
  'string' => value is String,
  'number' => value is num,
  'integer' => value is int,
  'boolean' => value is bool,
  _ => false,
};

bool _isDate(String value) {
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) return false;
  final parsed = DateTime.tryParse(value);
  return parsed != null && parsed.toIso8601String().substring(0, 10) == value;
}

bool _isUri(String value) {
  final uri = Uri.tryParse(value);
  return uri != null && uri.hasScheme;
}

void _validateReferenceSources(
  Map<String, dynamic> references,
  String path,
  List<String> errors,
) {
  final sourceIds = _sourceIds(references);
  for (final key in ['globalAverage', 'temperatureBudget']) {
    final reference = references[key] as Map<String, dynamic>;
    if (!sourceIds.contains(reference['sourceId'])) {
      errors.add('$path.$key.sourceId: does not resolve to a source');
    }
  }
}

void _validatePackSources(
  Map<String, dynamic> pack,
  String path,
  List<String> errors,
) {
  final sourceIds = _sourceIds(pack);
  final factors = (pack['emissionFactors'] as List<dynamic>)
      .cast<Map<String, dynamic>>();
  final factorIds = factors.map((factor) => factor['factorId']).toSet();

  void requireSource(Object? sourceId, String sourcePath) {
    if (!sourceIds.contains(sourceId)) {
      errors.add('$sourcePath: does not resolve to a source');
    }
  }

  requireSource(
    (pack['regionalAverage'] as Map<String, dynamic>)['sourceId'],
    '$path.regionalAverage.sourceId',
  );
  for (var index = 0; index < factors.length; index++) {
    requireSource(
      factors[index]['sourceId'],
      '$path.emissionFactors[$index].sourceId',
    );
  }
  final transports = (pack['transportModes'] as List<dynamic>)
      .cast<Map<String, dynamic>>();
  for (var index = 0; index < transports.length; index++) {
    if (!factorIds.contains(transports[index]['factorId'])) {
      errors.add(
        '$path.transportModes[$index].factorId: does not resolve to a factor',
      );
    }
  }
  final recipes = (pack['recipes'] as List<dynamic>)
      .cast<Map<String, dynamic>>();
  for (var index = 0; index < recipes.length; index++) {
    final recipe = recipes[index];
    for (final sourceId in (recipe['sourceIds'] as List<dynamic>)) {
      requireSource(sourceId, '$path.recipes[$index].sourceIds');
    }
    final factorId = recipe['emissionFactorId'];
    if (factorId != null && !factorIds.contains(factorId)) {
      errors.add(
        '$path.recipes[$index].emissionFactorId: does not resolve to a factor',
      );
    }
  }
}

Set<Object?> _sourceIds(Map<String, dynamic> data) =>
    (data['sources'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map((source) => source['sourceId'])
        .toSet();
