import 'dart:convert';

import 'package:flutter/services.dart';

class ProductCatalog {
  const ProductCatalog._(this.products);

  static const assetPath = 'assets/data/product-catalog.json';
  static const expectedProductCount = 24;
  static const categories = <String>[
    'Reusable alternatives',
    'Organic food options',
    'Energy-efficient appliances',
    'Zero-waste alternatives',
  ];

  final List<SuggestedProduct> products;

  static Future<ProductCatalog> loadBundled({AssetBundle? bundle}) async {
    final source = await (bundle ?? rootBundle).loadString(assetPath);
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('The product catalog must be a JSON object.');
    }
    return parse(decoded);
  }

  static ProductCatalog parse(Map<String, dynamic> source) {
    _requireKeys(source, {'schemaVersion', 'products'}, 'product catalog');
    if (source['schemaVersion'] != 1) {
      throw const FormatException('Unsupported product catalog version.');
    }
    final rawProducts = source['products'];
    if (rawProducts is! List || rawProducts.length != expectedProductCount) {
      throw const FormatException(
        'The product catalog must contain exactly 24 products.',
      );
    }

    final products = <SuggestedProduct>[];
    final names = <String>{};
    final counts = {for (final category in categories) category: 0};
    for (final rawProduct in rawProducts) {
      if (rawProduct is! Map<String, dynamic>) {
        throw const FormatException('A product catalog entry is invalid.');
      }
      _requireKeys(rawProduct, {'name', 'category', 'note'}, 'product');
      final name = _requiredString(rawProduct, 'name', 'product');
      final category = _requiredString(rawProduct, 'category', 'product');
      final note = _requiredString(rawProduct, 'note', 'product');
      if (!counts.containsKey(category) || !names.add(name)) {
        throw FormatException(
          'Product "$name" has an invalid category or name.',
        );
      }
      counts[category] = counts[category]! + 1;
      products.add(
        SuggestedProduct(name: name, category: category, note: note),
      );
    }
    if (counts.values.any((count) => count != 6)) {
      throw const FormatException(
        'Each product category must contain exactly six products.',
      );
    }
    return ProductCatalog._(List.unmodifiable(products));
  }

  List<SuggestedProduct> filter({
    String query = '',
    String? category,
    ProductSortOrder sort = ProductSortOrder.ascending,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    final filtered =
        products
            .where(
              (product) =>
                  (category == null || product.category == category) &&
                  (normalizedQuery.isEmpty ||
                      product.name.toLowerCase().contains(normalizedQuery) ||
                      product.note.toLowerCase().contains(normalizedQuery)),
            )
            .toList()
          ..sort((first, second) {
            final order = first.name.toLowerCase().compareTo(
              second.name.toLowerCase(),
            );
            return sort == ProductSortOrder.ascending ? order : -order;
          });
    return List.unmodifiable(filtered);
  }
}

class SuggestedProduct {
  const SuggestedProduct({
    required this.name,
    required this.category,
    required this.note,
  });

  final String name;
  final String category;
  final String note;
}

enum ProductSortOrder { ascending, descending }

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
