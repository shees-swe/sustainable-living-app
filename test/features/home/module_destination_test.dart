import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/app/router.dart';
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/features/certifications_guide/data/certification_catalog.dart';
import 'package:sustainable_living_app/features/eco_friendly_product_suggestions/data/product_catalog.dart';
import 'package:sustainable_living_app/features/sustainable_living_challenges/data/challenge_catalog.dart';
import 'package:sustainable_living_app/features/sustainable_living_challenges/data/challenge_progress_repository.dart';
import 'package:sustainable_living_app/features/home/domain/module_destination.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

import '../../support/text_layout_expectations.dart';

void main() {
  late ProductCatalog productCatalog;
  late ChallengeCatalog challengeCatalog;
  late CertificationCatalog certificationCatalog;
  late AppDatabase challengeDatabase;
  late ChallengeProgressRepository challengeProgressRepository;

  setUpAll(() async {
    productCatalog = await ProductCatalog.loadBundled();
    challengeCatalog = await ChallengeCatalog.loadBundled();
    certificationCatalog = await CertificationCatalog.loadBundled();
    challengeDatabase = AppDatabase.forTesting(NativeDatabase.memory());
    challengeProgressRepository = ChallengeProgressRepository(
      database: challengeDatabase,
    );
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
        challengeProgressRepository: challengeProgressRepository,
      );
      await tester.pumpWidget(_TestApp(router: router, textScale: 2));
      if (destination.id == 'sustainableLivingChallenges') {
        await _pumpUntilVisible(tester, find.text('Plastic-Free Week'));
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
      if (destination.id != 'carbonFootprintTracker') {
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
