import 'dart:convert';

import 'package:flutter/services.dart';

class ChallengeCatalog {
  const ChallengeCatalog._(this.challenges);

  static const assetPath = 'assets/data/challenge-catalog.json';
  static const expectedChallengeCount = 10;

  final List<SustainableChallenge> challenges;

  static Future<ChallengeCatalog> loadBundled({AssetBundle? bundle}) async {
    final source = await (bundle ?? rootBundle).loadString(assetPath);
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'The challenge catalog must be a JSON object.',
      );
    }
    return parse(decoded);
  }

  static ChallengeCatalog parse(Map<String, dynamic> source) {
    _requireKeys(source, {'schemaVersion', 'challenges'}, 'challenge catalog');
    if (source['schemaVersion'] != 1) {
      throw const FormatException('Unsupported challenge catalog version.');
    }
    final rawChallenges = source['challenges'];
    if (rawChallenges is! List ||
        rawChallenges.length != expectedChallengeCount) {
      throw const FormatException(
        'The challenge catalog must contain exactly 10 challenges.',
      );
    }

    final challenges = <SustainableChallenge>[];
    final ids = <String>{};
    for (final rawChallenge in rawChallenges) {
      if (rawChallenge is! Map<String, dynamic>) {
        throw const FormatException('A challenge catalog entry is invalid.');
      }
      _requireKeys(rawChallenge, {
        'title',
        'theme',
        'days',
        'description',
      }, 'challenge');
      final title = _requiredString(rawChallenge, 'title', 'challenge');
      final theme = _requiredString(rawChallenge, 'theme', 'challenge');
      final description = _requiredString(
        rawChallenge,
        'description',
        'challenge',
      );
      final days = rawChallenge['days'];
      if (days is! int || days < 1) {
        throw const FormatException(
          'challenge.days must be a positive integer.',
        );
      }
      final id = challengeIdFor(title);
      if (!ids.add(id)) {
        throw FormatException('Challenge "$title" has a duplicate title.');
      }
      challenges.add(
        SustainableChallenge(
          id: id,
          title: title,
          theme: theme,
          days: days,
          description: description,
        ),
      );
    }
    return ChallengeCatalog._(List.unmodifiable(challenges));
  }

  static String challengeIdFor(String title) => title
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}

class SustainableChallenge {
  const SustainableChallenge({
    required this.id,
    required this.title,
    required this.theme,
    required this.days,
    required this.description,
  });

  final String id;
  final String title;
  final String theme;
  final int days;
  final String description;
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
