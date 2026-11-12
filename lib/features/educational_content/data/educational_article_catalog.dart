import 'dart:convert';

import 'package:flutter/services.dart';

class EducationalArticleCatalog {
  const EducationalArticleCatalog._(this.articles);

  static const assetPath = 'assets/data/educational-articles.json';
  static const expectedArticleCount = 10;
  static const topics = <String>[
    'Climate Basics',
    'Home Energy',
    'Waste',
    'Water',
    'Food',
    'Travel',
    'Shopping',
  ];

  final List<EducationalArticle> articles;

  static Future<EducationalArticleCatalog> loadBundled({
    AssetBundle? bundle,
  }) async {
    final source = await (bundle ?? rootBundle).loadString(assetPath);
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'The educational article catalog must be a JSON object.',
      );
    }
    return parse(decoded);
  }

  static EducationalArticleCatalog parse(Map<String, dynamic> source) {
    _requireKeys(source, {'schemaVersion', 'articles'}, 'article catalog');
    if (source['schemaVersion'] != 1) {
      throw const FormatException('Unsupported article catalog version.');
    }
    final rawArticles = source['articles'];
    if (rawArticles is! List || rawArticles.length != expectedArticleCount) {
      throw const FormatException(
        'The educational article catalog must contain exactly 10 articles.',
      );
    }

    final articles = <EducationalArticle>[];
    final titles = <String>{};
    for (final rawArticle in rawArticles) {
      if (rawArticle is! Map<String, dynamic>) {
        throw const FormatException('An educational article is invalid.');
      }
      _requireKeys(rawArticle, {
        'title',
        'topic',
        'body',
        'takeaway',
      }, 'educational article');
      final title = _requiredString(rawArticle, 'title', 'article');
      if (!titles.add(title)) {
        throw FormatException('Article "$title" is duplicated.');
      }
      final topic = _requiredString(rawArticle, 'topic', 'article');
      if (!topics.contains(topic)) {
        throw FormatException('Article "$title" has an unsupported topic.');
      }
      final body = _requiredString(rawArticle, 'body', 'article');
      if (body.split('\n\n').length != 3) {
        throw FormatException(
          'Article "$title" must contain exactly three paragraphs.',
        );
      }
      articles.add(
        EducationalArticle(
          title: title,
          topic: topic,
          body: body,
          takeaway: _requiredString(rawArticle, 'takeaway', 'article'),
        ),
      );
    }
    return EducationalArticleCatalog._(List.unmodifiable(articles));
  }

  List<EducationalArticle> filter({
    String query = '',
    String? topic,
    EducationalArticleSortOrder sort = EducationalArticleSortOrder.title,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    final filtered =
        articles
            .where(
              (article) =>
                  (topic == null || article.topic == topic) &&
                  (normalizedQuery.isEmpty ||
                      article.title.toLowerCase().contains(normalizedQuery) ||
                      article.body.toLowerCase().contains(normalizedQuery)),
            )
            .toList()
          ..sort((first, second) {
            if (sort == EducationalArticleSortOrder.shortestRead) {
              final readingTimeOrder = first.readingTimeMinutes.compareTo(
                second.readingTimeMinutes,
              );
              if (readingTimeOrder != 0) return readingTimeOrder;
            }
            return first.title.toLowerCase().compareTo(
              second.title.toLowerCase(),
            );
          });
    return List.unmodifiable(filtered);
  }
}

class EducationalArticle {
  const EducationalArticle({
    required this.title,
    required this.topic,
    required this.body,
    required this.takeaway,
  });

  static const wordsPerMinute = 200;

  final String title;
  final String topic;
  final String body;
  final String takeaway;

  int get wordCount => body.trim().split(RegExp(r'\s+')).length;

  int get readingTimeMinutes {
    final minutes = (wordCount / wordsPerMinute).ceil();
    return minutes < 1 ? 1 : minutes;
  }

  List<String> get paragraphs => List.unmodifiable(body.split('\n\n'));
}

enum EducationalArticleSortOrder { title, shortestRead }

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
