import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/features/recipes_meal_planning/data/recipe_catalog.dart';
import 'package:sustainable_living_app/features/recipes_meal_planning/presentation/module_destination_screen.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

import '../../support/text_layout_expectations.dart';

void main() {
  late RecipeCatalog catalog;

  setUpAll(() async {
    catalog = await RecipeCatalog.loadBundled();
  });

  testWidgets('search narrows recipes by name and ingredient', (tester) async {
    await _openRecipes(tester, catalog);
    final search = find.byKey(const ValueKey('recipeSearchField'));

    await tester.enterText(search, 'Chickpea Curry');
    await tester.pump();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('recipe-Chickpea Curry')),
        matching: find.text('Chickpea Curry'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('recipe-Red Lentil & Vegetable Soup')),
      findsNothing,
    );

    await tester.enterText(search, 'courgette');
    await tester.pump();
    expect(
      find.byKey(const ValueKey('recipe-Vegetable Stir-Fry with Rice')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('recipe-Chickpea Curry')), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('season filter combines with recipe search', (tester) async {
    await _openRecipes(tester, catalog);

    await tester.tap(find.byKey(const ValueKey('recipeSeasonFilter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Summer').last);
    await tester.pumpAndSettle();
    expect(find.text('Vegetable Stir-Fry with Rice'), findsOneWidget);
    expect(find.text('Tomato & Basil Pasta'), findsOneWidget);
    expect(find.text('Chickpea Curry'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('recipeSearchField')),
      'tomato',
    );
    await tester.pump();
    expect(find.text('Tomato & Basil Pasta'), findsOneWidget);
    expect(find.text('Vegetable Stir-Fry with Rice'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('tapping a recipe shows its complete ingredients and steps', (
    tester,
  ) async {
    await _openRecipes(tester, catalog);
    final recipe = find.text('Red Lentil & Vegetable Soup');
    await tester.ensureVisible(recipe);
    await tester.tap(recipe);
    await tester.pumpAndSettle();

    expect(find.text('Recipe details'), findsOneWidget);
    expect(find.text('Red Lentil & Vegetable Soup'), findsOneWidget);
    expect(find.text('30 min'), findsOneWidget);
    expect(find.text('4 servings'), findsOneWidget);
    expect(
      find.text(
        'Red lentils need no soaking and cook fast, saving both energy and time.',
      ),
      findsOneWidget,
    );
    for (final ingredient in [
      '200 g red lentils, rinsed',
      '1 onion, chopped',
      '2 carrots, diced',
      '2 tomatoes, chopped',
      '2 garlic cloves, crushed',
      '1 tsp cumin',
      '1 litre water or vegetable stock',
      'salt to taste',
      'lemon wedges to serve',
    ]) {
      final ingredientFinder = find.textContaining(ingredient);
      await tester.scrollUntilVisible(
        ingredientFinder,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(ingredientFinder, findsOneWidget);
    }
    for (final step in [
      '1. Soften the onion and garlic in a little oil for 3 minutes.',
      '2. Add carrots, tomatoes, and cumin; cook 2 minutes.',
      '3. Add lentils and stock; simmer 20 minutes until soft.',
      '4. Season, blend part of the soup if you like it thicker, and serve with lemon.',
    ]) {
      final stepFinder = find.textContaining(step);
      await tester.scrollUntilVisible(
        stepFinder,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(stepFinder, findsOneWidget);
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('no-match state offers a clear action', (tester) async {
    await _openRecipes(tester, catalog);
    await tester.enterText(
      find.byKey(const ValueKey('recipeSearchField')),
      'not an ingredient',
    );
    await tester.pump();

    expect(
      find.text('No recipes match your search and season.'),
      findsOneWidget,
    );
    expect(find.text('Clear search and season'), findsOneWidget);
    expect(find.text('Red Lentil & Vegetable Soup'), findsNothing);

    await tester.tap(find.text('Clear search and season'));
    await tester.pump();
    expect(find.text('No recipes match your search and season.'), findsNothing);
    expect(find.text('Red Lentil & Vegetable Soup'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('recipe list and full detail fit at 200% text size', (
    tester,
  ) async {
    await _openRecipes(tester, catalog, textScale: 2);
    expectNoTextOverlapOrClipping(tester, 'Recipes at 200% text');

    final recipe = find.text('Red Lentil & Vegetable Soup');
    await tester.scrollUntilVisible(
      recipe,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(recipe);
    await tester.tap(recipe);
    await tester.pumpAndSettle();
    expectNoTextOverlapOrClipping(
      tester,
      'Recipe detail at 200% text',
      within: find.byKey(const ValueKey('recipeDetailList')),
    );

    final lastStep = find.text(
      '4. Season, blend part of the soup if you like it thicker, and serve with lemon.',
    );
    await tester.scrollUntilVisible(
      lastStep,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expectNoTextOverlapOrClipping(
      tester,
      'Recipe steps at 200% text',
      within: find.byKey(const ValueKey('recipeDetailList')),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Future<void> _openRecipes(
  WidgetTester tester,
  RecipeCatalog catalog, {
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    _TestApp(
      textScale: textScale,
      child: RecipesMealPlanningScreen(catalog: catalog),
    ),
  );
  await tester.pumpAndSettle();
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child, required this.textScale});

  final Widget child;
  final double textScale;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.light,
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: child,
    ),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
  );
}
