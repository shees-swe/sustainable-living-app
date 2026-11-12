import 'dart:convert';

import 'package:flutter/services.dart';

class TravelGuideCatalog {
  const TravelGuideCatalog({required this.modes, required this.tips});

  static const assetPath = 'assets/data/travel-guide.json';
  static const expectedModeCount = 7;
  static const expectedTipCount = 6;

  final List<TravelModeGuidance> modes;
  final List<TravelTip> tips;

  static Future<TravelGuideCatalog> loadBundled({AssetBundle? bundle}) async {
    final source = await (bundle ?? rootBundle).loadString(assetPath);
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('The travel guide must be a JSON object.');
    }
    return parse(decoded);
  }

  static TravelGuideCatalog parse(Map<String, dynamic> source) {
    _requireKeys(source, {'schemaVersion', 'modes', 'tips'}, 'travel guide');
    if (source['schemaVersion'] != 1) {
      throw const FormatException('Unsupported travel guide version.');
    }

    final rawModes = source['modes'];
    if (rawModes is! List || rawModes.length != expectedModeCount) {
      throw const FormatException(
        'The travel guide must contain exactly seven transport modes.',
      );
    }
    final rawTips = source['tips'];
    if (rawTips is! List || rawTips.length != expectedTipCount) {
      throw const FormatException(
        'The travel guide must contain exactly six tips.',
      );
    }

    final modes = <TravelModeGuidance>[];
    final modeNames = <String>{};
    for (final rawMode in rawModes) {
      if (rawMode is! Map<String, dynamic>) {
        throw const FormatException('A travel mode entry is invalid.');
      }
      _requireKeys(rawMode, {'mode', 'guidance'}, 'transport mode');
      final mode = _requiredString(rawMode, 'mode', 'transport mode');
      if (!modeNames.add(mode)) {
        throw FormatException('Transport mode "$mode" is duplicated.');
      }
      modes.add(
        TravelModeGuidance(
          mode: mode,
          guidance: _requiredString(rawMode, 'guidance', 'transport mode'),
        ),
      );
    }

    final tips = <TravelTip>[];
    final titles = <String>{};
    for (final rawTip in rawTips) {
      if (rawTip is! Map<String, dynamic>) {
        throw const FormatException('A travel tip entry is invalid.');
      }
      _requireKeys(rawTip, {'title', 'text'}, 'travel tip');
      final title = _requiredString(rawTip, 'title', 'travel tip');
      if (!titles.add(title)) {
        throw FormatException('Travel tip "$title" is duplicated.');
      }
      tips.add(
        TravelTip(
          title: title,
          text: _requiredString(rawTip, 'text', 'travel tip'),
        ),
      );
    }

    return TravelGuideCatalog(
      modes: List.unmodifiable(modes),
      tips: List.unmodifiable(tips),
    );
  }
}

class TravelModeGuidance {
  const TravelModeGuidance({required this.mode, required this.guidance});

  final String mode;
  final String guidance;
}

class TravelTip {
  const TravelTip({required this.title, required this.text});

  final String title;
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
