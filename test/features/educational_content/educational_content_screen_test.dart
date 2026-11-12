import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/features/educational_content/data/educational_article_catalog.dart';
import 'package:sustainable_living_app/features/educational_content/presentation/module_destination_screen.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

import '../../support/text_layout_expectations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late EducationalArticleCatalog catalog;

  setUpAll(() async {
    catalog = await EducationalArticleCatalog.loadBundled();
  });

  testWidgets('search matches body text and composes with topic filter', (
    tester,
  ) async {
    await _openArticles(tester, catalog);
    final search = find.byKey(const ValueKey('educationalArticleSearchField'));
    await tester.enterText(search, 'heated greenhouses');
    await tester.pump();

    final seasonalArticle = find.byKey(
      const ValueKey('educationalArticle-Seasonal Eating, Simply Explained'),
    );
    expect(seasonalArticle, findsOneWidget);
    expect(
      find.byKey(
        const ValueKey(
          'educationalArticle-Reading Your Electricity Use Like an Instrument',
        ),
      ),
      findsNothing,
    );

    final topicFilter = find.byKey(const ValueKey('educationalTopicFilter'));
    await tester.ensureVisible(topicFilter);
    await tester.tap(topicFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Food').last);
    await tester.pump();
    await tester.enterText(search, '');
    await tester.pump();

    expect(
      find.byKey(
        const ValueKey('educationalArticle-Seasonal Eating, Simply Explained'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('educationalArticle-Plant-Based, Most of the Time'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('educationalArticle-Composting Without the Smell'),
      ),
      findsNothing,
    );

    await tester.enterText(search, 'beans');
    await tester.pump();
    expect(
      find.byKey(
        const ValueKey('educationalArticle-Plant-Based, Most of the Time'),
      ),
      findsOneWidget,
    );
    expect(seasonalArticle, findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('sort selection orders visible rows by computed read time', (
    tester,
  ) async {
    final expandedCatalog = _catalogWithLongArticle(
      catalog,
      'Before You Buy: A Four-Question Check',
    );
    await _openArticles(tester, expandedCatalog);

    final titleSortedFirst = find.byKey(
      const ValueKey(
        'educationalArticle-Before You Buy: A Four-Question Check',
      ),
    );
    expect(titleSortedFirst, findsOneWidget);

    final sortField = find.byKey(const ValueKey('educationalArticleSort'));
    await tester.ensureVisible(sortField);
    await tester.tap(sortField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Shortest read').last);
    await tester.pump();

    final shortestFirst = find.byKey(
      const ValueKey('educationalArticle-Composting Without the Smell'),
    );
    final secondShortest = find.byKey(
      const ValueKey('educationalArticle-Plant-Based, Most of the Time'),
    );
    expect(shortestFirst, findsOneWidget);
    expect(secondShortest, findsOneWidget);
    expect(
      tester.getTopLeft(shortestFirst).dy,
      lessThan(tester.getTopLeft(secondShortest).dy),
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('article screen shows every paragraph and its takeaway', (
    tester,
  ) async {
    await _openArticles(tester, catalog);
    final article = catalog.articles.first;
    final row = find.byKey(ValueKey('educationalArticle-${article.title}'));
    final rowTapTarget = find.ancestor(of: row, matching: find.byType(InkWell));
    await tester.scrollUntilVisible(
      rowTapTarget,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(rowTapTarget);
    await tester.pump();
    await tester.tap(rowTapTarget);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('Article'), findsOneWidget);
    expect(find.text(article.title), findsOneWidget);
    expect(find.text(article.topic), findsOneWidget);
    expect(_richText('1 min read'), findsOneWidget);
    for (final paragraph in article.paragraphs) {
      await tester.scrollUntilVisible(
        _richText(paragraph),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      expect(_richText(paragraph), findsOneWidget);
    }
    await tester.scrollUntilVisible(
      find.text('Takeaway'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Takeaway'), findsOneWidget);
    expect(_richText(article.takeaway), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('impossible search shows the honest empty state', (tester) async {
    await _openArticles(tester, catalog);
    await tester.enterText(
      find.byKey(const ValueKey('educationalArticleSearchField')),
      'no such article phrase',
    );
    await tester.pump();

    expect(
      find.text('No articles match your search and topic.'),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('educationalArticle-Why Small Emissions Add Up'),
      ),
      findsNothing,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('list and article remain readable at 200 percent text', (
    tester,
  ) async {
    await _openArticles(tester, catalog, textScale: 2);
    expectNoTextOverlapOrClipping(tester, 'educational articles at 200% text');

    final article = catalog.articles.first;
    final row = find.byKey(ValueKey('educationalArticle-${article.title}'));
    final rowTapTarget = find.ancestor(of: row, matching: find.byType(InkWell));
    await tester.scrollUntilVisible(
      rowTapTarget,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(rowTapTarget);
    await tester.pump();
    await tester.tap(rowTapTarget);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expectNoTextOverlapOrClipping(
      tester,
      'educational article at 200% text',
      within: find.byKey(const ValueKey('educationalArticleDetail')),
    );

    final takeaway = find.text('Takeaway');
    await tester.scrollUntilVisible(
      takeaway,
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(takeaway, findsOneWidget);
    expectNoTextOverlapOrClipping(
      tester,
      'educational article takeaway at 200% text',
      within: find.byKey(const ValueKey('educationalArticleDetail')),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

EducationalArticleCatalog _catalogWithLongArticle(
  EducationalArticleCatalog source,
  String title,
) {
  final words = List<String>.filled(201, 'word');
  final body = [
    words.sublist(0, 67).join(' '),
    words.sublist(67, 134).join(' '),
    words.sublist(134).join(' '),
  ].join('\n\n');
  return EducationalArticleCatalog.parse({
    'schemaVersion': 1,
    'articles': [
      for (final article in source.articles)
        {
          'title': article.title,
          'topic': article.topic,
          'body': article.title == title ? body : article.body,
          'takeaway': article.takeaway,
        },
    ],
  });
}

Finder _richText(String value) => find.byWidgetPredicate(
  (widget) =>
      widget is Text &&
      (widget.data == value ||
          widget.textSpan?.toPlainText(includeSemanticsLabels: false) == value),
);

Future<void> _openArticles(
  WidgetTester tester,
  EducationalArticleCatalog catalog, {
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    _TestApp(
      textScale: textScale,
      child: EducationalContentScreen(catalog: catalog),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
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
