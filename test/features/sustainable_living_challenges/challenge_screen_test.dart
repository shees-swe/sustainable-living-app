import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/features/sustainable_living_challenges/data/challenge_catalog.dart';
import 'package:sustainable_living_app/features/sustainable_living_challenges/data/challenge_progress_repository.dart';
import 'package:sustainable_living_app/features/sustainable_living_challenges/presentation/module_destination_screen.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

import '../../support/text_layout_expectations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ChallengeCatalog catalog;

  setUpAll(() async {
    catalog = await ChallengeCatalog.loadBundled();
  });

  testWidgets('joining and toggling a day shows exact, reversible progress', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    try {
      final repository = ChallengeProgressRepository(database: database);
      await _openScreen(tester, catalog, repository);

      await tester.tap(find.text('Plastic-Free Week'));
      await _pumpUntilVisible(
        tester,
        find.text(
          'Refuse single-use plastic all week: carry your own bag, bottle, and containers, and say no to plastic cutlery and straws.',
        ),
      );
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump(const Duration(milliseconds: 1));
      expect(
        find.text(
          'Refuse single-use plastic all week: carry your own bag, bottle, and containers, and say no to plastic cutlery and straws.',
        ),
        findsOneWidget,
      );
      expect(find.text('Start challenge'), findsOneWidget);
      expect(find.text('0 / 7 days'), findsNothing);

      await tester.tap(find.text('Start challenge'));
      await _pumpUntilVisible(tester, find.text('0 / 7 days'));
      expect(find.text('0 / 7 days'), findsOneWidget);
      for (var day = 1; day <= 7; day++) {
        final dayLabel = find.text('Day $day');
        await tester.scrollUntilVisible(
          dayLabel,
          160,
          scrollable: find.byType(Scrollable).first,
        );
        expect(dayLabel, findsOneWidget);
      }
      await tester.scrollUntilVisible(
        find.text('Day 1'),
        160,
        scrollable: find.byType(Scrollable).first,
      );

      await tester.tap(find.text('Day 1'));
      await _pumpUntilVisible(tester, find.text('1 / 7 days'));
      expect(find.text('1 / 7 days'), findsOneWidget);
      var progressBar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator).last,
      );
      expect(progressBar.value, 1 / 7);
      expect(progressBar.semanticsValue, (1 / 7).toString());
      expect(progressBar.semanticsLabel, '1 of 7 days completed');

      await tester.tap(find.text('Day 1'));
      await _pumpUntilVisible(tester, find.text('0 / 7 days'));
      expect(find.text('0 / 7 days'), findsOneWidget);
      progressBar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator).last,
      );
      expect(progressBar.value, 0);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
      await database.close();
    }
  });

  testWidgets('completing every day displays the completed state', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    try {
      final repository = ChallengeProgressRepository(database: database);
      await _openChallengeDetail(tester, catalog, repository, 'Meat-Free Week');
      await tester.tap(find.text('Start challenge'));
      await _pumpUntilVisible(tester, find.text('0 / 7 days'));

      for (var day = 1; day <= 7; day++) {
        final dayLabel = find.text('Day $day');
        await tester.scrollUntilVisible(
          dayLabel,
          160,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(dayLabel);
        final count = find.text('$day / 7 days');
        await tester.scrollUntilVisible(
          count,
          160,
          scrollable: find.byType(Scrollable).first,
        );
        expect(count, findsOneWidget);
      }

      expect(find.text('7 / 7 days'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      final progressBar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator).last,
      );
      expect(progressBar.value, 1);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
      await database.close();
    }
  });

  testWidgets('challenge screens remain readable at 200 percent text size', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    try {
      final repository = ChallengeProgressRepository(database: database);
      await _openScreen(tester, catalog, repository, textScale: 2);
      expectNoTextOverlapOrClipping(tester, 'Challenge list');

      final challenge = find.text('Grow a Plant');
      await tester.scrollUntilVisible(
        challenge,
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(challenge);
      final description = catalog.challenges
          .singleWhere((item) => item.title == 'Grow a Plant')
          .description;
      await _pumpUntilVisible(tester, find.text(description));
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump(const Duration(milliseconds: 1));
      expectNoTextOverlapOrClipping(tester, 'Challenge detail');
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Start challenge'));
      await _pumpUntilVisible(tester, find.text('0 / 30 days'));
      final lastDay = find.text('Day 30');
      await tester.scrollUntilVisible(
        lastDay,
        180,
        scrollable: find.byType(Scrollable).first,
      );
      expect(lastDay, findsOneWidget);
      final dayBounds = tester.getRect(lastDay);
      final viewportBounds = tester.getRect(find.byType(ListView).last);
      expect(viewportBounds.contains(dayBounds.topLeft), isTrue);
      expect(viewportBounds.contains(dayBounds.bottomRight), isTrue);
      _expectVisibleListTextReadable(
        tester,
        'Last challenge day row',
        find.byType(ListView).last,
      );
      expect(tester.takeException(), isNull);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
      await database.close();
    }
  });
}

Future<void> _openChallengeDetail(
  WidgetTester tester,
  ChallengeCatalog catalog,
  ChallengeProgressRepository repository,
  String title,
) async {
  await _openScreen(tester, catalog, repository);
  await tester.scrollUntilVisible(
    find.text(title),
    160,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(find.text(title));
  final description = catalog.challenges
      .singleWhere((challenge) => challenge.title == title)
      .description;
  await _pumpUntilVisible(tester, find.text(description));
  await tester.pump(const Duration(milliseconds: 120));
  await tester.pump(const Duration(milliseconds: 1));
}

Future<void> _openScreen(
  WidgetTester tester,
  ChallengeCatalog catalog,
  ChallengeProgressRepository repository, {
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    _TestApp(
      textScale: textScale,
      child: SustainableLivingChallengesScreen(
        catalog: catalog,
        repository: repository,
      ),
    ),
  );
  await _pumpUntilVisible(tester, find.text('Plastic-Free Week'));
}

Future<void> _pumpUntilVisible(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 30; attempt++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
  fail('Widget did not appear: $finder');
}

void _expectVisibleListTextReadable(
  WidgetTester tester,
  String screen,
  Finder list,
) {
  final viewport = tester.getRect(list);
  final paragraphs = find
      .byWidgetPredicate((widget) => widget is Text || widget is SelectableText)
      .evaluate()
      .map((element) => element.findRenderObject())
      .whereType<RenderParagraph>()
      .where((paragraph) => paragraph.attached && paragraph.hasSize)
      .toList();
  final visibleParagraphs = <RenderParagraph>[];
  final visibleBounds = <Rect>[];
  for (final paragraph in paragraphs) {
    expect(
      paragraph.didExceedMaxLines,
      isFalse,
      reason: '$screen contains clipped text: ${paragraph.text.toPlainText()}',
    );
    final bounds = paragraph.localToGlobal(Offset.zero) & paragraph.size;
    final visible = bounds.intersect(viewport);
    if (visible.isEmpty) continue;
    visibleParagraphs.add(paragraph);
    visibleBounds.add(visible);
  }
  for (var index = 0; index < visibleParagraphs.length; index++) {
    for (var other = index + 1; other < visibleBounds.length; other++) {
      expect(
        visibleBounds[index].overlaps(visibleBounds[other]),
        isFalse,
        reason:
            '$screen has overlapping text: '
            '"${visibleParagraphs[index].text.toPlainText()}" and '
            '"${visibleParagraphs[other].text.toPlainText()}"',
      );
    }
  }
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
