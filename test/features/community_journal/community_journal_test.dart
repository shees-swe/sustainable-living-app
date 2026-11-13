import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/features/community_journal/data/community_post_repository.dart';
import 'package:sustainable_living_app/features/community_journal/presentation/module_destination_screen.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

import '../../support/text_layout_expectations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('empty state, local-only note, and all guidelines render', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = CommunityPostRepository(database: database);
    await _openJournal(tester, repository);

    expect(
      find.text(
        'Your posts are stored only on this device. Nothing is uploaded or shared.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'No posts yet. Add your first post to start your personal record.',
      ),
      findsOneWidget,
    );

    final guidelines = [
      (
        'Share what you tried',
        'Posts about your own efforts, challenges, and results help you see your own progress over time.',
      ),
      (
        'Be specific',
        'What you changed, for how long, and what happened — specific posts are the ones worth re-reading.',
      ),
      (
        'Be honest about results',
        'A challenge that did not work is as useful a record as one that did.',
      ),
      (
        'Your journal, your device',
        'In this version the forum is a personal, on-device feed. A shared community would arrive in a later version.',
      ),
    ];
    final scrollable = find.byType(Scrollable).first;
    for (final (title, text) in guidelines) {
      final titleFinder = find.text(title);
      await tester.scrollUntilVisible(titleFinder, 200, scrollable: scrollable);
      expect(titleFinder, findsOneWidget);
      final textFinder = find.text(text);
      await tester.scrollUntilVisible(textFinder, 120, scrollable: scrollable);
      expect(textFinder, findsOneWidget);
    }

    expect(await repository.readPosts(), isEmpty);
    await _closeJournal(tester, database);
  });

  testWidgets('creates, edits, and immediately deletes newest-first posts', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    var currentTime = DateTime.utc(2026, 11, 12);
    final repository = CommunityPostRepository(
      database: database,
      clock: () => currentTime,
    );
    await _openJournal(tester, repository);

    await _createPost(
      tester,
      title: 'First effort',
      body: 'I repaired a lamp instead of replacing it.',
    );
    final olderPost = (await repository.readPosts()).single;
    final olderRow = find.byKey(ValueKey('communityPost-${olderPost.postId}'));
    expect(
      find.descendant(of: olderRow, matching: find.text('First effort')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: olderRow,
        matching: find.text('I repaired a lamp instead of replacing it.'),
      ),
      findsOneWidget,
    );

    currentTime = currentTime.add(const Duration(minutes: 1));
    await _createPost(
      tester,
      title: 'Latest effort',
      body: 'I brought a reusable cup.',
    );
    var posts = await repository.readPosts();
    expect(posts.map((post) => post.title), ['Latest effort', 'First effort']);
    final latestPost = posts.first;
    final latestRow = find.byKey(
      ValueKey('communityPost-${latestPost.postId}'),
    );
    await tester.ensureVisible(latestRow);
    await tester.ensureVisible(olderRow);
    expect(
      tester.getTopLeft(latestRow).dy,
      lessThan(tester.getTopLeft(olderRow).dy),
    );

    await tester.ensureVisible(olderRow);
    await tester.tap(
      find.descendant(of: olderRow, matching: find.byTooltip('Edit post')),
    );
    await _pumpUntilVisible(tester, find.text('Update post'));
    final titleField = find.byKey(const ValueKey('communityPostTitleField'));
    final bodyField = find.byKey(const ValueKey('communityPostBodyField'));
    await tester.ensureVisible(titleField);
    await tester.enterText(titleField, 'Updated effort');
    await tester.ensureVisible(bodyField);
    await tester.enterText(bodyField, 'I repaired two household items.');
    await tester.tap(find.byKey(const ValueKey('communitySavePostButton')));
    await tester.pump();
    await _pumpUntilDialogClosed(tester);

    final editedRow = find.byKey(ValueKey('communityPost-${olderPost.postId}'));
    await _pumpUntilVisible(
      tester,
      find.descendant(of: editedRow, matching: find.text('Updated effort')),
    );
    posts = await repository.readPosts();
    expect(posts.last.title, 'Updated effort');
    expect(posts.last.body, 'I repaired two household items.');
    expect(
      find.descendant(of: editedRow, matching: find.text('Updated effort')),
      findsOneWidget,
    );

    await tester.drag(find.byType(Scrollable).first, const Offset(0, 1000));
    await tester.pumpAndSettle();
    final latestDeleteTooltip = find.descendant(
      of: latestRow,
      matching: find.byTooltip('Delete post'),
    );
    final latestDeleteButton = find.ancestor(
      of: latestDeleteTooltip,
      matching: find.byType(IconButton),
    );
    await _fullyRevealDeleteButton(tester, latestDeleteButton);
    await tester.tap(latestDeleteButton);
    await _pumpUntilPostCount(tester, repository, 1);
    expect((await repository.readPosts()).single.title, 'Updated effort');

    final editedDeleteTooltip = find.descendant(
      of: editedRow,
      matching: find.byTooltip('Delete post'),
    );
    final editedDeleteButton = find.ancestor(
      of: editedDeleteTooltip,
      matching: find.byType(IconButton),
    );
    await _fullyRevealDeleteButton(tester, editedDeleteButton);
    await tester.tap(editedDeleteButton);
    await _pumpUntilPostCount(tester, repository, 0);
    expect(await repository.readPosts(), isEmpty);
    final emptyState = find.text(
      'No posts yet. Add your first post to start your personal record.',
    );
    await tester.scrollUntilVisible(
      emptyState,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(emptyState, findsOneWidget);
    await _closeJournal(tester, database);
  });

  testWidgets('journal and post form remain readable at 200% text', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = CommunityPostRepository(database: database);
    await _openJournal(tester, repository, textScale: 2);

    expectNoTextOverlapOrClipping(tester, 'Community journal at 200% text');
    await tester.tap(find.byKey(const ValueKey('communityAddPostButton')));
    await _pumpUntilVisible(tester, find.byType(AlertDialog));
    expectNoTextOverlapOrClipping(
      tester,
      'Community post form at 200% text',
      within: find.byType(AlertDialog),
    );
    await tester.tap(find.text('Cancel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    final finalGuideline = find.text(
      'In this version the forum is a personal, on-device feed. A shared community would arrive in a later version.',
    );
    await tester.scrollUntilVisible(
      finalGuideline,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(finalGuideline, findsOneWidget);
    expectNoTextOverlapOrClipping(
      tester,
      'Community guidelines at 200% text',
      within: find.byKey(const ValueKey('communityJournalList')),
    );
    expect(tester.takeException(), isNull);
    await _closeJournal(tester, database);
  });
}

Future<void> _openJournal(
  WidgetTester tester,
  CommunityPostRepository repository, {
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    _TestApp(
      textScale: textScale,
      child: CommunityJournalScreen(repository: repository),
    ),
  );
  await _pumpUntilVisible(
    tester,
    find.text(
      'No posts yet. Add your first post to start your personal record.',
    ),
  );
}

Future<void> _createPost(
  WidgetTester tester, {
  required String title,
  required String body,
}) async {
  await tester.ensureVisible(
    find.byKey(const ValueKey('communityAddPostButton')),
  );
  await tester.tap(find.byKey(const ValueKey('communityAddPostButton')));
  await _pumpUntilVisible(tester, find.text('Save post'));
  final titleField = find.byKey(const ValueKey('communityPostTitleField'));
  final bodyField = find.byKey(const ValueKey('communityPostBodyField'));
  await tester.ensureVisible(titleField);
  await tester.enterText(titleField, title);
  await tester.ensureVisible(bodyField);
  await tester.enterText(bodyField, body);
  await tester.tap(find.byKey(const ValueKey('communitySavePostButton')));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  await _pumpUntilVisible(tester, find.text(title));
}

Future<void> _pumpUntilVisible(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 30; attempt++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
  fail('Widget did not appear: $finder');
}

Future<void> _pumpUntilDialogClosed(WidgetTester tester) async {
  final dialog = find.byType(AlertDialog);
  for (var attempt = 0; attempt < 30; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (dialog.evaluate().isEmpty) return;
  }
  fail('The journal post dialog did not close.');
}

Future<void> _fullyRevealDeleteButton(
  WidgetTester tester,
  Finder target,
) async {
  final scrollable = find.byType(Scrollable).first;
  final viewport = find.byType(Viewport).first;
  for (var attempt = 0; attempt < 20; attempt++) {
    final targetBounds = tester.getRect(target);
    final viewportBounds = tester.getRect(viewport);
    if (viewportBounds.contains(targetBounds.topLeft) &&
        viewportBounds.contains(targetBounds.bottomRight)) {
      return;
    }
    final delta = targetBounds.bottom > viewportBounds.bottom
        ? const Offset(0, -100)
        : const Offset(0, 100);
    await tester.drag(scrollable, delta);
    await tester.pump();
  }
  fail('Delete control could not be fully brought into view: $target');
}

Future<void> _pumpUntilPostCount(
  WidgetTester tester,
  CommunityPostRepository repository,
  int count,
) async {
  for (var attempt = 0; attempt < 30; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    if ((await repository.readPosts()).length == count) return;
  }
  fail('The journal did not update to $count posts.');
}

Future<void> _closeJournal(WidgetTester tester, AppDatabase database) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
  await database.close();
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child, this.textScale = 1});

  final Widget child;
  final double textScale;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.light,
    home: child,
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
