import 'dart:convert';

import 'package:flutter/services.dart';

class EnergyTipCatalog {
  const EnergyTipCatalog._(this.tips);

  static const assetPath = 'assets/data/energy-conservation-tips.json';
  static const expectedTipCount = 11;
  static const categoryNames = <String>[
    'Heating & cooling',
    'Lighting',
    'Appliances',
    'Water',
    'Renewables',
  ];

  final List<EnergyTip> tips;

  List<String> get categories =>
      List.unmodifiable(tips.map((tip) => tip.category).toSet());

  static Future<EnergyTipCatalog> loadBundled({AssetBundle? bundle}) async {
    final source = await (bundle ?? rootBundle).loadString(assetPath);
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'The energy tip catalog must be a JSON object.',
      );
    }
    return parse(decoded);
  }

  static EnergyTipCatalog parse(Map<String, dynamic> source) {
    _requireKeys(source, {'schemaVersion', 'tips'}, 'energy tip catalog');
    if (source['schemaVersion'] != 1) {
      throw const FormatException('Unsupported energy tip catalog version.');
    }
    final rawTips = source['tips'];
    if (rawTips is! List || rawTips.length != expectedTipCount) {
      throw const FormatException(
        'The energy tip catalog must contain exactly 11 tips.',
      );
    }

    final tips = <EnergyTip>[];
    final titles = <String>{};
    for (final rawTip in rawTips) {
      if (rawTip is! Map<String, dynamic>) {
        throw const FormatException('An energy tip entry is invalid.');
      }
      _requireKeys(rawTip, {'title', 'category', 'text'}, 'energy tip');
      final title = _requiredString(rawTip, 'title', 'energy tip');
      if (!titles.add(title)) {
        throw FormatException('Energy tip "$title" is duplicated.');
      }
      final category = _requiredString(rawTip, 'category', 'energy tip');
      if (!categoryNames.contains(category)) {
        throw FormatException(
          'Energy tip "$title" has an unsupported category.',
        );
      }
      tips.add(
        EnergyTip(
          title: title,
          category: category,
          text: _requiredString(rawTip, 'text', 'energy tip'),
        ),
      );
    }

    return EnergyTipCatalog._(List.unmodifiable(tips));
  }

  List<EnergyTip> filter({String query = '', String? category}) {
    final normalizedQuery = query.trim().toLowerCase();
    return List.unmodifiable(
      tips.where(
        (tip) =>
            (category == null || tip.category == category) &&
            (normalizedQuery.isEmpty ||
                tip.title.toLowerCase().contains(normalizedQuery) ||
                tip.text.toLowerCase().contains(normalizedQuery)),
      ),
    );
  }
}

class EnergyTip {
  const EnergyTip({
    required this.title,
    required this.category,
    required this.text,
  });

  final String title;
  final String category;
  final String text;
}

void _requireKeys(
  Map<String, dynamic> source,
  Set<String> allowed,
  String label,
) {
  if (source.keys.toSet().difference(allowed).isNotEmpty) {
    throw FormatException('$label contains unsupported fields.');
  }
}

String _requiredString(Map<String, dynamic> source, String key, String label) {
  final value = source[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$label.$key must be a non-empty string.');
  }
  return value;
}
