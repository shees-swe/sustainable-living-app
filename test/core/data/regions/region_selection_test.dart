import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/core/data/regions/region_catalog.dart';
import 'package:sustainable_living_app/features/settings/data/user_preferences_repository.dart';

void main() {
  late AppDatabase database;
  late UserPreferencesRepository preferences;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    preferences = UserPreferencesRepository(
      database: database,
      supportedRegionIds: const {'PK', 'demo-region'},
    );
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'defaults display language to English with no implicit region',
    () async {
      final settings = await preferences.load();

      expect(settings.displayLanguageTag, 'en');
      expect(settings.selectedRegionId, isNull);
    },
  );

  test(
    'persists explicit region selection independently of display language',
    () async {
      await preferences.selectRegion('PK');
      await preferences.setDisplayLanguageTag('fr');
      final settings = await preferences.load();

      expect(settings.selectedRegionId, 'PK');
      expect(settings.displayLanguageTag, 'fr');
    },
  );

  test(
    'rejects unknown region selection without silently changing selection',
    () async {
      await preferences.selectRegion('PK');

      await expectLater(
        preferences.selectRegion('XX'),
        throwsA(isA<UnsupportedRegionSelection>()),
      );

      expect((await preferences.load()).selectedRegionId, 'PK');
    },
  );

  test('formats selected ISO currency independently of display language', () {
    final formatted = RegionCatalog.formatCurrency(
      1200,
      currencyCode: 'PKR',
      locale: 'en',
    );

    expect(formatted, contains('PKR'));
    expect(
      () =>
          RegionCatalog.formatCurrency(1200, currencyCode: 'PK1', locale: 'en'),
      throwsA(isA<ArgumentError>()),
    );
  });
}
