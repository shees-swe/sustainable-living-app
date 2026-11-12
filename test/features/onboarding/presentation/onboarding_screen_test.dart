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

import '../../../support/text_layout_expectations.dart';

void main() {
  late FoundationReferences foundationReferences;
  late RegionRepository regions;

  setUpAll(() async {
    foundationReferences = await FoundationReferences.loadBundled();
    regions = await RegionRepository.loadBundled();
  });

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

  testWidgets('onboarding stays readable and unclipped at Very Large text', (
    tester,
  ) async {
    final router = createAppRouter(initialLocation: AppRoutes.onboarding);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
    });

    await tester.pumpWidget(_TestApp(router: router, textScale: 2.0));
    await _pumpUntilVisible(tester, find.text('Choose a region'));

    await tester.tap(find.text('Demo region (demo only)'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Annual electricity use (kWh)'), findsOneWidget);
    expect(find.text('Annual travel (km)'), findsOneWidget);
    expect(tester.takeException(), isNull);
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
    'shows the demo budget share, category context, and cited factor sources',
    (tester) async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final catalog = RegionCatalog.fromRepository(regions);
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
        foundationReferences: foundationReferences,
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
      tester.testTextInput.hide();
      final calculateButton = find.text('Calculate demo estimate');
      await tester.ensureVisible(calculateButton);
      await tester.pumpAndSettle();
      await tester.tap(calculateButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await _pumpUntilVisible(tester, findTextContaining('DEMO ONLY'));
      expect(findTextContaining('DEMO ONLY'), findsWidgets);
      expect(find.text('Your estimated footprint'), findsOneWidget);
      final resultScrollable = find
          .descendant(
            of: find.byKey(const ValueKey('estimateResultList')),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        findTextContaining('at least 1.8% of the 1.5° budget'),
        250,
        scrollable: resultScrollable,
      );
      expect(
        findTextContaining('at least 1.8% of the 1.5° budget'),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.text('Category breakdown'),
        250,
        scrollable: resultScrollable,
      );
      expect(find.text('Category breakdown'), findsOneWidget);
      expect(findTextContaining('Electricity'), findsWidgets);
      expect(findTextContaining('Transport'), findsWidgets);
      await tester.scrollUntilVisible(
        find.text('Estimate coverage'),
        250,
        scrollable: resultScrollable,
      );
      expect(find.text('Estimate coverage'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Factors used in this estimate'),
        250,
        scrollable: resultScrollable,
      );
      expect(find.text('Factors used in this estimate'), findsOneWidget);
      expect(findTextContaining('Demonstration fixture only'), findsWidgets);
      expect(findTextContaining('Publication year: 2026'), findsWidgets);
      expect(find.text('Regional average'), findsNothing);
      expect(find.text('Global average'), findsNothing);
      expect(find.text('Sign in'), findsNothing);
    },
  );

  testWidgets(
    'demo region selected through the regional picker produces a result',
    (tester) async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final catalog = RegionCatalog.fromRepository(regions);
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
        foundationReferences: foundationReferences,
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
      tester.testTextInput.hide();
      final calculateButton = find.text('Calculate demo estimate');
      await tester.ensureVisible(calculateButton);
      await tester.pumpAndSettle();
      await tester.tap(calculateButton);
      await tester.pump();
      await _pumpUntilVisible(tester, find.text('Your estimated footprint'));

      expect(find.text('Your estimated footprint'), findsOneWidget);
    },
  );

  testWidgets(
    'uses the selected Pakistan pack without an incompatible budget share',
    (tester) async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final catalog = RegionCatalog.fromRepository(regions);
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
        foundationReferences: foundationReferences,
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
      tester.testTextInput.hide();
      final button = find.text('Calculate estimate');
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -250));
      await tester.pump();
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await _pumpUntilVisible(
        tester,
        find.byKey(const ValueKey('estimateRegionLabel')),
      );
      expect(find.text('Your estimated footprint'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 120));
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('estimateRegionLabel')))
            .data,
        'Pakistan',
      );
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('estimateTotal')))
            .textSpan!
            .toPlainText(),
        '34.70 kg CO2/year',
      );
      expect(find.text('Currency: PKR'), findsWidgets);
      expect(
        find.text(
          'A budget share is not shown because this estimate cannot be compared with the cited benchmark.',
        ),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('budgetShareBar')), findsNothing);
      expect(find.text('Regional average'), findsNothing);
      expect(find.text('Global average'), findsNothing);
      expect(
        findTextContaining('2.5 t CO2e/person/year by 2030'),
        findsOneWidget,
      );

      await tester.scrollUntilVisible(
        findTextContaining('Yearly Electricity Data'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(findTextContaining('Ember'), findsOneWidget);
      expect(findTextContaining('Publication year: 2025'), findsWidgets);
      final settings = await preferences.load();
      expect(settings.selectedRegionId, 'PK');
      expect(settings.displayLanguageTag, 'en');

      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
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
    final button = find.text('Calculate demo estimate');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -200));
    await tester.pump();
    await tester.ensureVisible(button);
    await tester.tap(button);
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
  const _TestApp({required this.router, this.textScale = 1});

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
