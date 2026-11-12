import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/data/database/app_database.dart';
import '../core/data/regions/foundation_references.dart';
import '../core/data/regions/region_catalog.dart';
import '../core/data/regions/region_repository.dart';
import '../core/accessibility/motion_aware_progress_indicator.dart';
import '../core/theme/app_theme.dart';
import '../features/account/data/account_repository.dart';
import '../features/account/data/password_hasher.dart';
import '../features/carbon_footprint_tracker/data/activity_log_repository.dart';
import '../features/certifications_guide/data/certification_catalog.dart';
import '../features/eco_friendly_product_suggestions/data/product_catalog.dart';
import '../features/sustainable_living_challenges/data/challenge_catalog.dart';
import '../features/sustainable_living_challenges/data/challenge_progress_repository.dart';
import '../features/onboarding/data/estimate_demo_fixtures.dart';
import '../features/onboarding/data/footprint_estimate_repository.dart';
import '../features/settings/data/user_data_deleter.dart';
import '../features/settings/data/user_data_exporter.dart';
import '../features/settings/data/user_data_file_sharer.dart';
import '../features/settings/data/user_preferences_repository.dart';
import '../l10n/generated/app_localizations.dart';
import 'router.dart';

class SustainableLivingApp extends StatefulWidget {
  const SustainableLivingApp({
    this.database,
    this.regionRepository,
    this.foundationReferences,
    this.productCatalog,
    this.challengeCatalog,
    this.certificationCatalog,
    super.key,
  });

  final AppDatabase? database;
  final RegionRepository? regionRepository;
  final FoundationReferences? foundationReferences;
  final ProductCatalog? productCatalog;
  final ChallengeCatalog? challengeCatalog;
  final CertificationCatalog? certificationCatalog;

  @override
  State<SustainableLivingApp> createState() => _SustainableLivingAppState();
}

class _SustainableLivingAppState extends State<SustainableLivingApp> {
  late AppDatabase _database;
  late final bool _ownsDatabase = widget.database == null;
  late FootprintEstimateRepository _estimateRepository;
  late ActivityLogRepository _activityLogRepository;
  late ChallengeProgressRepository _challengeProgressRepository;
  late AccountRepository _accountRepository;
  late Future<GoRouter> _router;
  GoRouter? _resolvedRouter;

  @override
  void initState() {
    super.initState();
    _initializeStorage(widget.database ?? AppDatabase());
    _router = _createRouter();
  }

  void _initializeStorage(AppDatabase database) {
    _database = database;
    _estimateRepository = FootprintEstimateRepository(database: database);
    _activityLogRepository = ActivityLogRepository(database: database);
    _challengeProgressRepository = ChallengeProgressRepository(
      database: database,
    );
    _accountRepository = AccountRepository(
      database: database,
      passwordHasher: const PasswordHasher(),
    );
  }

  Future<GoRouter> _createRouter({String? initialLocation}) async {
    final regionRepository =
        widget.regionRepository ?? await RegionRepository.loadBundled();
    final foundationReferences =
        widget.foundationReferences ?? await FoundationReferences.loadBundled();
    final productCatalog =
        widget.productCatalog ?? await ProductCatalog.loadBundled();
    final challengeCatalog =
        widget.challengeCatalog ?? await ChallengeCatalog.loadBundled();
    final certificationCatalog =
        widget.certificationCatalog ?? await CertificationCatalog.loadBundled();
    final regionCatalog = RegionCatalog.fromRepository(regionRepository);
    final preferences = UserPreferencesRepository(
      database: _database,
      supportedRegionIds: regionCatalog.regions
          .map((region) => region.regionId)
          .toSet(),
    );
    final preferencesSnapshot = await preferences.load();
    final selectedRegionId =
        preferencesSnapshot.selectedRegionId ??
        await _estimateRepository.loadLatestEstimateRegionId();
    final demoRegion = selectedRegionId == 'demo-region'
        ? foundationEstimateDemoRegions.single
        : null;
    final selectedRegionPack = selectedRegionId == null || demoRegion != null
        ? null
        : regionRepository.requireRegion(selectedRegionId);
    final savedFactors = selectedRegionPack == null
        ? demoRegion?.factors ?? const []
        : emissionFactorsFromRegionPack(selectedRegionPack);
    final savedEstimate = selectedRegionId == null
        ? null
        : await _estimateRepository.loadLatestCompleteEstimate(
            factors: savedFactors,
            expectedRegionId: selectedRegionId,
          );
    await AppDatabase.excludeDatabaseFromBackup();
    final router = createAppRouter(
      initialLocation:
          initialLocation ??
          (savedEstimate == null ? AppRoutes.onboarding : AppRoutes.home),
      estimateRepository: _estimateRepository,
      activityLogRepository: _activityLogRepository,
      accountRepository: _accountRepository,
      userDataExporter: UserDataExporter(database: _database),
      userPreferencesRepository: preferences,
      regionCatalog: regionCatalog,
      regionRepository: regionRepository,
      foundationReferences: foundationReferences,
      productCatalog: productCatalog,
      challengeCatalog: challengeCatalog,
      certificationCatalog: certificationCatalog,
      challengeProgressRepository: _challengeProgressRepository,
      selectedRegionPack: selectedRegionPack,
      demoRegion: demoRegion,
      userDataDeleter: UserDataDeleter(
        database: _database,
        closeDatabase: _database.close,
        deleteDatabaseFiles: AppDatabase.deleteDatabaseFiles,
        onGuestReset: _resetToGuest,
      ),
      onGuestReturn: () async {},
      shareUserData: const UserDataFileSharer().shareExport,
      hasSavedEstimate: savedEstimate != null,
    );
    if (!mounted) {
      router.dispose();
      return router;
    }
    _resolvedRouter = router;
    return router;
  }

  Future<void> _resetToGuest() async {
    if (!mounted) return;
    _resolvedRouter?.dispose();
    _resolvedRouter = null;
    _initializeStorage(AppDatabase());
    setState(() {
      _router = _createRouter(initialLocation: AppRoutes.home);
    });
  }

  @override
  void dispose() {
    _resolvedRouter?.dispose();
    if (_ownsDatabase) unawaited(_database.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: FutureBuilder<GoRouter>(
        future: _router,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return MaterialApp(
              theme: AppTheme.light,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: Text(
                      '${AppLocalizations.of(context)!.startupFailure}\n'
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          }
          final router = snapshot.data;
          if (router == null) {
            return MaterialApp(
              theme: AppTheme.light,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: MotionAwareProgressIndicator(
                      semanticsLabel: AppLocalizations.of(context)!.loading,
                    ),
                  ),
                ),
              ),
            );
          }
          return MaterialApp.router(
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)!.appTitle,
            theme: AppTheme.light,
            routerConfig: router,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );
  }
}
