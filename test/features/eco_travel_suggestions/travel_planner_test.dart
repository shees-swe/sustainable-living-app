import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/features/eco_travel_suggestions/data/travel_guide_catalog.dart';
import 'package:sustainable_living_app/features/eco_travel_suggestions/data/travel_trip_repository.dart';
import 'package:sustainable_living_app/features/eco_travel_suggestions/presentation/module_destination_screen.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

import '../../support/text_layout_expectations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TravelGuideCatalog catalog;

  setUpAll(() async {
    catalog = await TravelGuideCatalog.loadBundled();
  });

  testWidgets('empty state describes a new travel plan', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = TravelTripRepository(database: database);
    await _openPlanner(tester, repository, catalog);

    expect(find.text('No trips planned yet.'), findsOneWidget);
    expect(find.text('Plan a trip'), findsOneWidget);

    await _closePlanner(tester, database);
  });

  testWidgets('creating, editing, and deleting a trip updates the saved plan', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = TravelTripRepository(database: database);
    await _openPlanner(tester, repository, catalog);

    await _openTripForm(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('travelTitleField')));
    await tester.enterText(
      find.byKey(const ValueKey('travelTitleField')),
      'Weekend by train',
    );
    await tester.enterText(
      find.byKey(const ValueKey('travelDestinationField')),
      'York',
    );
    expect(
      find.text(
        'The lowest-impact way to travel — no fuel, no emissions, and you see the place properly.',
      ),
      findsOneWidget,
    );
    await _selectMode(tester, 'Train');
    expect(
      find.text(
        'One of the lowest-impact motorised options, especially on electric lines.',
      ),
      findsOneWidget,
    );
    final dateButton = find.byKey(const ValueKey('travelChooseDateButton'));
    await tester.ensureVisible(dateButton);
    await tester.tap(dateButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    final notesField = find.byKey(const ValueKey('travelNotesField'));
    await tester.ensureVisible(notesField);
    await tester.enterText(notesField, 'Pack light.');
    await tester.tap(find.byKey(const ValueKey('travelSaveTripButton')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    await _pumpUntilVisible(tester, find.text('Weekend by train'));
    var trips = await repository.readTrips();
    expect(trips, hasLength(1));
    var trip = trips.single;
    final tripRow = find.byKey(ValueKey('travelTrip-${trip.tripId}'));
    expect(
      find.descendant(of: tripRow, matching: find.text('Weekend by train')),
      findsOneWidget,
    );
    expect(trip.destination, 'York');
    expect(trip.transportMode, 'Train');
    expect(trip.tripDate, isNotNull);
    expect(trip.notes, 'Pack light.');
    expect(
      find.descendant(
        of: tripRow,
        matching: find.text(
          'One of the lowest-impact motorised options, especially on electric lines.',
        ),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(of: tripRow, matching: find.byTooltip('Edit trip')),
    );
    await _pumpUntilVisible(tester, find.text('Update trip'));
    final titleField = _dialogField('travelTitleField');
    await tester.ensureVisible(titleField);
    await tester.enterText(titleField, 'Train weekend');
    await tester.enterText(_dialogField('travelDestinationField'), 'Leeds');
    await _selectMode(tester, 'Ferry');
    expect(
      find.text(
        'A reasonable option for coastal and island routes; slower usually means gentler.',
      ),
      findsOneWidget,
    );
    final clearDateButton = _dialogField('travelClearDateButton');
    await tester.ensureVisible(clearDateButton);
    await tester.tap(clearDateButton);
    final editNotesField = _dialogField('travelNotesField');
    await tester.ensureVisible(editNotesField);
    await tester.enterText(editNotesField, 'Take the coastal route.');
    await tester.tap(find.byKey(const ValueKey('travelSaveTripButton')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    await _pumpUntilVisible(tester, find.text('Train weekend'));
    trips = await repository.readTrips();
    expect(trips, hasLength(1));
    trip = trips.single;
    expect(trip.title, 'Train weekend');
    expect(trip.destination, 'Leeds');
    expect(trip.transportMode, 'Ferry');
    expect(trip.tripDate, isNull);
    expect(trip.notes, 'Take the coastal route.');
    final editedTripRow = find.byKey(ValueKey('travelTrip-${trip.tripId}'));
    expect(
      find.descendant(
        of: editedTripRow,
        matching: find.text(
          'A reasonable option for coastal and island routes; slower usually means gentler.',
        ),
      ),
      findsOneWidget,
    );

    final deleteButton = find.descendant(
      of: editedTripRow,
      matching: find.byTooltip('Delete trip'),
    );
    await tester.ensureVisible(deleteButton);
    await tester.tap(deleteButton);
    await _pumpUntilTripsDeleted(tester, repository);
    expect(await repository.readTrips(), isEmpty);
    final emptyState = find.text('No trips planned yet.');
    await _scrollBackUntilFound(tester, emptyState);
    expect(emptyState, findsOneWidget);

    await _closePlanner(tester, database);
  });

  testWidgets('all six supplied travel tips render in full', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = TravelTripRepository(database: database);
    await _openPlanner(tester, repository, catalog);
    final scrollable = find.byType(Scrollable).first;

    for (final tip in catalog.tips) {
      final title = find.text(tip.title);
      await tester.scrollUntilVisible(title, 200, scrollable: scrollable);
      expect(title, findsOneWidget);
      final text = find.text(tip.text);
      await tester.scrollUntilVisible(text, 120, scrollable: scrollable);
      expect(text, findsOneWidget);
    }

    await _closePlanner(tester, database);
  });

  testWidgets('planner and trip form remain readable at 200% text', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = TravelTripRepository(database: database);
    await _openPlanner(tester, repository, catalog, textScale: 2);

    expectNoTextOverlapOrClipping(tester, 'Travel planner at 200% text');
    final lastTip = find.text(catalog.tips.last.title);
    await tester.scrollUntilVisible(
      lastTip,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.scrollUntilVisible(
      find.text(catalog.tips.last.text),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expectNoTextOverlapOrClipping(
      tester,
      'Travel guide at 200% text',
      within: find.byKey(const ValueKey('travelPlannerList')),
    );
    expect(tester.takeException(), isNull);

    final addButton = find.byKey(const ValueKey('travelAddTripButton'));
    await _scrollBackUntilFound(tester, addButton);
    await tester.tap(addButton);
    await _pumpUntilVisible(
      tester,
      find.byKey(const ValueKey('travelTitleField')),
    );
    final notes = find.byKey(const ValueKey('travelNotesField'));
    await tester.scrollUntilVisible(
      notes,
      120,
      scrollable: find
          .descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expectNoTextOverlapOrClipping(
      tester,
      'Trip form at 200% text',
      within: find.byType(AlertDialog),
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Cancel'));
    await tester.pump();
    await _closePlanner(tester, database);
  });
}

Future<void> _openPlanner(
  WidgetTester tester,
  TravelTripRepository repository,
  TravelGuideCatalog catalog, {
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    _TestApp(
      textScale: textScale,
      child: EcoTravelSuggestionsScreen(
        repository: repository,
        catalog: catalog,
      ),
    ),
  );
  await _pumpUntilVisible(tester, find.text('No trips planned yet.'));
}

Future<void> _openTripForm(WidgetTester tester) async {
  final addButton = find.byKey(const ValueKey('travelAddTripButton'));
  await tester.ensureVisible(addButton);
  await tester.tap(addButton);
  await _pumpUntilVisible(
    tester,
    find.byKey(const ValueKey('travelTitleField')),
  );
}

Future<void> _selectMode(WidgetTester tester, String mode) async {
  final picker = _dialogField('travelModePicker');
  await tester.ensureVisible(picker);
  await tester.tap(picker);
  await tester.pumpAndSettle();
  await tester.tap(find.text(mode).last);
  await tester.pump();
}

Finder _dialogField(String key) => find.descendant(
  of: find.byType(AlertDialog).last,
  matching: find.byKey(ValueKey(key)),
);

Future<void> _pumpUntilVisible(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 30; attempt++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
  fail('Widget did not appear: $finder');
}

Future<void> _pumpUntilTripsDeleted(
  WidgetTester tester,
  TravelTripRepository repository,
) async {
  for (var attempt = 0; attempt < 30; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    if ((await repository.readTrips()).isEmpty) return;
  }
  fail('The deleted trip remained in the repository.');
}

Future<void> _scrollBackUntilFound(WidgetTester tester, Finder target) async {
  final scrollable = find.byType(Scrollable).first;
  for (var attempt = 0; attempt < 30; attempt++) {
    if (target.evaluate().isNotEmpty) {
      await tester.ensureVisible(target);
      await tester.pump();
      return;
    }
    await tester.drag(scrollable, const Offset(0, 250));
    await tester.pump(const Duration(milliseconds: 100));
  }
  fail('Widget did not appear while scrolling toward the top: $target');
}

Future<void> _closePlanner(WidgetTester tester, AppDatabase database) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
  await database.close();
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
