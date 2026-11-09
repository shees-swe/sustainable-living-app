import 'dart:convert';

import 'package:flutter/services.dart';

class FoundationReferences {
  const FoundationReferences({
    required this.schemaVersion,
    required this.referenceSetVersion,
    required this.sources,
    required this.globalAverage,
    required this.temperatureBudget,
  });

  final int schemaVersion;
  final String referenceSetVersion;
  final Map<String, FoundationReferenceSource> sources;
  final FoundationReferenceValue globalAverage;
  final FoundationTemperatureBudget temperatureBudget;

  static Future<FoundationReferences> loadBundled({AssetBundle? bundle}) async {
    final source = await (bundle ?? rootBundle).loadString(
      'assets/data/foundation-references.json',
    );
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Foundation references must be a JSON object.',
      );
    }
    return parse(decoded);
  }

  static FoundationReferences parse(Map<String, dynamic> source) {
    _requireKeys(source, {
      'schemaVersion',
      'referenceSetVersion',
      'sources',
      'globalAverage',
      'temperatureBudget',
    }, 'foundation references');
    if (source['schemaVersion'] != 1 ||
        source['referenceSetVersion'] is! String ||
        !_semver.hasMatch(source['referenceSetVersion'] as String)) {
      throw const FormatException('Foundation reference version is invalid.');
    }

    final sources = <String, FoundationReferenceSource>{};
    final rawSources = source['sources'];
    if (rawSources is! List || rawSources.isEmpty) {
      throw const FormatException('Foundation references require sources.');
    }
    for (final rawSource in rawSources) {
      if (rawSource is! Map<String, dynamic>) {
        throw const FormatException('Foundation reference source is invalid.');
      }
      _requireKeys(rawSource, {
        'sourceId',
        'title',
        'publisher',
        'publicationYear',
        'url',
        'reportVersion',
      }, 'reference source');
      final item = FoundationReferenceSource(
        sourceId: _requiredString(rawSource, 'sourceId', 'reference source'),
        title: _requiredString(rawSource, 'title', 'reference source'),
        publisher: _requiredString(rawSource, 'publisher', 'reference source'),
        publicationYear: _requiredInt(
          rawSource,
          'publicationYear',
          'reference source',
        ),
        url: _optionalString(rawSource, 'url', 'reference source'),
        reportVersion: _optionalString(
          rawSource,
          'reportVersion',
          'reference source',
        ),
      );
      final parsedUrl = item.url == null ? null : Uri.tryParse(item.url!);
      if (item.publicationYear < 1900 ||
          (parsedUrl != null && !parsedUrl.hasScheme) ||
          sources.containsKey(item.sourceId)) {
        throw FormatException(
          'Invalid or duplicate foundation source "${item.sourceId}".',
        );
      }
      sources[item.sourceId] = item;
    }

    final global = _object(source, 'globalAverage');
    _requireKeys(global, {
      'referenceId',
      'value',
      'unit',
      'period',
      'sourceId',
      'methodology',
      'accountingBoundary',
      'uncertainty',
    }, 'global average');
    if (global['referenceId'] != 'global-average') {
      throw const FormatException('Global average reference ID is invalid.');
    }
    final globalAverage = _referenceValue(global, sources, 'global average');

    final target = _object(source, 'temperatureBudget');
    _requireKeys(target, {
      'referenceId',
      'value',
      'unit',
      'period',
      'sourceId',
      'methodology',
      'accountingBoundary',
      'targetYear',
      'baselineYear',
      'allocationRule',
      'gases',
      'exclusions',
      'uncertainty',
    }, 'temperature budget');
    if (target['referenceId'] != 'temperature-budget-1-5c') {
      throw const FormatException(
        'Temperature target reference ID is invalid.',
      );
    }
    final gases = _stringArray(target, 'gases', 'temperature budget');
    final exclusions = _stringArray(target, 'exclusions', 'temperature budget');
    final temperatureBudget = FoundationTemperatureBudget(
      reference: _referenceValue(target, sources, 'temperature budget'),
      targetYear: _requiredInt(target, 'targetYear', 'temperature budget'),
      baselineYear: _requiredInt(target, 'baselineYear', 'temperature budget'),
      allocationRule: _requiredString(
        target,
        'allocationRule',
        'temperature budget',
      ),
      gases: gases,
      exclusions: exclusions,
    );
    if (temperatureBudget.targetYear < 1900 ||
        temperatureBudget.baselineYear < 1900) {
      throw const FormatException('Temperature target years are invalid.');
    }

    return FoundationReferences(
      schemaVersion: 1,
      referenceSetVersion: source['referenceSetVersion'] as String,
      sources: Map.unmodifiable(sources),
      globalAverage: globalAverage,
      temperatureBudget: temperatureBudget,
    );
  }
}

class FoundationReferenceSource {
  const FoundationReferenceSource({
    required this.sourceId,
    required this.title,
    required this.publisher,
    required this.publicationYear,
    this.url,
    this.reportVersion,
  });

  final String sourceId;
  final String title;
  final String publisher;
  final int publicationYear;
  final String? url;
  final String? reportVersion;
}

class FoundationReferenceValue {
  const FoundationReferenceValue({
    required this.referenceId,
    required this.value,
    required this.unit,
    required this.period,
    required this.sourceId,
    required this.methodology,
    required this.accountingBoundary,
    this.uncertainty,
  });

  final String referenceId;
  final double value;
  final String unit;
  final String period;
  final String sourceId;
  final String methodology;
  final String accountingBoundary;
  final String? uncertainty;
}

class FoundationTemperatureBudget {
  const FoundationTemperatureBudget({
    required this.reference,
    required this.targetYear,
    required this.baselineYear,
    required this.allocationRule,
    required this.gases,
    required this.exclusions,
  });

  final FoundationReferenceValue reference;
  final int targetYear;
  final int baselineYear;
  final String allocationRule;
  final List<String> gases;
  final List<String> exclusions;
}

FoundationReferenceValue _referenceValue(
  Map<String, dynamic> source,
  Map<String, FoundationReferenceSource> sources,
  String label,
) {
  final sourceId = _requiredString(source, 'sourceId', label);
  if (!sources.containsKey(sourceId)) {
    throw FormatException('$label references unknown source "$sourceId".');
  }
  final rawValue = source['value'];
  if (rawValue is! num || !rawValue.isFinite || rawValue < 0) {
    throw FormatException('$label value must be finite and nonnegative.');
  }
  return FoundationReferenceValue(
    referenceId: _requiredString(source, 'referenceId', label),
    value: rawValue.toDouble(),
    unit: _requiredString(source, 'unit', label),
    period: _requiredString(source, 'period', label),
    sourceId: sourceId,
    methodology: _requiredString(source, 'methodology', label),
    accountingBoundary: _requiredString(source, 'accountingBoundary', label),
    uncertainty: _optionalString(source, 'uncertainty', label),
  );
}

Map<String, dynamic> _object(Map<String, dynamic> source, String key) {
  final value = source[key];
  if (value is! Map<String, dynamic>) {
    throw FormatException('Foundation references.$key must be an object.');
  }
  return value;
}

String _requiredString(Map<String, dynamic> source, String key, String label) {
  final value = source[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$label.$key must be a non-empty string.');
  }
  return value;
}

String? _optionalString(Map<String, dynamic> source, String key, String label) {
  if (!source.containsKey(key) || source[key] == null) return null;
  return _requiredString(source, key, label);
}

int _requiredInt(Map<String, dynamic> source, String key, String label) {
  final value = source[key];
  if (value is! int) {
    throw FormatException('$label.$key must be an integer.');
  }
  return value;
}

List<String> _stringArray(
  Map<String, dynamic> source,
  String key,
  String label,
) {
  final value = source[key];
  if (value is! List ||
      value.any((item) => item is! String || item.trim().isEmpty)) {
    throw FormatException('$label.$key must contain non-empty strings.');
  }
  return value.cast<String>();
}

void _requireKeys(
  Map<String, dynamic> source,
  Set<String> allowed,
  String label,
) {
  for (final key in source.keys) {
    if (!allowed.contains(key)) {
      throw FormatException('$label contains unsupported field "$key".');
    }
  }
}

final _semver = RegExp(r'^[0-9]+\.[0-9]+\.[0-9]+$');
