import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/core/data/regions/region_repository.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/features/carbon_footprint_tracker/data/activity_log_repository.dart';
import 'package:sustainable_living_app/features/community_journal/data/community_post_repository.dart';
import 'package:sustainable_living_app/features/eco_travel_suggestions/data/travel_trip_repository.dart';
import 'package:sustainable_living_app/features/onboarding/data/estimate_demo_fixtures.dart';
import 'package:sustainable_living_app/features/onboarding/domain/footprint_estimate.dart';
import 'package:sustainable_living_app/features/progress_dashboard/presentation/module_destination_screen.dart';
import 'package:sustainable_living_app/features/sustainable_living_challenges/data/challenge_progress_repository.dart';
import 'package:sustainable_living_app/features/waste_reduction_tracker/data/waste_log_repository.dart';
import 'package:sustainable_living_app/features/waste_reduction_tracker/domain/waste_category.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

import '../../support/text_layout_expectations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<EmissionFactor> factors;

  setUpAll(() async {
    final regionRepository = await RegionRepository.loadBundled();
    factors = emissionFactorsFromRegionPack(
      regionRepository.requireRegion('PK'),
    );
  });

  testWidgets('shows exact totals and monthly trends from stored data', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final activities = ActivityLogRepository(database: database);
    final waste = WasteLogRepository(database: database);
    final challenges = ChallengeProgressRepository(database: database);
    final trips = TravelTripRepository(database: database);
    final posts = CommunityPostRepository(database: database);
    final year = DateTime.now().year;

    await activities.addElectricity(
      date: DateTime(year, 1, 12),
      amountKwh: 1,
      regionId: 'PK',
      factors: factors,
    );
    await activities.addElectricity(
      date: DateTime(year, 2, 12),
      amountKwh: 2,
      regionId: 'PK',
      factors: factors,
    );
    await waste.addEntry(
      date: DateTime(year, 1, 12),
      category: WasteCategory.plastic,
      amountKg: 1.11,
    );
    await waste.addEntry(
      date: DateTime(year, 2, 12),
      category: WasteCategory.paperAndCardboard,
      amountKg: 2.22,
    );
    await challenges.startChallenge('challenge-one');
    await challenges.startChallenge('challenge-two');
    await challenges.setDayCompleted(
      challengeId: 'challenge-one',
      totalDays: 3,
      dayNumber: 1,
      completed: true,
    );
    await challenges.setDayCompleted(
      challengeId: 'challenge-one',
      totalDays: 3,
      dayNumber: 2,
      completed: true,
    );
    await challenges.setDayCompleted(
      challengeId: 'challenge-two',
      totalDays: 5,
      dayNumber: 1,
      completed: true,
    );
    await trips.addTrip(
      title: 'Weekend visit',
      destination: 'Lahore',
      transportMode: 'Train',
    );
    await trips.addTrip(
      title: 'Coastal break',
      destination: 'Karachi',
      transportMode: 'Bus or coach',
    );
    await posts.addPost(title: 'Small change', body: 'Carried a reusable bag.');

    await tester.pumpWidget(
      _TestApp(
        child: ProgressDashboardScreen(
          activityLogRepository: activities,
          wasteLogRepository: waste,
          challengeProgressRepository: challenges,
          travelTripRepository: trips,
          communityPostRepository: posts,
        ),
      ),
    );
    await _pumpUntilVisible(
      tester,
      find.byKey(const ValueKey('progressCarbonAllTimeTotal')),
    );

    expect(_value(tester, 'progressCarbonAllTimeTotal'), '1.04 kg CO2e');
    expect(_value(tester, 'progressWasteAllTimeTotal'), '3.33 kg');
    await _reveal(tester, find.byKey(const ValueKey('progressCarbonMonth-1')));
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('progressCarbonMonth-1')),
        matching: find.text('0.35 kg CO2e'),
      ),
      findsOneWidget,
    );
    await _reveal(tester, find.byKey(const ValueKey('progressCarbonMonth-2')));
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('progressCarbonMonth-2')),
        matching: find.text('0.69 kg CO2e'),
      ),
      findsOneWidget,
    );
    await _reveal(tester, find.byKey(const ValueKey('progressWasteMonth-1')));
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('progressWasteMonth-1')),
        matching: find.text('1.11 kg'),
      ),
      findsOneWidget,
    );
    await _reveal(tester, find.byKey(const ValueKey('progressWasteMonth-2')));
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('progressWasteMonth-2')),
        matching: find.text('2.22 kg'),
      ),
      findsOneWidget,
    );
    await _reveal(tester, find.byKey(const ValueKey('progressChallengeCount')));
    expect(_value(tester, 'progressChallengeCount'), '2');
    expect(_value(tester, 'progressChallengeDaysChecked'), '3');
    await _reveal(
      tester,
      find.byKey(const ValueKey('progressTravelTripCount')),
    );
    expect(_value(tester, 'progressTravelTripCount'), '2');
    await _reveal(
      tester,
      find.byKey(const ValueKey('progressJournalPostCount')),
    );
    expect(_value(tester, 'progressJournalPostCount'), '1');
    expect(tester.takeException(), isNull);
    await _closeDashboardTest(tester, database);
  });

  testWidgets('shows overall and source-specific empty states and scope', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    await tester.pumpWidget(_TestApp(child: _screen(database)));
    await _pumpUntilVisible(
      tester,
      find.text('Your progress will appear here as you use the app.'),
    );

    expect(
      find.text('No activity logged yet. Start in Carbon Footprint Tracker.'),
      findsOneWidget,
    );
    expect(
      find.text('No waste logged yet. Start in Waste Reduction Tracker.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'No challenges joined yet. Start in Sustainable Living Challenges.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('No trips planned yet. Start in Eco-Travel Suggestions.'),
      findsOneWidget,
    );
    expect(
      find.text('No posts written yet. Start in Community Journal.'),
      findsOneWidget,
    );
    final scope = find.text(
      'Purchases are not tracked in this app, so they do not appear on this dashboard.',
    );
    await _reveal(tester, scope);
    expect(scope, findsOneWidget);
    await _closeDashboardTest(tester, database);
  });

  testWidgets('remains readable at 200 percent text size', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    await tester.pumpWidget(_TestApp(textScale: 2, child: _screen(database)));
    await _pumpUntilVisible(
      tester,
      find.text('Your progress will appear here as you use the app.'),
    );
    expectNoTextOverlapOrClipping(tester, 'Sustainability Progress Dashboard');
    final scope = find.text(
      'Purchases are not tracked in this app, so they do not appear on this dashboard.',
    );
    await _reveal(tester, scope);
    expect(scope, findsOneWidget);
    expectNoTextOverlapOrClipping(
      tester,
      'Sustainability Progress Dashboard',
      within: find.byKey(const ValueKey('progressDashboardList')),
    );
    expect(tester.takeException(), isNull);
    await _closeDashboardTest(tester, database);
  });
}

ProgressDashboardScreen _screen(AppDatabase database) =>
    ProgressDashboardScreen(
      activityLogRepository: ActivityLogRepository(database: database),
      wasteLogRepository: WasteLogRepository(database: database),
      challengeProgressRepository: ChallengeProgressRepository(
        database: database,
      ),
      travelTripRepository: TravelTripRepository(database: database),
      communityPostRepository: CommunityPostRepository(database: database),
    );

String? _value(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(ValueKey(key))).data;

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _pumpUntilVisible(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 30; attempt++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
  fail('Widget did not appear: $finder');
}

Future<void> _closeDashboardTest(
  WidgetTester tester,
  AppDatabase database,
) async {
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
