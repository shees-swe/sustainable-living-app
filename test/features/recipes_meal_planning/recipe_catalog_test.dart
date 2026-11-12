import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/features/recipes_meal_planning/data/recipe_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RecipeCatalog catalog;

  setUpAll(() async {
    catalog = await RecipeCatalog.loadBundled();
  });

  test('bundled catalog contains exactly eight recipes', () {
    expect(catalog.recipes, hasLength(8));
    expect(catalog.seasons, ['All seasons', 'Summer', 'Winter']);
  });

  test('search matches names and ingredients', () {
    expect(catalog.filter(query: 'chickpea').map((recipe) => recipe.name), [
      'Chickpea Curry',
    ]);
    expect(catalog.filter(query: 'courgette').map((recipe) => recipe.name), [
      'Vegetable Stir-Fry with Rice',
    ]);
  });

  test('season and search filters combine', () {
    expect(catalog.filter(season: 'Summer').map((recipe) => recipe.name), [
      'Vegetable Stir-Fry with Rice',
      'Seasonal Fruit Bowl with Mint & Lime',
      'Tomato & Basil Pasta',
    ]);
    expect(catalog.filter(season: 'Winter').map((recipe) => recipe.name), [
      'Spinach & Potato Curry',
    ]);
    expect(
      catalog
          .filter(query: 'tomato', season: 'Summer')
          .map((recipe) => recipe.name),
      ['Tomato & Basil Pasta'],
    );
    expect(catalog.filter(season: 'All seasons'), hasLength(8));
  });
}
