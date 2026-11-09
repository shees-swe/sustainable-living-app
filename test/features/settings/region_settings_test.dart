import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/core/data/regions/region_catalog.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/features/settings/data/user_preferences_repository.dart';
import 'package:sustainable_living_app/features/settings/presentation/region_picker.dart';
import 'package:sustainable_living_app/l10n/generated/app_localizations.dart';

void main() {
  late AppDatabase database;
  late UserPreferencesRepository preferences;
  late RegionCatalog catalog;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    preferences = UserPreferencesRepository(
      database: database,
      supportedRegionIds: const {'PK', 'demo-region'},
    );
    catalog = RegionCatalog(
      regions: const [
        RegionCatalogEntry(
          regionId: 'PK',
          nameKey: 'regionPakistan',
          currencyCode: 'PKR',
        ),
        RegionCatalogEntry(
          regionId: 'demo-region',
          nameKey: 'regionDemoOnly',
          currencyCode: 'USD',
          demoOnly: true,
        ),
      ],
    );
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('region picker defaults to English without selecting a region', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(preferences: preferences, catalog: catalog),
    );
    await tester.pumpAndSettle();

    expect(find.text('Choose a region'), findsOneWidget);
    expect(find.text('Display language: English'), findsOneWidget);
    expect(find.text('No region selected'), findsOneWidget);
    expect((await preferences.load()).selectedRegionId, isNull);
  });

  testWidgets(
    'region selection updates region and currency without changing language',
    (tester) async {
      await preferences.setDisplayLanguageTag('fr');
      await tester.pumpWidget(
        _TestApp(preferences: preferences, catalog: catalog),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pakistan'));
      await tester.pumpAndSettle();

      expect(find.text('Currency: PKR'), findsNWidgets(2));
      expect(find.text('Display language: fr'), findsOneWidget);
      final settings = await preferences.load();
      expect(settings.selectedRegionId, 'PK');
      expect(settings.displayLanguageTag, 'fr');

      await tester.tap(find.text('Demo region (demo only)'));
      await tester.pumpAndSettle();

      expect(find.text('Currency: USD'), findsOneWidget);
      expect(find.text('Display language: fr'), findsOneWidget);
      final switchedSettings = await preferences.load();
      expect(switchedSettings.selectedRegionId, 'demo-region');
      expect(switchedSettings.displayLanguageTag, 'fr');
    },
  );

  testWidgets('demo fixture remains explicitly labelled demo-only', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(preferences: preferences, catalog: catalog),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Demo region (demo only)'));
    await tester.pumpAndSettle();

    expect(find.text('Demo region (demo only)'), findsOneWidget);
    expect(find.textContaining('DEMO ONLY'), findsNWidgets(2));
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.preferences, required this.catalog});

  final UserPreferencesRepository preferences;
  final RegionCatalog catalog;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: RegionPicker(preferences: preferences, catalog: catalog),
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
