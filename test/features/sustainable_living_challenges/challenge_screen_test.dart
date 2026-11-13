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
      expect(_progressCount(0), findsNothing);

      await tester.tap(find.text('Start challenge'));
      await _pumpUntilVisible(tester, _progressCount(0));
      expect(_progressCount(0), findsOneWidget);
      for (var day = 1; day <= 7; day++) {
        final dayLabel = find.text('Day $day');
        await tester.scrollUntilVisible(
          dayLabel,
          160,
          scrollable: _detailScrollable,
        );
        expect(dayLabel, findsOneWidget);
      }
      await tester.scrollUntilVisible(
        find.text('Day 1'),
        160,
        scrollable: find.byType(Scrollable).first,
      );

      await tester.tap(find.text('Day 1'));
      var progress = (await repository.readChallengeProgress(
        'plastic-free-week',
      ))!;
      expect(progress.completedDays, {1});
      await tester.pump();
      await _scrollDetailToTop(tester);
      await _pumpUntilVisible(tester, _progressCount(1));
      expect(_progressCount(1), findsOneWidget);
      var progressBar = tester.widget<LinearProgressIndicator>(
        _detailProgressBar,
      );
      expect(progressBar.value, 1 / 7);
      expect(progressBar.semanticsValue, (1 / 7).toString());
      expect(progressBar.semanticsLabel, '1 of 7 days completed');

      await tester.tap(find.text('Day 1'));
      progress = (await repository.readChallengeProgress('plastic-free-week'))!;
      expect(progress.completedDays, isEmpty);
      await tester.pump();
      await _scrollDetailToTop(tester);
      await _pumpUntilVisible(tester, _progressCount(0));
      expect(_progressCount(0), findsOneWidget);
      progressBar = tester.widget<LinearProgressIndicator>(_detailProgressBar);
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
      var now = DateTime(2026, 1, 1);
      final repository = ChallengeProgressRepository(
        database: database,
        clock: () => now,
      );
      await _openChallengeDetail(tester, catalog, repository, 'Meat-Free Week');
      await tester.tap(find.text('Start challenge'));
      await _pumpUntilVisible(tester, _progressCount(0));
      now = DateTime(2026, 1, 8);

      for (var day = 1; day <= 7; day++) {
        final dayLabel = find.text('Day $day');
        await _ensureDayVisible(tester, day);
        await tester.tap(dayLabel);
        final progress = (await repository.readChallengeProgress(
          'meat-free-week',
        ))!;
        expect(progress.completedDayCount, day);
        await tester.pump();
        await _scrollDetailToTop(tester);
        final count = _progressCount(day);
        await tester.ensureVisible(count);
        await tester.pump();
        expect(count, findsOneWidget);
      }

      expect(_progressCount(7), findsOneWidget);
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

  testWidgets('tapping Day 2 toggles only Day 2', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    try {
      var now = DateTime(2026, 1, 1);
      final repository = ChallengeProgressRepository(
        database: database,
        clock: () => now,
      );
      await repository.startChallenge('plastic-free-week');
      await repository.setDayCompleted(
        challengeId: 'plastic-free-week',
        totalDays: 7,
        dayNumber: 1,
        completed: true,
      );
      now = DateTime(2026, 1, 8);
      await repository.setDayCompleted(
        challengeId: 'plastic-free-week',
        totalDays: 7,
        dayNumber: 2,
        completed: true,
      );

      await _openChallengeDetail(
        tester,
        catalog,
        repository,
        'Plastic-Free Week',
      );

      await _ensureDayVisible(tester, 2);
      expect(_dayCheckbox(tester, 2).value, isTrue);
      expect(_dayCheckbox(tester, 2).onChanged, isNotNull);
      await tester.tap(find.text('Day 2'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(_dayCheckbox(tester, 2).value, isFalse);
      var progress = (await repository.readChallengeProgress(
        'plastic-free-week',
      ))!;
      expect(progress.completedDays, {1});
      expect(_dayCheckbox(tester, 1).value, isTrue);
      expect(_dayCheckbox(tester, 2).value, isFalse);
      await tester.pump();
      expect(progress.completedDays.contains(1), isTrue);
      expect(progress.completedDays.contains(2), isFalse);

      await _ensureDayVisible(tester, 2);
      await tester.tap(find.text('Day 2'));
      await tester.pump(const Duration(milliseconds: 100));
      progress = (await repository.readChallengeProgress('plastic-free-week'))!;
      expect(progress.completedDays, {1, 2});
      expect(_dayCheckbox(tester, 1).value, isTrue);
      expect(_dayCheckbox(tester, 2).value, isTrue);
      await tester.pump();
      expect(progress.completedDays, {1, 2});
      expect(progress.completedDays.contains(1), isTrue);
      expect(progress.completedDays.contains(2), isTrue);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
      await database.close();
    }
  });

  testWidgets('locked future day shows a note and cannot be checked', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    try {
      final repository = ChallengeProgressRepository(
        database: database,
        clock: () => DateTime(2026, 1, 1),
      );
      await _openChallengeDetail(
        tester,
        catalog,
        repository,
        'Plastic-Free Week',
      );
      await tester.tap(find.text('Start challenge'));
      expect(
        await repository.readChallengeProgress('plastic-free-week'),
        isNotNull,
      );
      await tester.pump();
      await _pumpUntilVisible(tester, _progressCount(0));

      final dayTwoRow = find.byKey(const ValueKey<int>(2));
      await tester.scrollUntilVisible(
        find.text('Day 2'),
        160,
        scrollable: _detailScrollable,
      );
      expect(
        find.descendant(
          of: dayTwoRow,
          matching: find.text('Not available yet.'),
        ),
        findsOneWidget,
      );
      final checkbox = tester.widget<CheckboxListTile>(
        find.descendant(of: dayTwoRow, matching: find.byType(CheckboxListTile)),
      );
      expect(checkbox.onChanged, isNull);

      await tester.tap(find.text('Day 2'));
      await tester.pump(const Duration(milliseconds: 200));
      final progress = (await repository.readChallengeProgress(
        'plastic-free-week',
      ))!;
      expect(progress.completedDays, isEmpty);
      await _scrollDetailToTop(tester);
      expect(_progressCount(0), findsOneWidget);
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

Finder _progressCount(int completed) => find.descendant(
  of: find.byKey(const ValueKey('challengeDetailList')),
  matching: find.byWidgetPredicate(
    (widget) =>
        widget is RichText &&
        widget.text.toPlainText() == '$completed / 7 days',
    skipOffstage: false,
  ),
);

CheckboxListTile _dayCheckbox(WidgetTester tester, int dayNumber) =>
    tester.widget<CheckboxListTile>(
      find.descendant(
        of: find.byKey(ValueKey<int>(dayNumber)),
        matching: find.byType(CheckboxListTile),
      ),
    );

Future<void> _scrollDetailToTop(WidgetTester tester) async {
  await tester.drag(
    find.byKey(const ValueKey('challengeDetailList')),
    const Offset(0, 1000),
  );
  await tester.pump();
}

Future<void> _ensureDayVisible(WidgetTester tester, int dayNumber) async {
  await tester.ensureVisible(find.text('Day $dayNumber'));
  await tester.pump();
}

final _detailScrollable = find.descendant(
  of: find.byKey(const ValueKey('challengeDetailList')),
  matching: find.byType(Scrollable),
);

final _detailProgressBar = find.descendant(
  of: find.byKey(const ValueKey('challengeDetailList')),
  matching: find.byType(LinearProgressIndicator),
);

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
