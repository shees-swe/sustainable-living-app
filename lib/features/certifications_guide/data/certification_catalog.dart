import 'dart:convert';

import 'package:flutter/services.dart';

class CertificationCatalog {
  const CertificationCatalog._({
    required this.certifications,
    required this.guidePoints,
  });

  static const assetPath = 'assets/data/certification-directory.json';
  static const expectedCertificationCount = 12;
  static const expectedGuidePointCount = 4;

  final List<Certification> certifications;
  final List<BrandCheckPoint> guidePoints;

  List<String> get categories => List.unmodifiable(
    certifications.map((certification) => certification.category).toSet(),
  );

  static Future<CertificationCatalog> loadBundled({AssetBundle? bundle}) async {
    final source = await (bundle ?? rootBundle).loadString(assetPath);
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'The certification directory must be a JSON object.',
      );
    }
    return parse(decoded);
  }

  static CertificationCatalog parse(Map<String, dynamic> source) {
    _requireKeys(source, {
      'schemaVersion',
      'certifications',
      'guide',
    }, 'certification directory');
    if (source['schemaVersion'] != 1) {
      throw const FormatException(
        'Unsupported certification directory version.',
      );
    }
    final rawCertifications = source['certifications'];
    if (rawCertifications is! List ||
        rawCertifications.length != expectedCertificationCount) {
      throw const FormatException(
        'The directory must contain exactly 12 certifications.',
      );
    }
    final rawGuide = source['guide'];
    if (rawGuide is! List || rawGuide.length != expectedGuidePointCount) {
      throw const FormatException(
        'The brand-check guide must contain exactly four points.',
      );
    }

    final certifications = <Certification>[];
    final names = <String>{};
    for (final rawCertification in rawCertifications) {
      if (rawCertification is! Map<String, dynamic>) {
        throw const FormatException('A certification entry is invalid.');
      }
      _requireKeys(rawCertification, {
        'name',
        'category',
        'meaning',
        'whereSeen',
      }, 'certification');
      final name = _requiredString(rawCertification, 'name', 'certification');
      if (!names.add(name)) {
        throw FormatException('Certification "$name" is duplicated.');
      }
      certifications.add(
        Certification(
          name: name,
          category: _requiredString(
            rawCertification,
            'category',
            'certification',
          ),
          meaning: _requiredString(
            rawCertification,
            'meaning',
            'certification',
          ),
          whereSeen: _requiredString(
            rawCertification,
            'whereSeen',
            'certification',
          ),
        ),
      );
    }

    final guidePoints = <BrandCheckPoint>[];
    final titles = <String>{};
    for (final rawPoint in rawGuide) {
      if (rawPoint is! Map<String, dynamic>) {
        throw const FormatException('A brand-check guide point is invalid.');
      }
      _requireKeys(rawPoint, {'title', 'text'}, 'brand-check guide point');
      final title = _requiredString(rawPoint, 'title', 'brand-check guide');
      if (!titles.add(title)) {
        throw FormatException('Guide point "$title" is duplicated.');
      }
      guidePoints.add(
        BrandCheckPoint(
          title: title,
          text: _requiredString(rawPoint, 'text', 'brand-check guide'),
        ),
      );
    }

    return CertificationCatalog._(
      certifications: List.unmodifiable(certifications),
      guidePoints: List.unmodifiable(guidePoints),
    );
  }

  List<Certification> filter({String query = '', String? category}) {
    final normalizedQuery = query.trim().toLowerCase();
    return List.unmodifiable(
      certifications.where(
        (certification) =>
            (category == null || certification.category == category) &&
            (normalizedQuery.isEmpty ||
                certification.name.toLowerCase().contains(normalizedQuery) ||
                certification.meaning.toLowerCase().contains(normalizedQuery)),
      ),
    );
  }
}

class Certification {
  const Certification({
    required this.name,
    required this.category,
    required this.meaning,
    required this.whereSeen,
  });

  final String name;
  final String category;
  final String meaning;
  final String whereSeen;
}

class BrandCheckPoint {
  const BrandCheckPoint({required this.title, required this.text});

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
