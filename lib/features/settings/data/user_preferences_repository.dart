import 'package:drift/drift.dart';

import '../../../core/data/database/app_database.dart';

class UserPreferencesRepository {
  UserPreferencesRepository({
    required this._database,
    required Set<String> supportedRegionIds,
    DateTime Function()? clock,
  }) : _supportedRegionIds = Set.unmodifiable(supportedRegionIds),
       _clock = clock ?? DateTime.now;

  final AppDatabase _database;
  final Set<String> _supportedRegionIds;
  final DateTime Function() _clock;

  Future<UserPreferencesSettings> load() async {
    var row =
        await (_database.select(_database.userPreferences)
              ..where((preference) => preference.preferenceId.equals(1)))
            .getSingleOrNull();
    if (row == null) {
      await _database.savePreferences(
        UserPreferencesCompanion.insert(
          preferenceId: const Value(1),
          displayLanguageTag: const Value('en'),
          updatedAt: _clock().toUtc(),
        ),
      );
      row = await (_database.select(
        _database.userPreferences,
      )..where((preference) => preference.preferenceId.equals(1))).getSingle();
    }
    return UserPreferencesSettings(
      displayLanguageTag: row.displayLanguageTag,
      selectedRegionId: row.selectedRegionId,
    );
  }

  Future<void> selectRegion(String? regionId) async {
    if (regionId != null && !_supportedRegionIds.contains(regionId)) {
      throw UnsupportedRegionSelection(regionId);
    }
    final current = await load();
    await _database.savePreferences(
      UserPreferencesCompanion(
        preferenceId: const Value(1),
        displayLanguageTag: Value(current.displayLanguageTag),
        selectedRegionId: Value(regionId),
        updatedAt: Value(_clock().toUtc()),
      ),
    );
  }

  Future<void> setDisplayLanguageTag(String languageTag) async {
    final normalized = languageTag.trim();
    if (!_languageTag.hasMatch(normalized)) {
      throw ArgumentError.value(
        languageTag,
        'languageTag',
        'Must be a valid BCP 47 tag.',
      );
    }
    final current = await load();
    await _database.savePreferences(
      UserPreferencesCompanion(
        preferenceId: const Value(1),
        displayLanguageTag: Value(normalized),
        selectedRegionId: Value(current.selectedRegionId),
        updatedAt: Value(_clock().toUtc()),
      ),
    );
  }
}

class UserPreferencesSettings {
  const UserPreferencesSettings({
    required this.displayLanguageTag,
    required this.selectedRegionId,
  });

  final String displayLanguageTag;
  final String? selectedRegionId;
}

class UnsupportedRegionSelection implements Exception {
  const UnsupportedRegionSelection(this.regionId);

  final String regionId;

  @override
  String toString() => 'UnsupportedRegionSelection: $regionId';
}

final _languageTag = RegExp(r'^[A-Za-z]{2,8}(-[A-Za-z0-9]{1,8})*$');
