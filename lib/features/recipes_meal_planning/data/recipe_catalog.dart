import 'dart:convert';

import 'package:flutter/services.dart';

class RecipeCatalog {
  const RecipeCatalog._(this.recipes);

  static const assetPath = 'assets/data/recipe-catalog.json';
  static const expectedRecipeCount = 8;
  static const allSeasons = 'All seasons';
  static const seasonTags = <String>[allSeasons, 'Summer', 'Winter'];

  final List<Recipe> recipes;

  List<String> get seasons => seasonTags;

  static Future<RecipeCatalog> loadBundled({AssetBundle? bundle}) async {
    final source = await (bundle ?? rootBundle).loadString(assetPath);
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('The recipe catalog must be a JSON object.');
    }
    return parse(decoded);
  }

  static RecipeCatalog parse(Map<String, dynamic> source) {
    _requireKeys(source, {'schemaVersion', 'recipes'}, 'recipe catalog');
    if (source['schemaVersion'] != 1) {
      throw const FormatException('Unsupported recipe catalog version.');
    }
    final rawRecipes = source['recipes'];
    if (rawRecipes is! List || rawRecipes.length != expectedRecipeCount) {
      throw const FormatException(
        'The recipe catalog must contain exactly eight recipes.',
      );
    }

    final recipes = <Recipe>[];
    final names = <String>{};
    for (final rawRecipe in rawRecipes) {
      if (rawRecipe is! Map<String, dynamic>) {
        throw const FormatException('A recipe catalog entry is invalid.');
      }
      _requireKeys(rawRecipe, {
        'name',
        'preparationTime',
        'servings',
        'season',
        'seasonalNote',
        'ingredients',
        'steps',
      }, 'recipe');
      final name = _requiredString(rawRecipe, 'name', 'recipe');
      if (!names.add(name)) {
        throw FormatException('Recipe "$name" is duplicated.');
      }
      final season = _requiredString(rawRecipe, 'season', 'recipe');
      if (!seasonTags.contains(season)) {
        throw FormatException('Recipe "$name" has an unsupported season.');
      }
      recipes.add(
        Recipe(
          name: name,
          preparationTime: _requiredString(
            rawRecipe,
            'preparationTime',
            'recipe',
          ),
          servings: _requiredString(rawRecipe, 'servings', 'recipe'),
          season: season,
          seasonalNote: _requiredString(rawRecipe, 'seasonalNote', 'recipe'),
          ingredients: _requiredStringList(rawRecipe, 'ingredients', 'recipe'),
          steps: _requiredStringList(rawRecipe, 'steps', 'recipe'),
        ),
      );
    }
    return RecipeCatalog._(List.unmodifiable(recipes));
  }

  List<Recipe> filter({String query = '', String season = allSeasons}) {
    final normalizedQuery = query.trim().toLowerCase();
    return List.unmodifiable(
      recipes.where(
        (recipe) =>
            (season == allSeasons || recipe.season == season) &&
            (normalizedQuery.isEmpty ||
                recipe.name.toLowerCase().contains(normalizedQuery) ||
                recipe.ingredients.any(
                  (ingredient) =>
                      ingredient.toLowerCase().contains(normalizedQuery),
                )),
      ),
    );
  }
}

class Recipe {
  const Recipe({
    required this.name,
    required this.preparationTime,
    required this.servings,
    required this.season,
    required this.seasonalNote,
    required this.ingredients,
    required this.steps,
  });

  final String name;
  final String preparationTime;
  final String servings;
  final String season;
  final String seasonalNote;
  final List<String> ingredients;
  final List<String> steps;
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

List<String> _requiredStringList(
  Map<String, dynamic> source,
  String key,
  String label,
) {
  final value = source[key];
  if (value is! List ||
      value.isEmpty ||
      value.any((item) => item is! String || item.trim().isEmpty)) {
    throw FormatException('$label.$key must be a non-empty string list.');
  }
  return List.unmodifiable(value.cast<String>());
}
