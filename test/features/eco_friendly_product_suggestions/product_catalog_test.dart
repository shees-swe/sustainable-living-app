import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/features/eco_friendly_product_suggestions/data/product_catalog.dart';
import 'package:sustainable_living_app/features/eco_friendly_product_suggestions/presentation/module_destination_screen.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

import '../../support/text_layout_expectations.dart';

void main() {
  late ProductCatalog catalog;

  setUpAll(() async {
    catalog = await ProductCatalog.loadBundled();
  });

  test('bundled catalog has exactly 24 products across four categories', () {
    expect(catalog.products, hasLength(24));
    expect(ProductCatalog.categories, hasLength(4));
    final counts = {
      for (final category in ProductCatalog.categories)
        category: catalog.products
            .where((product) => product.category == category)
            .length,
    };
    expect(counts.values, everyElement(6));
  });

  test('search, category, combined filters, and both sort orders work', () {
    expect(catalog.filter(query: ' bottle ').map((product) => product.name), [
      'Bar soap and shampoo bars',
      'Refillable cleaning spray bottles',
      'Stainless steel water bottle',
    ]);
    expect(
      catalog.filter(query: 'pollinators').map((product) => product.name),
      ['Raw local honey'],
    );
    final organic = catalog.filter(category: 'Organic food options');
    expect(organic, hasLength(6));
    expect(
      organic.every((product) => product.category == 'Organic food options'),
      isTrue,
    );
    expect(
      catalog
          .filter(query: 'local', category: 'Organic food options')
          .map((product) => product.name),
      ['Raw local honey', 'Seasonal local vegetables'],
    );

    final ascending = catalog.filter();
    final descending = catalog.filter(sort: ProductSortOrder.descending);
    expect(
      descending.map((product) => product.name),
      ascending.map((product) => product.name).toList().reversed,
    );
    expect(ascending.first.name, 'Bamboo toothbrush');
    expect(descending.first.name, 'Stainless steel water bottle');
  });

  testWidgets('category, search, and sort controls combine on the screen', (
    tester,
  ) async {
    await _openCatalog(tester, catalog);

    await tester.enterText(
      find.byKey(const ValueKey('productSearchField')),
      'local',
    );
    await tester.pumpAndSettle();
    expect(find.text('Raw local honey'), findsOneWidget);
    expect(find.text('Seasonal local vegetables'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('productCategoryFilter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Organic food options').last);
    await tester.pumpAndSettle();
    expect(find.text('Raw local honey'), findsOneWidget);
    expect(find.text('Seasonal local vegetables'), findsOneWidget);
    expect(find.text('Reusable alternatives'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('productSortFilter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Z–A'));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('Seasonal local vegetables')).dy,
      lessThan(tester.getTopLeft(find.text('Raw local honey')).dy),
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('tapping a product opens its full detail view', (tester) async {
    await _openCatalog(tester, catalog);
    final product = find.text('Bamboo toothbrush');
    await tester.scrollUntilVisible(
      product,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(product);
    await tester.pumpAndSettle();

    expect(find.text('Product details'), findsOneWidget);
    expect(find.text('Bamboo toothbrush'), findsOneWidget);
    expect(find.text('Reusable alternatives'), findsOneWidget);
    expect(
      find.text('Biodegradable handle instead of plastic.'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('no matches offers a clear action that restores products', (
    tester,
  ) async {
    await _openCatalog(tester, catalog);
    await tester.enterText(
      find.byKey(const ValueKey('productSearchField')),
      'no such product',
    );
    await tester.pumpAndSettle();

    expect(
      find.text('No products match your current search and category.'),
      findsOneWidget,
    );
    expect(find.text('Clear search and filters'), findsOneWidget);
    expect(find.text('Bamboo toothbrush'), findsNothing);

    await tester.tap(find.text('Clear search and filters'));
    await tester.pumpAndSettle();
    expect(
      find.text('No products match your current search and category.'),
      findsNothing,
    );
    expect(find.text('Bamboo toothbrush'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('catalog remains readable at 200 percent text size', (
    tester,
  ) async {
    await _openCatalog(tester, catalog, textScale: 2);

    expectNoTextOverlapOrClipping(tester, 'Product suggestions');
    expect(tester.takeException(), isNull);
    final lastProduct = find.text('Silicone stretch lids');
    await tester.scrollUntilVisible(
      lastProduct,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(lastProduct, findsOneWidget);
    expectNoTextOverlapOrClipping(
      tester,
      'Product suggestion row',
      within: find.ancestor(of: lastProduct, matching: find.byType(InkWell)),
    );
    await tester.tap(lastProduct);
    await tester.pumpAndSettle();
    expectNoTextOverlapOrClipping(tester, 'Product details');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Future<void> _openCatalog(
  WidgetTester tester,
  ProductCatalog catalog, {
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    _TestApp(
      textScale: textScale,
      child: EcoFriendlyProductSuggestionsScreen(catalog: catalog),
    ),
  );
  await tester.pumpAndSettle();
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child, this.textScale = 1});

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
