import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/app/router.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/core/data/regions/foundation_references.dart';
import 'package:sustainable_living_app/core/data/regions/region_catalog.dart';
import 'package:sustainable_living_app/core/data/regions/region_repository.dart';
import 'package:sustainable_living_app/features/onboarding/data/footprint_estimate_repository.dart';
import 'package:sustainable_living_app/features/settings/data/user_preferences_repository.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('selects a demo region before showing estimate questions', (
    tester,
  ) async {
    final router = createAppRouter(initialLocation: AppRoutes.onboarding);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
    });

    await tester.pumpWidget(_TestApp(router: router));
    await _pumpUntilVisible(tester, find.text('Choose a region'));

    expect(find.text('Choose a region'), findsOneWidget);
    expect(find.text('Annual electricity use (kWh)'), findsNothing);
    expect(find.text('Demo region (demo only)'), findsOneWidget);

    await tester.tap(find.text('Demo region (demo only)'));
    await tester.pump();

    expect(find.text('Annual electricity use (kWh)'), findsOneWidget);
    expect(find.text('Annual travel (km)'), findsOneWidget);
  });

  testWidgets('can skip onboarding and continue as a guest', (tester) async {
    final router = createAppRouter(initialLocation: AppRoutes.onboarding);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
    });

    await tester.pumpWidget(_TestApp(router: router));
    await _pumpUntilVisible(tester, find.text('Skip and continue as guest'));

    await tester.tap(find.text('Skip and continue as guest'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(router.routeInformationProvider.value.uri.path, AppRoutes.home);
    expect(find.text('Sustainable Living Guide'), findsOneWidget);
    expect(find.text('Sign in'), findsNothing);
  });

  testWidgets(
    'shows demo-only result, all references, and actual factor sources',
    (tester) async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final router = createAppRouter(
        initialLocation: AppRoutes.onboarding,
        estimateRepository: FootprintEstimateRepository(database: database),
      );
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        router.dispose();
      });

      await tester.pumpWidget(_TestApp(router: router));
      await _pumpUntilVisible(tester, find.text('Choose a region'));

      await tester.tap(find.text('Demo region (demo only)'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(
        find.byKey(const ValueKey('electricityInput')),
        '100',
      );
      await tester.enterText(find.byKey(const ValueKey('travelInput')), '200');
      await tester.tap(find.text('Calculate demo estimate'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('DEMO ONLY — not a verified estimate'), findsOneWidget);
      expect(find.text('Your estimated footprint'), findsOneWidget);
      for (final label in [
        'Regional average',
        'Global average',
        '1.5°C-aligned budget',
      ]) {
        await tester.scrollUntilVisible(
          find.text(label),
          250,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text(label), findsOneWidget);
      }
      await tester.scrollUntilVisible(
        find.text('Factors used in this estimate'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Factors used in this estimate'), findsOneWidget);
      expect(find.textContaining('Demonstration fixture only'), findsWidgets);
      expect(find.textContaining('Publication year: 2026'), findsWidgets);
      expect(find.text('Sign in'), findsNothing);
    },
  );

  testWidgets(
    'demo region selected through the regional picker produces a result',
    (tester) async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final regions = await RegionRepository.loadBundled();
      final catalog = RegionCatalog.fromRepository(regions);
      final references = await FoundationReferences.loadBundled();
      final preferences = UserPreferencesRepository(
        database: database,
        supportedRegionIds: catalog.regions
            .map((region) => region.regionId)
            .toSet(),
      );
      final router = createAppRouter(
        initialLocation: AppRoutes.onboarding,
        estimateRepository: FootprintEstimateRepository(database: database),
        userPreferencesRepository: preferences,
        regionCatalog: catalog,
        regionRepository: regions,
        foundationReferences: references,
      );
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        router.dispose();
      });

      await tester.pumpWidget(_TestApp(router: router));
      await _pumpUntilVisible(tester, find.text('Demo region (demo only)'));

      await tester.tap(find.text('Demo region (demo only)'));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(
        find.byKey(const ValueKey('electricityInput')),
        '100',
      );
      await tester.enterText(find.byKey(const ValueKey('travelInput')), '200');
      final calculateButton = find.text('Calculate demo estimate');
      await tester.ensureVisible(calculateButton);
      await tester.tap(calculateButton);
      await tester.pump();
      await _pumpUntilVisible(tester, find.text('Your estimated footprint'));

      expect(find.text('Your estimated footprint'), findsOneWidget);
    },
  );

  testWidgets(
    'uses the selected Pakistan pack and shows references without false rings',
    (tester) async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final regions = await RegionRepository.loadBundled();
      final catalog = RegionCatalog.fromRepository(regions);
      final references = await FoundationReferences.loadBundled();
      final preferences = UserPreferencesRepository(
        database: database,
        supportedRegionIds: catalog.regions
            .map((region) => region.regionId)
            .toSet(),
      );
      final router = createAppRouter(
        initialLocation: AppRoutes.onboarding,
        estimateRepository: FootprintEstimateRepository(database: database),
        userPreferencesRepository: preferences,
        regionCatalog: catalog,
        regionRepository: regions,
        foundationReferences: references,
      );
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        router.dispose();
      });

      await tester.pumpWidget(_TestApp(router: router));
      await _pumpUntilVisible(tester, find.text('Pakistan'));
      expect(find.text('Choose a region'), findsOneWidget);
      await tester.tap(find.text('Pakistan'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const ValueKey('electricityInput')), findsOneWidget);
      expect(find.byKey(const ValueKey('travelInput')), findsNothing);
      expect(
        find.text(
          'Transport data unavailable — no cited factor is included in this pack.',
        ),
        findsOneWidget,
      );
      await tester.enterText(
        find.byKey(const ValueKey('electricityInput')),
        '100',
      );
      await tester.scrollUntilVisible(
        find.text('Calculate estimate'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Calculate estimate'));
      await tester.pumpAndSettle();

      expect(find.text('Your estimated footprint'), findsOneWidget);
      expect(find.text('Pakistan'), findsOneWidget);
      expect(find.text('34.70 kg CO2/year'), findsOneWidget);
      expect(find.text('Currency: PKR'), findsOneWidget);
      expect(find.text('Comparison unavailable'), findsWidgets);
      expect(find.textContaining('Contextual reference only'), findsWidgets);

      for (final reference in [
        '0.72 t CO2/person',
        '4.70 t CO2/person',
        '2.50 t CO2e/person/year',
      ]) {
        await tester.scrollUntilVisible(
          find.textContaining(reference),
          250,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.textContaining(reference), findsOneWidget);
      }

      await tester.scrollUntilVisible(
        find.textContaining('Yearly Electricity Data'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('Ember'), findsOneWidget);
      expect(find.textContaining('Publication year: 2025'), findsWidgets);
      final settings = await preferences.load();
      expect(settings.selectedRegionId, 'PK');
      expect(settings.displayLanguageTag, 'en');

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Choose a region'), findsOneWidget);
    },
  );

  testWidgets('incomplete answers do not produce an estimate', (tester) async {
    final router = createAppRouter(initialLocation: AppRoutes.onboarding);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
    });

    await tester.pumpWidget(_TestApp(router: router));
    await _pumpUntilVisible(tester, find.text('Choose a region'));

    await tester.tap(find.text('Demo region (demo only)'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(
      find.byKey(const ValueKey('electricityInput')),
      '100',
    );
    await tester.tap(find.text('Calculate demo estimate'));
    await tester.pump();

    expect(
      find.text('Please answer each question to see an estimate.'),
      findsOneWidget,
    );
    expect(find.text('Your estimated footprint'), findsNothing);
    expect(
      router.routeInformationProvider.value.uri.path,
      AppRoutes.onboarding,
    );
  });
}

Future<void> _pumpUntilVisible(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 20; attempt++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
  fail('Widget did not appear: $finder');
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.router});

  final RouterConfig<Object> router;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
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
