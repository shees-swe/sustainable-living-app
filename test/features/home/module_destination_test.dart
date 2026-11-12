import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/app/router.dart';
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/features/certifications_guide/data/certification_catalog.dart';
import 'package:sustainable_living_app/features/carbon_footprint_tracker/data/activity_log_repository.dart';
import 'package:sustainable_living_app/features/community_journal/data/community_post_repository.dart';
import 'package:sustainable_living_app/features/eco_friendly_product_suggestions/data/product_catalog.dart';
import 'package:sustainable_living_app/features/eco_travel_suggestions/data/travel_guide_catalog.dart';
import 'package:sustainable_living_app/features/eco_travel_suggestions/data/travel_trip_repository.dart';
import 'package:sustainable_living_app/features/sustainable_living_challenges/data/challenge_catalog.dart';
import 'package:sustainable_living_app/features/sustainable_living_challenges/data/challenge_progress_repository.dart';
import 'package:sustainable_living_app/features/settings/data/user_preferences_repository.dart';
import 'package:sustainable_living_app/features/waste_reduction_tracker/data/waste_log_repository.dart';
import 'package:sustainable_living_app/features/recipes_meal_planning/data/recipe_catalog.dart';
import 'package:sustainable_living_app/features/home/domain/module_destination.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

import '../../support/text_layout_expectations.dart';

void main() {
  late ProductCatalog productCatalog;
  late ChallengeCatalog challengeCatalog;
  late CertificationCatalog certificationCatalog;
  late RecipeCatalog recipeCatalog;
  late TravelGuideCatalog travelGuideCatalog;
  late AppDatabase challengeDatabase;
  late ChallengeProgressRepository challengeProgressRepository;
  late WasteLogRepository wasteLogRepository;
  late UserPreferencesRepository wastePreferencesRepository;
  late TravelTripRepository travelTripRepository;
  late CommunityPostRepository communityPostRepository;
  late ActivityLogRepository activityLogRepository;

  setUpAll(() async {
    productCatalog = await ProductCatalog.loadBundled();
    challengeCatalog = await ChallengeCatalog.loadBundled();
    certificationCatalog = await CertificationCatalog.loadBundled();
    recipeCatalog = await RecipeCatalog.loadBundled();
    travelGuideCatalog = await TravelGuideCatalog.loadBundled();
    challengeDatabase = AppDatabase.forTesting(NativeDatabase.memory());
    challengeProgressRepository = ChallengeProgressRepository(
      database: challengeDatabase,
    );
    wasteLogRepository = WasteLogRepository(database: challengeDatabase);
    wastePreferencesRepository = UserPreferencesRepository(
      database: challengeDatabase,
      supportedRegionIds: const {},
    );
    travelTripRepository = TravelTripRepository(database: challengeDatabase);
    communityPostRepository = CommunityPostRepository(
      database: challengeDatabase,
    );
    activityLogRepository = ActivityLogRepository(database: challengeDatabase);
  });

  tearDownAll(() async {
    await challengeDatabase.close();
  });

  testWidgets('all module destinations remain readable at Very Large text', (
    tester,
  ) async {
    for (final destination in ModuleDestination.modules) {
      final router = createAppRouter(
        initialLocation: destination.path,
        productCatalog: productCatalog,
        challengeCatalog: challengeCatalog,
        certificationCatalog: certificationCatalog,
        recipeCatalog: recipeCatalog,
        travelGuideCatalog: travelGuideCatalog,
        challengeProgressRepository: challengeProgressRepository,
        wasteLogRepository: wasteLogRepository,
        travelTripRepository: travelTripRepository,
        communityPostRepository: communityPostRepository,
        activityLogRepository: activityLogRepository,
        userPreferencesRepository: wastePreferencesRepository,
      );
      await tester.pumpWidget(_TestApp(router: router, textScale: 2));
      if (destination.id == 'sustainableLivingChallenges') {
        await _pumpUntilVisible(tester, find.text('Plastic-Free Week'));
      } else if (destination.id == 'wasteReductionTracker') {
        await _pumpUntilVisible(
          tester,
          find.text('These waste amounts are your own estimates.'),
        );
      } else if (destination.id == 'ecoTravelSuggestions') {
        await _pumpUntilVisible(tester, find.text('No trips planned yet.'));
      } else if (destination.id == 'energyConservationTips') {
        await _pumpUntilVisible(
          tester,
          find.text('Use fans before air conditioning'),
        );
      } else if (destination.id == 'communityJournal') {
        await _pumpUntilVisible(
          tester,
          find.text(
            'No posts yet. Add your first post to start your personal record.',
          ),
        );
      } else if (destination.id == 'educationalContent') {
        await _pumpUntilVisible(tester, find.text('Search by title or body'));
      } else {
        await tester.pumpAndSettle();
      }

      if (destination.id == 'carbonFootprintTracker') {
        expect(find.text('Carbon Footprint Tracker'), findsOneWidget);
        expectNoTextOverlapOrClipping(tester, destination.path);
        final emptyState = find.text(
          'No activities logged for this period yet.',
        );
        await tester.scrollUntilVisible(
          emptyState,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        expect(emptyState, findsOneWidget);
      } else if (destination.id == 'ecoFriendlyProductSuggestions') {
        expect(find.text('Search by name or note'), findsOneWidget);
      } else if (destination.id == 'sustainableLivingChallenges') {
        expect(find.text('Plastic-Free Week'), findsOneWidget);
      } else if (destination.id == 'certificationsGuide') {
        expect(find.text('Search by name or meaning'), findsOneWidget);
      } else if (destination.id == 'recipesMealPlanning') {
        expect(
          find.text('Search by recipe name or ingredient'),
          findsOneWidget,
        );
      } else if (destination.id == 'wasteReductionTracker') {
        final emptyState = find.text('No waste logged yet.');
        await tester.scrollUntilVisible(
          emptyState,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(emptyState, findsOneWidget);
      } else if (destination.id == 'ecoTravelSuggestions') {
        expect(find.text('No trips planned yet.'), findsOneWidget);
        expectNoTextOverlapOrClipping(tester, destination.path);
        final finalTip = find.text('Leave places as you found them');
        await tester.scrollUntilVisible(
          finalTip,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(finalTip, findsOneWidget);
      } else if (destination.id == 'communityJournal') {
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
        expectNoTextOverlapOrClipping(
          tester,
          destination.path,
          within: find.byKey(const ValueKey('communityJournalList')),
        );
        final lastGuideline = find.text(
          'In this version the forum is a personal, on-device feed. A shared community would arrive in a later version.',
        );
        await tester.scrollUntilVisible(
          lastGuideline,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(lastGuideline, findsOneWidget);
      } else if (destination.id == 'progressDashboard') {
        expect(
          find.text('Your progress will appear here as you use the app.'),
          findsOneWidget,
        );
        expectNoTextOverlapOrClipping(tester, destination.path);
        final scope = find.text(
          'Purchases are not tracked in this app, so they do not appear on this dashboard.',
        );
        await tester.scrollUntilVisible(
          scope,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(scope, findsOneWidget);
      } else if (destination.id == 'energyConservationTips') {
        expect(find.text('Search by title or text'), findsOneWidget);
        expectNoTextOverlapOrClipping(tester, destination.path);
        final lastTip = find.byKey(
          const ValueKey('energyTip-Take one small solar step'),
        );
        await tester.scrollUntilVisible(
          lastTip,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(lastTip, findsOneWidget);
      } else if (destination.id == 'educationalContent') {
        expect(find.text('Search by title or body'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('educationalArticleList')),
          findsOneWidget,
        );
        expectNoTextOverlapOrClipping(
          tester,
          destination.path,
          within: find.byKey(const ValueKey('educationalArticleList')),
        );
      } else {
        expect(
          find.text('Foundation destination'),
          findsOneWidget,
          reason: '${destination.path} must show its destination title',
        );
        expect(
          find.text('Detailed features will be available in a future update.'),
          findsOneWidget,
          reason: '${destination.path} must show its existing details',
        );
      }
      if (destination.id == 'energyConservationTips') {
        expectNoTextOverlapOrClipping(
          tester,
          destination.path,
          within: find.byKey(const ValueKey('energyTipsList')),
        );
      } else if (destination.id == 'ecoTravelSuggestions') {
        expectNoTextOverlapOrClipping(
          tester,
          destination.path,
          within: find.byKey(const ValueKey('travelPlannerList')),
        );
      } else if (destination.id == 'progressDashboard') {
        expectNoTextOverlapOrClipping(
          tester,
          destination.path,
          within: find.byKey(const ValueKey('progressDashboardList')),
        );
      } else if (destination.id != 'carbonFootprintTracker') {
        expectNoTextOverlapOrClipping(tester, destination.path);
      }
      expect(
        tester.takeException(),
        isNull,
        reason: '${destination.path} must not overflow at Very Large text',
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      router.dispose();
    }
  });

  test('registers exactly the required 11 primary module destinations', () {
    expect(
      ModuleDestination.modules.map((destination) => destination.id).toSet(),
      {
        'carbonFootprintTracker',
        'ecoFriendlyProductSuggestions',
        'sustainableLivingChallenges',
        'certificationsGuide',
        'wasteReductionTracker',
        'recipesMealPlanning',
        'energyConservationTips',
        'ecoTravelSuggestions',
        'communityJournal',
        'progressDashboard',
        'educationalContent',
      },
    );
    expect(ModuleDestination.modules, hasLength(11));
    expect(
      ModuleDestination.modules.every(
        (destination) =>
            destination.navigationGroup == NavigationGroup.homePrimary,
      ),
      isTrue,
    );
    expect(
      ModuleDestination.modules.every(
        (destination) =>
            destination.availability == DestinationAvailability.foundationStub,
      ),
      isTrue,
    );
  });

  test('keeps About Us reachable from Home outside the module inventory', () {
    expect(ModuleDestination.aboutUsPath, '/about');
    expect(ModuleDestination.aboutUsTitleKey, 'aboutUs');
  });

  test('provides stable routes and localization keys for every module', () {
    final paths = ModuleDestination.modules
        .map((destination) => destination.path)
        .toSet();
    final titleKeys = ModuleDestination.modules
        .map((destination) => destination.titleKey)
        .toSet();

    expect(paths, hasLength(11));
    expect(titleKeys, hasLength(11));
    expect(paths, isNot(contains('/gallery')));
    expect(paths, isNot(contains('/contact')));
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.router, required this.textScale});

  final RouterConfig<Object> router;
  final double textScale;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}

Future<void> _pumpUntilVisible(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 30; attempt++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
  fail('Widget did not appear: $finder');
}
