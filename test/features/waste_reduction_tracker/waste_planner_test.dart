import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/features/settings/data/user_preferences_repository.dart';
import 'package:sustainable_living_app/features/waste_reduction_tracker/data/waste_log_repository.dart';
import 'package:sustainable_living_app/features/waste_reduction_tracker/presentation/module_destination_screen.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

import '../../support/text_layout_expectations.dart';

void main() {
  testWidgets('planner days start unset, persist, change, and clear', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    await tester.pumpWidget(_TestApp(database: database, textScale: 1));
    await _scrollToPlanner(tester);
    await _pumpUntilVisible(
      tester,
      find.text('Set your recycling collection day.'),
    );

    expect(find.text('Set your compost day.'), findsOneWidget);
    expect(find.text('Recycling: Not set · Compost: Not set'), findsOneWidget);

    await _selectDay(tester, 'wasteRecyclingDayPicker', 'Tuesday');
    expect(find.text('Recycling: Tuesday · Compost: Not set'), findsOneWidget);
    await _selectDay(tester, 'wasteCompostDayPicker', 'Friday');
    expect(find.text('Recycling: Tuesday · Compost: Friday'), findsOneWidget);

    final freshRead = await _preferences(database).load();
    expect(freshRead.recyclingCollectionDay, DateTime.tuesday);
    expect(freshRead.compostDay, DateTime.friday);

    await _selectDay(tester, 'wasteRecyclingDayPicker', 'Wednesday');
    expect(find.text('Recycling: Wednesday · Compost: Friday'), findsOneWidget);
    await _selectDay(tester, 'wasteCompostDayPicker', 'Not set');
    expect(
      find.text('Recycling: Wednesday · Compost: Not set'),
      findsOneWidget,
    );
    expect(find.text('Set your compost day.'), findsOneWidget);
    final updatedRead = await _preferences(database).load();
    expect(updatedRead.recyclingCollectionDay, DateTime.wednesday);
    expect(updatedRead.compostDay, isNull);
    expect(tester.takeException(), isNull);

    await _closeTest(tester, database);
  });

  testWidgets('all six tips render fully and planner fits at 200% text', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    await tester.pumpWidget(_TestApp(database: database, textScale: 2));
    await _scrollToPlanner(tester);
    await _pumpUntilVisible(
      tester,
      find.text('Set your recycling collection day.'),
    );

    expectNoTextOverlapOrClipping(tester, 'Waste planner at 200% text');
    final list = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('wasteCompostDayPicker')),
      300,
      scrollable: list,
    );
    await tester.pump();
    expectNoTextOverlapOrClipping(
      tester,
      'Waste day controls at 200% text',
      within: find.byKey(const ValueKey('wastePlannerSection')),
    );
    await tester.scrollUntilVisible(
      find.text('Keep both bins close'),
      300,
      scrollable: list,
    );
    await tester.pump();
    expectNoTextOverlapOrClipping(
      tester,
      'Waste tips at 200% text',
      within: find.byKey(const ValueKey('wasteTipsSection')),
    );

    const tips = [
      (
        'Keep both bins close',
        'Keep a small recycling bin beside the main bin — sorting is easier when both are within reach.',
      ),
      (
        'Compost the right scraps',
        'Compost fruit and vegetable scraps, eggshells, and coffee grounds — keep meat and dairy out of a home compost pile.',
      ),
      (
        'Rinse before recycling',
        'Rinse containers before recycling — food residue can spoil a whole batch of recyclables.',
      ),
      (
        'Flatten cardboard',
        'Flatten cardboard boxes — they take a fraction of the space and are easier to store until collection day.',
      ),
      (
        'Buy loose where you can',
        'Buy loose produce instead of pre-packed where you can — less packaging enters the house in the first place.',
      ),
      (
        'Donate or repair first',
        'Keep a "donate or repair" box — items you no longer use leave the house useful instead of becoming waste.',
      ),
    ];
    for (final (title, text) in tips) {
      expect(find.text(title), findsOneWidget);
      expect(find.text(text), findsOneWidget);
    }
    expect(tester.takeException(), isNull);

    await _closeTest(tester, database);
  });
}

Future<void> _selectDay(
  WidgetTester tester,
  String pickerKey,
  String option,
) async {
  final picker = find.byKey(ValueKey(pickerKey));
  final scrollable = find.byType(Scrollable).first;
  await tester.drag(scrollable, const Offset(0, 1000));
  await tester.pump();
  final dropdown = find.descendant(
    of: picker,
    matching: find.byType(DropdownButtonFormField<int>),
  );
  await tester.scrollUntilVisible(dropdown, 250, scrollable: scrollable);
  await _fullyReveal(tester, dropdown, scrollable);
  await tester.tap(dropdown);
  await _pumpUntilVisible(tester, find.text(option));
  await tester.tap(find.text(option).last);
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _fullyReveal(
  WidgetTester tester,
  Finder target,
  Finder scrollable,
) async {
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
  fail('Widget could not be fully brought into view: $target');
}

Future<void> _scrollToPlanner(WidgetTester tester) async {
  await tester.pump();
  await tester.scrollUntilVisible(
    find.text('Weekly planner'),
    250,
    scrollable: find.byType(Scrollable).first,
  );
}

Future<void> _pumpUntilVisible(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 30; attempt++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
  fail('Widget did not appear: $finder');
}

Future<void> _closeTest(WidgetTester tester, AppDatabase database) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
  await database.close();
}

UserPreferencesRepository _preferences(AppDatabase database) =>
    UserPreferencesRepository(database: database, supportedRegionIds: const {});

class _TestApp extends StatelessWidget {
  const _TestApp({required this.database, required this.textScale});

  final AppDatabase database;
  final double textScale;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.light,
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: WasteReductionTrackerScreen(
        repository: WasteLogRepository(database: database),
        preferences: _preferences(database),
      ),
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
