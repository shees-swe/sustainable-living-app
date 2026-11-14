import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../features/about/presentation/about_screen.dart';
import '../features/account/data/account_repository.dart';
import '../features/account/presentation/account_screen.dart';
import '../features/carbon_footprint_tracker/presentation/module_destination_screen.dart'
    as carbon;
import '../features/carbon_footprint_tracker/data/activity_log_repository.dart';
import '../features/eco_friendly_product_suggestions/data/product_catalog.dart';
import '../features/community_journal/data/community_post_repository.dart';
import '../features/eco_travel_suggestions/data/travel_guide_catalog.dart';
import '../features/eco_travel_suggestions/data/travel_trip_repository.dart';
import '../features/sustainable_living_challenges/data/challenge_catalog.dart';
import '../features/sustainable_living_challenges/data/challenge_progress_repository.dart';
import '../features/waste_reduction_tracker/data/waste_log_repository.dart';
import '../features/community_journal/presentation/module_destination_screen.dart'
    as journal;
import '../features/contact/presentation/contact_screen.dart';
import '../features/certifications_guide/presentation/module_destination_screen.dart'
    as certifications;
import '../features/certifications_guide/data/certification_catalog.dart';
import '../features/eco_friendly_product_suggestions/presentation/module_destination_screen.dart'
    as products;
import '../features/eco_travel_suggestions/presentation/module_destination_screen.dart'
    as travel;
import '../features/educational_content/presentation/module_destination_screen.dart'
    as education;
import '../features/energy_conservation_tips/presentation/module_destination_screen.dart'
    as energy;
import '../features/gallery/presentation/gallery_screen.dart';
import '../features/home/domain/module_destination.dart';
import '../features/explore/presentation/explore_hub_screen.dart';
import '../features/home/presentation/home_dashboard_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/you/presentation/you_screen.dart';
import 'app_shell.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/onboarding/data/footprint_estimate_repository.dart';
import '../features/onboarding/data/estimate_demo_fixtures.dart';
import '../features/onboarding/domain/footprint_estimate.dart';
import '../features/onboarding/presentation/estimate_result_screen.dart';
import '../core/data/regions/foundation_references.dart';
import '../core/data/regions/region_pack_parser.dart';
import '../core/data/regions/region_repository.dart';
import '../features/progress_dashboard/presentation/module_destination_screen.dart'
    as progress;
import '../features/recipes_meal_planning/presentation/module_destination_screen.dart'
    as recipes;
import '../features/recipes_meal_planning/data/recipe_catalog.dart';
import '../features/settings/data/user_data_deleter.dart';
import '../features/settings/data/user_data_exporter.dart';
import '../features/settings/data/user_data_importer.dart';
import '../features/settings/data/user_preferences_repository.dart';
import '../features/settings/presentation/privacy_policy_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../core/data/regions/region_catalog.dart';
import '../core/accessibility/reduced_motion.dart';
import '../core/motion/motion_spec.dart';
import '../features/sustainable_living_challenges/presentation/module_destination_screen.dart'
    as challenges;
import '../features/waste_reduction_tracker/presentation/module_destination_screen.dart'
    as waste;
import '../l10n/generated/app_localizations.dart';

abstract final class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String estimateResult = '/estimate-result';
  static const String home = '/home';
  static const String account = '/account';
  static const String settings = '/settings';
  static const String privacyPolicy = '/privacy-policy';
  static const String about = ModuleDestination.aboutUsPath;
  static const String gallery = '/gallery';
  static const String contact = '/contact';
  static const String explore = '/explore';
  static const String you = '/you';
}

GoRouter createAppRouter({
  String initialLocation = AppRoutes.onboarding,
  FootprintEstimateRepository? estimateRepository,
  ActivityLogRepository? activityLogRepository,
  AccountRepository? accountRepository,
  UserDataExporter? userDataExporter,
  UserDataDeleter? userDataDeleter,
  UserDataImporter? userDataImporter,
  UserPreferencesRepository? userPreferencesRepository,
  RegionCatalog? regionCatalog,
  RegionRepository? regionRepository,
  FoundationReferences? foundationReferences,
  ProductCatalog? productCatalog,
  ChallengeCatalog? challengeCatalog,
  CertificationCatalog? certificationCatalog,
  RecipeCatalog? recipeCatalog,
  TravelGuideCatalog? travelGuideCatalog,
  ChallengeProgressRepository? challengeProgressRepository,
  WasteLogRepository? wasteLogRepository,
  TravelTripRepository? travelTripRepository,
  CommunityPostRepository? communityPostRepository,
  RegionDataPack? selectedRegionPack,
  EstimateDemoRegion? demoRegion,
  Future<void> Function()? onGuestReturn,
  Future<void> Function()? onImportComplete,
  Future<ShareResult> Function(Map<String, Object?> export)? shareUserData,
  bool hasSavedEstimate = false,
  bool useTabShell = false,
}) {
  final onboardingRoutes = <RouteBase>[
      _appRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => OnboardingScreen(
          regionRepository: regionRepository,
          foundationReferences: foundationReferences,
          regionCatalog: regionCatalog,
          preferences: userPreferencesRepository,
        ),
      ),
      _appRoute(
        path: AppRoutes.estimateResult,
        builder: (context, state) {
          final extra = state.extra;
          final routeData = switch (extra) {
            null => null,
            OnboardingRouteData data => data,
            RegionalOnboardingRouteData data => data,
            _ => throw ArgumentError.value(
              extra,
              'extra',
              'Invalid estimate result route data',
            ),
          };
          return EstimateResultScreen(
            repository: estimateRepository,
            onboardingData: routeData is OnboardingRouteData ? routeData : null,
            regionalOnboardingData: routeData is RegionalOnboardingRouteData
                ? routeData
                : null,
            selectedRegionPack: selectedRegionPack,
            foundationReferences: foundationReferences,
            demoRegion: demoRegion,
          );
        },
      ),
    ];
  final appRoutes = <RouteBase>[
      _appRoute(
        path: AppRoutes.home,
        builder: (context, state) {
          final onViewEstimate = hasSavedEstimate && estimateRepository != null
              ? () => context.push(AppRoutes.estimateResult)
              : null;
          return useTabShell
              ? HomeDashboardScreen(
                  onViewEstimate: onViewEstimate,
                  activityLogRepository: activityLogRepository,
                )
              : HomeScreen(onViewEstimate: onViewEstimate);
        },
      ),
      _appRoute(
        path: AppRoutes.explore,
        builder: (context, state) => const ExploreHubScreen(),
      ),
      _appRoute(
        path: AppRoutes.you,
        builder: (context, state) => const YouScreen(),
      ),
      _appRoute(
        path: AppRoutes.account,
        builder: (context, state) => accountRepository == null
            ? _RoutePlaceholder(title: (l10n) => l10n.account)
            : AccountScreen(repository: accountRepository),
      ),
      _appRoute(
        path: AppRoutes.settings,
        builder: (context, state) =>
            userDataExporter == null ||
                userDataDeleter == null ||
                userDataImporter == null ||
                onGuestReturn == null
            ? _RoutePlaceholder(title: (l10n) => l10n.settings)
            : SettingsScreen(
                exporter: userDataExporter,
                deleter: userDataDeleter,
                importer: userDataImporter,
                onGuestReturn: onGuestReturn,
                onImportComplete: onImportComplete ?? () async {},
                shareExport: shareUserData,
                preferences: userPreferencesRepository,
                regionCatalog: regionCatalog,
              ),
      ),
      _appRoute(
        path: AppRoutes.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      _appRoute(
        path: AppRoutes.about,
        builder: (context, state) => const AboutScreen(),
      ),
      _appRoute(
        path: AppRoutes.gallery,
        builder: (context, state) => const GalleryScreen(),
      ),
      _appRoute(
        path: AppRoutes.contact,
        builder: (context, state) => const ContactScreen(),
      ),
      for (final destination in ModuleDestination.modules)
        _appRoute(
          path: destination.path,
          name: destination.id,
          builder: (context, state) => _moduleScreen(
            destination.id,
            activityLogRepository: activityLogRepository,
            foundationReferences: foundationReferences,
            productCatalog: productCatalog,
            challengeCatalog: challengeCatalog,
            certificationCatalog: certificationCatalog,
            recipeCatalog: recipeCatalog,
            travelGuideCatalog: travelGuideCatalog,
            challengeProgressRepository: challengeProgressRepository,
            wasteLogRepository: wasteLogRepository,
            travelTripRepository: travelTripRepository,
            communityPostRepository: communityPostRepository,
            userPreferencesRepository: userPreferencesRepository,
            trackerRegionId: selectedRegionPack?.region.regionId,
            trackerFactors: selectedRegionPack == null
                ? const []
                : emissionFactorsFromRegionPack(selectedRegionPack),
          ),
        ),
  ];
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      ...onboardingRoutes,
      if (useTabShell)
        ShellRoute(
          builder: (context, state, child) =>
              AppShell(location: state.uri.path, child: child),
          routes: appRoutes,
        )
      else
        ...appRoutes,
    ],
  );
}

GoRoute _appRoute({
  required String path,
  String? name,
  required Widget Function(BuildContext, GoRouterState) builder,
}) {
  return GoRoute(
    path: path,
    name: name,
    pageBuilder: (context, state) {
      final child = builder(context, state);
      if (ReducedMotion.isEnabled(context)) {
        return NoTransitionPage<void>(key: state.pageKey, child: child);
      }
      return CustomTransitionPage<void>(
        key: state.pageKey,
        child: child,
        transitionDuration: MotionSpec.optionalFade,
        reverseTransitionDuration: MotionSpec.optionalFade,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation.drive(
                CurveTween(curve: MotionSpec.optionalFadeCurve),
              ),
              child: child,
            ),
      );
    },
  );
}

Widget _moduleScreen(
  String moduleId, {
  required ActivityLogRepository? activityLogRepository,
  required FoundationReferences? foundationReferences,
  required ProductCatalog? productCatalog,
  required ChallengeCatalog? challengeCatalog,
  required CertificationCatalog? certificationCatalog,
  required RecipeCatalog? recipeCatalog,
  required TravelGuideCatalog? travelGuideCatalog,
  required ChallengeProgressRepository? challengeProgressRepository,
  required WasteLogRepository? wasteLogRepository,
  required TravelTripRepository? travelTripRepository,
  required CommunityPostRepository? communityPostRepository,
  required UserPreferencesRepository? userPreferencesRepository,
  required String? trackerRegionId,
  required List<EmissionFactor> trackerFactors,
}) => switch (moduleId) {
  'carbonFootprintTracker' => carbon.CarbonFootprintDestinationScreen(
    repository: activityLogRepository,
    regionId: trackerRegionId,
    factors: trackerFactors,
    references: foundationReferences,
  ),
  'ecoFriendlyProductSuggestions' =>
    products.EcoFriendlyProductSuggestionsScreen(catalog: productCatalog),
  'sustainableLivingChallenges' =>
    challengeCatalog == null || challengeProgressRepository == null
        ? _RoutePlaceholder(title: (l10n) => l10n.sustainableLivingChallenges)
        : challenges.SustainableLivingChallengesScreen(
            catalog: challengeCatalog,
            repository: challengeProgressRepository,
          ),
  'certificationsGuide' =>
    certificationCatalog == null
        ? _RoutePlaceholder(title: (l10n) => l10n.certificationsGuide)
        : certifications.CertificationsGuideScreen(
            catalog: certificationCatalog,
          ),
  'wasteReductionTracker' =>
    wasteLogRepository == null || userPreferencesRepository == null
        ? _RoutePlaceholder(title: (l10n) => l10n.wasteReductionTracker)
        : waste.WasteReductionTrackerScreen(
            repository: wasteLogRepository,
            preferences: userPreferencesRepository,
          ),
  'recipesMealPlanning' => recipes.RecipesMealPlanningScreen(
    catalog: recipeCatalog,
  ),
  'energyConservationTips' => const energy.EnergyConservationTipsScreen(),
  'ecoTravelSuggestions' =>
    travelTripRepository == null
        ? _RoutePlaceholder(title: (l10n) => l10n.ecoTravelSuggestions)
        : travel.EcoTravelSuggestionsScreen(
            repository: travelTripRepository,
            catalog: travelGuideCatalog,
          ),
  'communityJournal' =>
    communityPostRepository == null
        ? _RoutePlaceholder(title: (l10n) => l10n.communityJournal)
        : journal.CommunityJournalScreen(repository: communityPostRepository),
  'progressDashboard' =>
    activityLogRepository == null ||
            wasteLogRepository == null ||
            challengeProgressRepository == null ||
            travelTripRepository == null ||
            communityPostRepository == null
        ? _RoutePlaceholder(title: (l10n) => l10n.progressDashboard)
        : progress.ProgressDashboardScreen(
            activityLogRepository: activityLogRepository,
            wasteLogRepository: wasteLogRepository,
            challengeProgressRepository: challengeProgressRepository,
            travelTripRepository: travelTripRepository,
            communityPostRepository: communityPostRepository,
          ),
  'educationalContent' => const education.EducationalContentScreen(),
  _ => throw ArgumentError.value(
    moduleId,
    'moduleId',
    'Unknown module destination',
  ),
};

class _RoutePlaceholder extends StatelessWidget {
  const _RoutePlaceholder({required this.title});

  final String Function(AppLocalizations) title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final routeTitle = title(l10n);

    return Scaffold(
      appBar: AppBar(title: Text(routeTitle)),
      body: Center(child: Text(routeTitle)),
    );
  }
}
