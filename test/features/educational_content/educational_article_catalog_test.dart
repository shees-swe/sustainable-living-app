import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/features/educational_content/data/educational_article_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late EducationalArticleCatalog catalog;

  setUpAll(() async {
    catalog = await EducationalArticleCatalog.loadBundled();
  });

  test('bundled catalog contains the exact ten article titles and topics', () {
    expect(catalog.articles.map((article) => article.title).toList(), [
      'Why Small Emissions Add Up',
      'What a Carbon Budget Means for One Person',
      'Reading Your Electricity Use Like an Instrument',
      'Reduce, Reuse, Recycle — In That Order',
      'Composting Without the Smell',
      'Where Home Water Really Goes',
      'Seasonal Eating, Simply Explained',
      'Plant-Based, Most of the Time',
      'Trips: The Mode Matters More Than the Miles',
      'Before You Buy: A Four-Question Check',
    ]);
    expect(catalog.articles.map((article) => article.topic).toList(), [
      'Climate Basics',
      'Climate Basics',
      'Home Energy',
      'Waste',
      'Waste',
      'Water',
      'Food',
      'Food',
      'Travel',
      'Shopping',
    ]);
    expect(catalog.articles, hasLength(10));
    expect(EducationalArticleCatalog.topics, [
      'Climate Basics',
      'Home Energy',
      'Waste',
      'Water',
      'Food',
      'Travel',
      'Shopping',
    ]);
  });

  test('search covers titles and body and composes with topic', () {
    expect(
      catalog
          .filter(query: 'heated greenhouses')
          .map((article) => article.title),
      ['Seasonal Eating, Simply Explained'],
    );
    expect(
      catalog.filter(query: 'carbon budget').map((article) => article.title),
      ['What a Carbon Budget Means for One Person'],
    );
    expect(catalog.filter(topic: 'Food').map((article) => article.title), [
      'Plant-Based, Most of the Time',
      'Seasonal Eating, Simply Explained',
    ]);
    expect(
      catalog
          .filter(query: 'beans', topic: 'Food')
          .map((article) => article.title),
      ['Plant-Based, Most of the Time'],
    );
    expect(catalog.filter(query: 'beans', topic: 'Waste'), isEmpty);
  });

  test('computes reading time and sorts by title or shortest read', () {
    expect(catalog.articles.first.readingTimeMinutes, 1);

    final words = List<String>.filled(201, 'word');
    final longBody = [
      words.sublist(0, 67).join(' '),
      words.sublist(67, 134).join(' '),
      words.sublist(134).join(' '),
    ].join('\n\n');
    final expandedCatalog = EducationalArticleCatalog.parse({
      'schemaVersion': 1,
      'articles': [
        for (final article in catalog.articles)
          {
            'title': article.title,
            'topic': article.topic,
            'body': article.title == 'Before You Buy: A Four-Question Check'
                ? longBody
                : article.body,
            'takeaway': article.takeaway,
          },
      ],
    });
    final longArticle = expandedCatalog.articles.singleWhere(
      (article) => article.title == 'Before You Buy: A Four-Question Check',
    );
    expect(longArticle.wordCount, 201);
    expect(longArticle.readingTimeMinutes, 2);

    expect(
      expandedCatalog
          .filter(sort: EducationalArticleSortOrder.title)
          .first
          .title,
      'Before You Buy: A Four-Question Check',
    );
    final shortestFirst = expandedCatalog.filter(
      sort: EducationalArticleSortOrder.shortestRead,
    );
    expect(shortestFirst.first.title, 'Composting Without the Smell');
    expect(shortestFirst.last.title, longArticle.title);
  });
}
