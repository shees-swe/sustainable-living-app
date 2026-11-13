import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/features/waste_reduction_tracker/data/waste_log_repository.dart';
import 'package:sustainable_living_app/features/waste_reduction_tracker/domain/waste_category.dart';
import 'package:sustainable_living_app/features/waste_reduction_tracker/presentation/module_destination_screen.dart';
import 'package:sustainable_living_app/features/settings/data/user_preferences_repository.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

import '../../support/text_layout_expectations.dart';

void main() {
  testWidgets('empty state describes a new waste log', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = WasteLogRepository(database: database);
    final preferences = _preferences(database);
    await tester.pumpWidget(
      _TestApp(repository: repository, preferences: preferences),
    );
    await _pumpUntilVisible(tester, find.text('No waste logged yet.'));

    expect(
      find.text('These waste amounts are your own estimates.'),
      findsOneWidget,
    );
    expect(find.text('No waste logged this month yet.'), findsOneWidget);
    await _closeWasteTrackerTest(tester, database);
  });

  testWidgets(
    'adding entries shows exact amounts and totals; delete corrects totals',
    (tester) async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      var tick = 0;
      final repository = WasteLogRepository(
        database: database,
        clock: () => DateTime.now().toUtc().add(Duration(seconds: tick++)),
      );
      final preferences = _preferences(database);
      await tester.pumpWidget(
        _TestApp(repository: repository, preferences: preferences),
      );
      await _pumpUntilVisible(tester, find.text('No waste logged yet.'));

      await _addWasteEntry(tester, 'Plastic', '1.25');
      expect(find.text('1.25 kg'), findsWidgets);
      await tester.pump(const Duration(milliseconds: 150));
      expect(await _monthTotal(tester), '1.25 kg');

      await _addWasteEntry(tester, 'Paper & cardboard', '2.75');
      expect(find.text('2.75 kg'), findsWidgets);
      await tester.pump(const Duration(milliseconds: 150));
      expect(await _monthTotal(tester), '4.00 kg');
      final entries = await repository.readEntries();
      expect(entries, hasLength(2));
      expect(entries.first.amountKg, 2.75);
      expect(entries.last.amountKg, 1.25);
      final today = DateTime.now();
      expect(
        entries.every(
          (entry) =>
              entry.wasteDate.year == today.year &&
              entry.wasteDate.month == today.month &&
              entry.wasteDate.day == today.day,
        ),
        isTrue,
      );

      await tester.tap(find.byTooltip('Delete waste entry').first);
      await _pumpUntilMonthTotal(tester, '1.25 kg');

      expect(await repository.readEntries(), hasLength(1));
      expect(find.text('2.75 kg'), findsNothing);
      expect(await _monthTotal(tester), '1.25 kg');
      await _closeWasteTrackerTest(tester, database);
    },
  );

  testWidgets('screen remains readable at 200 percent text size', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = WasteLogRepository(database: database);
    await repository.addEntry(
      date: DateTime.now(),
      category: WasteCategory.paperAndCardboard,
      amountKg: 12.5,
    );
    final preferences = _preferences(database);
    await tester.pumpWidget(
      _TestApp(repository: repository, preferences: preferences, textScale: 2),
    );
    await _pumpUntilVisible(tester, find.text('12.50 kg'));

    expectNoTextOverlapOrClipping(tester, 'Waste Tracker');
    final addButton = find.byKey(const ValueKey('wasteAddEntryButton'));
    await tester.scrollUntilVisible(
      addButton,
      120,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('wasteTrackerList')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(addButton);
    await _pumpUntilVisible(tester, find.text('Save entry'));
    await tester.pump(const Duration(milliseconds: 150));
    expectNoTextOverlapOrClipping(
      tester,
      'Waste entry dialog',
      within: find.byType(AlertDialog),
    );
    await tester.tap(find.byKey(const ValueKey('wasteCategoryPicker')));
    await tester.pump(const Duration(milliseconds: 250));
    expectNoTextOverlapOrClipping(
      tester,
      'Waste category picker',
      within: find.byType(Scrollable).last,
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Other').last);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('Cancel'));
    await tester.pump(const Duration(milliseconds: 150));
    await _closeWasteTrackerTest(tester, database);
  });

  testWidgets('category picker presents all six categories', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = WasteLogRepository(database: database);
    final preferences = _preferences(database);
    await tester.pumpWidget(
      _TestApp(repository: repository, preferences: preferences),
    );
    await _pumpUntilVisible(tester, find.text('No waste logged yet.'));

    await tester.tap(find.byKey(const ValueKey('wasteAddEntryButton')));
    await _pumpUntilVisible(tester, find.text('Save entry'));
    await tester.pump(const Duration(milliseconds: 150));
    final amountField = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const ValueKey('wasteAmountField')),
        matching: find.byType(TextField),
      ),
    );
    expect(amountField.style?.fontFamily, startsWith('IBMPlexMono'));
    await tester.tap(find.byKey(const ValueKey('wasteCategoryPicker')));
    await _pumpUntilVisible(tester, find.text('Paper & cardboard'));
    for (final category in [
      'Plastic',
      'Paper & cardboard',
      'Glass',
      'Metal',
      'Organic',
      'Other',
    ]) {
      expect(find.text(category), findsWidgets);
    }
    await tester.tap(find.text('Other').last);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('Cancel'));
    await tester.pump(const Duration(milliseconds: 200));
    await _closeWasteTrackerTest(tester, database);
  });
}

Future<void> _addWasteEntry(
  WidgetTester tester,
  String category,
  String amount,
) async {
  final addButton = find.byKey(const ValueKey('wasteAddEntryButton'));
  await tester.ensureVisible(addButton);
  await tester.tap(addButton);
  await _pumpUntilVisible(tester, find.text('Save entry'));

  await tester.pump(const Duration(milliseconds: 150));
  if (category != 'Plastic') {
    await tester.tap(find.byKey(const ValueKey('wasteCategoryPicker')));
    await _pumpUntilVisible(tester, find.text(category));
    await tester.tap(find.text(category).last);
    await tester.pump(const Duration(milliseconds: 200));
  }

  await tester.enterText(
    find.byKey(const ValueKey('wasteAmountField')),
    amount,
  );
  await tester.ensureVisible(find.text('Save entry'));
  await tester.pump();
  await tester.tap(find.text('Save entry'));
  await tester.pump(const Duration(milliseconds: 200));
  await _pumpUntilVisible(tester, find.text('$amount kg'));
}

Future<String> _monthTotal(WidgetTester tester) async {
  final total = find.byKey(const ValueKey('wasteMonthTotalValue'));
  await tester.drag(find.byType(Scrollable).first, const Offset(0, 1000));
  await tester.pump();
  await _pumpUntilVisible(tester, total);
  return tester.widget<Text>(total).textSpan!.toPlainText();
}

Future<void> _pumpUntilMonthTotal(WidgetTester tester, String expected) async {
  for (var attempt = 0; attempt < 30; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (await _monthTotal(tester) == expected) return;
  }
  fail(
    'Month total did not become $expected; '
    'actual: ${await _monthTotal(tester)}',
  );
}

Future<void> _pumpUntilVisible(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 30; attempt++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
  fail('Widget did not appear: $finder');
}

Future<void> _closeWasteTrackerTest(
  WidgetTester tester,
  AppDatabase database,
) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
  await database.close();
}

class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.repository,
    required this.preferences,
    this.textScale = 1,
  });

  final WasteLogRepository repository;
  final UserPreferencesRepository preferences;
  final double textScale;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.light,
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: WasteReductionTrackerScreen(
        repository: repository,
        preferences: preferences,
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

UserPreferencesRepository _preferences(AppDatabase database) =>
    UserPreferencesRepository(database: database, supportedRegionIds: const {});
