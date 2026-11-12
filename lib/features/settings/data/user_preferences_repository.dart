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
      reducedMotion: row.reducedMotion,
      recyclingCollectionDay: row.recyclingCollectionDay,
      compostDay: row.compostDay,
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
        reducedMotion: Value(current.reducedMotion),
        recyclingCollectionDay: Value(current.recyclingCollectionDay),
        compostDay: Value(current.compostDay),
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
        reducedMotion: Value(current.reducedMotion),
        recyclingCollectionDay: Value(current.recyclingCollectionDay),
        compostDay: Value(current.compostDay),
        updatedAt: Value(_clock().toUtc()),
      ),
    );
  }

  Future<void> setWastePlannerDays({
    required int? recyclingCollectionDay,
    required int? compostDay,
  }) async {
    _validateWeekday(recyclingCollectionDay, 'recyclingCollectionDay');
    _validateWeekday(compostDay, 'compostDay');
    final current = await load();
    await _database.savePreferences(
      UserPreferencesCompanion(
        preferenceId: const Value(1),
        displayLanguageTag: Value(current.displayLanguageTag),
        selectedRegionId: Value(current.selectedRegionId),
        reducedMotion: Value(current.reducedMotion),
        recyclingCollectionDay: Value(recyclingCollectionDay),
        compostDay: Value(compostDay),
        updatedAt: Value(_clock().toUtc()),
      ),
    );
  }

  void _validateWeekday(int? day, String argumentName) {
    if (day != null && (day < DateTime.monday || day > DateTime.sunday)) {
      throw ArgumentError.value(
        day,
        argumentName,
        'Must be a weekday from Monday through Sunday, or null.',
      );
    }
  }
}

class UserPreferencesSettings {
  const UserPreferencesSettings({
    required this.displayLanguageTag,
    required this.selectedRegionId,
    required this.reducedMotion,
    required this.recyclingCollectionDay,
    required this.compostDay,
  });

  final String displayLanguageTag;
  final String? selectedRegionId;
  final bool? reducedMotion;
  final int? recyclingCollectionDay;
  final int? compostDay;
}

class UnsupportedRegionSelection implements Exception {
  const UnsupportedRegionSelection(this.regionId);

  final String regionId;

  @override
  String toString() => 'UnsupportedRegionSelection: $regionId';
}

final _languageTag = RegExp(r'^[A-Za-z]{2,8}(-[A-Za-z0-9]{1,8})*$');
