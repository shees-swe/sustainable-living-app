import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/features/certifications_guide/data/certification_catalog.dart';
import 'package:sustainable_living_app/features/certifications_guide/presentation/module_destination_screen.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

import '../../support/text_layout_expectations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CertificationCatalog catalog;

  setUpAll(() async {
    catalog = await CertificationCatalog.loadBundled();
  });

  test('bundled directory contains the exact 12 certifications and guide', () {
    expect(catalog.certifications, hasLength(12));
    expect(
      catalog.certifications
          .map(
            (item) => [item.name, item.category, item.meaning, item.whereSeen],
          )
          .toList(),
      [
        [
          'Fairtrade',
          'Food & farming',
          'Farmers and workers receive fair prices and work under safer, fairer conditions.',
          'Coffee, tea, bananas, cocoa, cotton.',
        ],
        [
          'FSC (Forest Stewardship Council)',
          'Wood & paper',
          'Wood and paper come from responsibly managed forests.',
          'Furniture, paper, packaging, books.',
        ],
        [
          'GOTS (Global Organic Textile Standard)',
          'Textiles',
          'Textiles made from organic fibres, processed under environmental and social rules.',
          'Clothing, bedding, towels.',
        ],
        [
          'Energy Star',
          'Energy',
          'Appliances and electronics meet strict energy-efficiency requirements.',
          'Refrigerators, air conditioners, computers, lighting.',
        ],
        [
          'EU Energy Label',
          'Energy',
          'Appliances are rated A to G for energy efficiency, A being the most efficient.',
          'Washing machines, fridges, TVs sold in the EU.',
        ],
        [
          'USDA Organic',
          'Food & farming',
          'Food grown without most synthetic pesticides and fertilisers, under US organic rules.',
          'Packaged food, produce, dairy in the US.',
        ],
        [
          'EU Organic Leaf',
          'Food & farming',
          "Food produced under the European Union's organic farming rules.",
          'Food and drink sold in the EU.',
        ],
        [
          'Rainforest Alliance',
          'Food & farming',
          'Farms and forests are audited against sustainability standards for people and nature.',
          'Coffee, tea, cocoa, bananas.',
        ],
        [
          'Certified B Corporation',
          'Whole company',
          'The whole company meets verified standards of social and environmental performance.',
          'Company websites, packaging across many industries.',
        ],
        [
          'OEKO-TEX Standard 100',
          'Textiles',
          'The textile has been tested and found free of harmful levels of listed substances.',
          'Clothing, bedding, baby textiles.',
        ],
        [
          'MSC (Marine Stewardship Council)',
          'Seafood',
          'The seafood comes from a fishery certified as sustainably managed.',
          'Fish and seafood packaging.',
        ],
        [
          'Leaping Bunny',
          'Cosmetics & household',
          'The product and its ingredients were not tested on animals.',
          'Cosmetics, toiletries, cleaning products.',
        ],
      ],
    );
    expect(
      catalog.guidePoints.map((point) => [point.title, point.text]).toList(),
      [
        [
          'Look for third-party certification',
          'A label from an independent body (like the ones in this directory) means more than a logo the brand designed itself.',
        ],
        [
          'Specific claims beat vague words',
          '"Made with 70% recycled cotton" can be checked; "eco-friendly" and "natural" on their own cannot.',
        ],
        [
          'Judge the whole company, not one green product',
          'One recycled line does not make a brand sustainable if the rest of its range and policies are unchanged.',
        ],
        [
          'Look for published policies and reports',
          'Brands that measure their impact publish numbers and targets you can read; silence is also an answer.',
        ],
      ],
    );
    expect(catalog.categories, [
      'Food & farming',
      'Wood & paper',
      'Textiles',
      'Energy',
      'Whole company',
      'Seafood',
      'Cosmetics & household',
    ]);
  });

  test('search covers name and meaning and combines with category', () {
    expect(catalog.filter(query: 'fairtrade').map((item) => item.name), [
      'Fairtrade',
    ]);
    expect(
      catalog
          .filter(query: 'responsibly managed forests')
          .map((item) => item.name),
      ['FSC (Forest Stewardship Council)'],
    );
    expect(catalog.filter(category: 'Energy').map((item) => item.name), [
      'Energy Star',
      'EU Energy Label',
    ]);
    expect(
      catalog
          .filter(query: 'organic', category: 'Food & farming')
          .map((item) => item.name),
      ['USDA Organic', 'EU Organic Leaf'],
    );
  });

  testWidgets(
    'search filters by meaning and the category control filters rows',
    (tester) async {
      await _openDirectory(tester, catalog);

      await tester.enterText(
        find.byKey(const ValueKey('certificationSearchField')),
        'responsibly managed forests',
      );
      await tester.pump();
      expect(find.text('FSC (Forest Stewardship Council)'), findsOneWidget);
      expect(find.text('Fairtrade'), findsNothing);

      await tester.tap(find.byTooltip('Clear search'));
      await tester.pump();
      await tester.tap(
        find.byKey(const ValueKey('certificationCategoryFilter')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Energy').last);
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<DropdownButtonFormField<String>>(
              find.byKey(const ValueKey('certificationCategoryFilter')),
            )
            .initialValue,
        'Energy',
      );
      expect(find.text('Energy Star'), findsOneWidget);
      expect(find.text('EU Energy Label'), findsOneWidget);
      expect(find.text('Fairtrade'), findsNothing);
    },
  );

  testWidgets('tapping a certification shows its full detail', (tester) async {
    await _openDirectory(tester, catalog);
    final title = find.text('FSC (Forest Stewardship Council)');
    await tester.scrollUntilVisible(
      title,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(title);
    await tester.pumpAndSettle();

    expect(find.text('Certification details'), findsOneWidget);
    expect(find.text('Wood & paper'), findsOneWidget);
    expect(
      find.text('Wood and paper come from responsibly managed forests.'),
      findsOneWidget,
    );
    expect(find.text('Furniture, paper, packaging, books.'), findsOneWidget);
  });

  testWidgets('the guide shows all four exact points', (tester) async {
    await _openDirectory(tester, catalog);
    for (final point in catalog.guidePoints) {
      final title = find.text(point.title);
      await tester.scrollUntilVisible(
        title,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(title, findsOneWidget);
      final text = find.text(point.text);
      await tester.scrollUntilVisible(
        text,
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(text, findsOneWidget);
    }
  });

  testWidgets('no-match state offers to clear search and category', (
    tester,
  ) async {
    await _openDirectory(tester, catalog);
    await tester.enterText(
      find.byKey(const ValueKey('certificationSearchField')),
      'not-in-this-directory',
    );
    await tester.pump();

    expect(
      find.text('No certifications match your current search and category.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Clear search and category filter'));
    await tester.pump();
    expect(find.text('Fairtrade'), findsOneWidget);
  });

  testWidgets('directory and guide remain readable at 200% text', (
    tester,
  ) async {
    await _openDirectory(tester, catalog, textScale: 2);
    expectNoTextOverlapOrClipping(tester, 'certifications directory');

    final finalGuidePoint = catalog.guidePoints.last;
    await tester.scrollUntilVisible(
      find.text(finalGuidePoint.text),
      200,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('certificationDirectoryList')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.ensureVisible(find.text(finalGuidePoint.text));
    await tester.pumpAndSettle();
    expectNoTextOverlapOrClipping(
      tester,
      'certifications guide',
      within: find.byKey(const ValueKey('certificationDirectoryList')),
    );
    expect(tester.takeException(), isNull);
  });
}

Future<void> _openDirectory(
  WidgetTester tester,
  CertificationCatalog catalog, {
  double textScale = 1,
}) async {
  await tester.pumpWidget(_TestApp(catalog: catalog, textScale: textScale));
  await tester.pumpAndSettle();
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.catalog, required this.textScale});

  final CertificationCatalog catalog;
  final double textScale;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.light,
    home: CertificationsGuideScreen(catalog: catalog),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
  );
}
