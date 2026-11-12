import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/data/database/app_database.dart';
import 'user_data_exporter.dart';

class UserDataImporter {
  const UserDataImporter({required this.database});

  final AppDatabase database;

  static const supportedExportSchemaVersions = {
    UserDataExporter.exportSchemaVersion,
  };

  PreparedUserDataImport prepareImport(String source) {
    final root = _object(jsonDecode(source), 'export');
    _requireKeys(root, const {
      'exportSchemaVersion',
      'createdAt',
      'userData',
    }, 'export');
    final version = root['exportSchemaVersion'];
    if (version is! int || !supportedExportSchemaVersions.contains(version)) {
      throw const FormatException('Unsupported export schema version.');
    }
    _date(root['createdAt'], 'export.createdAt');

    final userData = _object(root['userData'], 'userData');
    _requireKeys(userData, const {
      'accounts',
      'footprintEstimates',
      'activityLogEntries',
      'wasteLogEntries',
      'travelTrips',
      'communityPosts',
      'challengeProgress',
      'preferences',
    }, 'userData');

    final accounts = _parseAccounts(userData['accounts']);
    final estimates = _parseEstimates(userData['footprintEstimates']);
    final activityEntries = _parseActivityEntries(
      userData['activityLogEntries'],
    );
    final wasteEntries = _parseWasteEntries(userData['wasteLogEntries']);
    final trips = _parseTrips(userData['travelTrips']);
    final posts = _parsePosts(userData['communityPosts']);
    final challengeData = _parseChallengeProgress(
      userData['challengeProgress'],
    );
    final preferences = _parsePreferences(userData['preferences']);

    final accountIds = accounts.map((account) => account.accountId.value);
    final accountIdSet = accountIds.toSet();
    if (accountIdSet.length != accounts.length) {
      throw const FormatException('Duplicate account IDs in export.');
    }
    for (final estimate in estimates) {
      final owner = estimate.ownerAccountId.value;
      if (owner != null && !accountIdSet.contains(owner)) {
        throw const FormatException(
          'An estimate references an account missing from the export.',
        );
      }
    }

    return PreparedUserDataImport._(
      accounts: accounts,
      estimates: estimates,
      activityEntries: activityEntries,
      wasteEntries: wasteEntries,
      trips: trips,
      posts: posts,
      challengeProgress: challengeData.progress,
      challengeCompletions: challengeData.completions,
      preferences: preferences,
    );
  }

  Future<void> importJson(String source) async {
    await applyImport(prepareImport(source));
  }

  Future<void> applyImport(PreparedUserDataImport prepared) {
    return database.replaceAllUserData(() async {
      for (final account in prepared.accounts) {
        await database.into(database.localAccounts).insert(account);
      }
      for (final estimate in prepared.estimates) {
        await database.into(database.footprintEstimates).insert(estimate);
      }
      for (final entry in prepared.activityEntries) {
        await database.into(database.activityLogEntries).insert(entry);
      }
      for (final entry in prepared.wasteEntries) {
        await database.into(database.wasteLogEntries).insert(entry);
      }
      for (final trip in prepared.trips) {
        await database.into(database.plannedTrips).insert(trip);
      }
      for (final post in prepared.posts) {
        await database.into(database.communityJournalPosts).insert(post);
      }
      for (final progress in prepared.challengeProgress) {
        await database.into(database.challengeProgressRecords).insert(progress);
      }
      for (final completion in prepared.challengeCompletions) {
        await database
            .into(database.challengeDayCompletions)
            .insert(completion);
      }
      for (final preference in prepared.preferences) {
        await database
            .into(database.userPreferences)
            .insertOnConflictUpdate(preference);
      }
    });
  }
}

class PreparedUserDataImport {
  const PreparedUserDataImport._({
    required this.accounts,
    required this.estimates,
    required this.activityEntries,
    required this.wasteEntries,
    required this.trips,
    required this.posts,
    required this.challengeProgress,
    required this.challengeCompletions,
    required this.preferences,
  });

  final List<LocalAccountsCompanion> accounts;
  final List<FootprintEstimatesCompanion> estimates;
  final List<ActivityLogEntriesCompanion> activityEntries;
  final List<WasteLogEntriesCompanion> wasteEntries;
  final List<PlannedTripsCompanion> trips;
  final List<CommunityJournalPostsCompanion> posts;
  final List<ChallengeProgressRecordsCompanion> challengeProgress;
  final List<ChallengeDayCompletionsCompanion> challengeCompletions;
  final List<UserPreferencesCompanion> preferences;
}

List<LocalAccountsCompanion> _parseAccounts(Object? value) {
  final rows = _list(value, 'userData.accounts');
  final parsed = <LocalAccountsCompanion>[];
  final identifiers = <String>{};
  for (var index = 0; index < rows.length; index++) {
    final path = 'userData.accounts[$index]';
    final row = _object(rows[index], path);
    _requireKeys(row, const {
      'accountId',
      'loginIdentifier',
      'createdAt',
    }, path);
    final accountId = _string(row['accountId'], '$path.accountId');
    final identifier = _string(row['loginIdentifier'], '$path.loginIdentifier');
    if (identifier.isEmpty || identifier.length > 320) {
      throw FormatException('$path.loginIdentifier is invalid.');
    }
    if (!identifiers.add(identifier)) {
      throw const FormatException('Duplicate login identifiers in export.');
    }
    parsed.add(
      LocalAccountsCompanion.insert(
        accountId: accountId,
        loginIdentifier: identifier,
        createdAt: _date(row['createdAt'], '$path.createdAt'),
      ),
    );
  }
  return parsed;
}

List<FootprintEstimatesCompanion> _parseEstimates(Object? value) {
  final rows = _list(value, 'userData.footprintEstimates');
  final parsed = <FootprintEstimatesCompanion>[];
  final ids = <String>{};
  for (var index = 0; index < rows.length; index++) {
    final path = 'userData.footprintEstimates[$index]';
    final row = _object(rows[index], path);
    _requireKeys(row, const {
      'estimateId',
      'ownerAccountId',
      'createdAt',
      'periodStart',
      'periodEnd',
      'answers',
      'estimateValue',
      'unit',
      'questionnaireVersion',
      'completionState',
      'assumptions',
    }, path);
    final id = _string(row['estimateId'], '$path.estimateId');
    if (!ids.add(id)) throw const FormatException('Duplicate estimate IDs.');
    final state = _string(row['completionState'], '$path.completionState');
    if (state != 'complete' && state != 'incomplete') {
      throw FormatException('$path.completionState is invalid.');
    }
    final answers = _object(row['answers'], '$path.answers');
    final assumptions = _stringList(row['assumptions'], '$path.assumptions');
    parsed.add(
      FootprintEstimatesCompanion.insert(
        estimateId: id,
        ownerAccountId: Value(
          _nullableString(row['ownerAccountId'], '$path.ownerAccountId'),
        ),
        createdAt: _date(row['createdAt'], '$path.createdAt'),
        periodStart: _date(row['periodStart'], '$path.periodStart'),
        periodEnd: _date(row['periodEnd'], '$path.periodEnd'),
        answers: jsonEncode(answers),
        estimateValue: _nonnegativeNumber(
          row['estimateValue'],
          '$path.estimateValue',
        ),
        unit: _string(row['unit'], '$path.unit'),
        questionnaireVersion: _string(
          row['questionnaireVersion'],
          '$path.questionnaireVersion',
        ),
        completionState: state,
        assumptions: jsonEncode(assumptions),
      ),
    );
  }
  return parsed;
}

List<ActivityLogEntriesCompanion> _parseActivityEntries(Object? value) {
  final rows = _list(value, 'userData.activityLogEntries');
  final parsed = <ActivityLogEntriesCompanion>[];
  final ids = <String>{};
  for (var index = 0; index < rows.length; index++) {
    final path = 'userData.activityLogEntries[$index]';
    final row = _object(rows[index], path);
    _requireKeys(row, const {
      'activityId',
      'activityDate',
      'createdAt',
      'category',
      'amount',
      'unit',
      'emissionsKg',
      'regionId',
      'factorId',
    }, path);
    final id = _string(row['activityId'], '$path.activityId');
    if (!ids.add(id)) throw const FormatException('Duplicate activity IDs.');
    parsed.add(
      ActivityLogEntriesCompanion.insert(
        activityId: id,
        activityDate: _date(row['activityDate'], '$path.activityDate'),
        createdAt: _date(row['createdAt'], '$path.createdAt'),
        category: _string(row['category'], '$path.category'),
        amount: _nonnegativeNumber(row['amount'], '$path.amount'),
        unit: _string(row['unit'], '$path.unit'),
        emissionsKg: _nonnegativeNumber(
          row['emissionsKg'],
          '$path.emissionsKg',
        ),
        regionId: _string(row['regionId'], '$path.regionId'),
        factorId: _string(row['factorId'], '$path.factorId'),
      ),
    );
  }
  return parsed;
}

List<WasteLogEntriesCompanion> _parseWasteEntries(Object? value) {
  final rows = _list(value, 'userData.wasteLogEntries');
  final parsed = <WasteLogEntriesCompanion>[];
  final ids = <String>{};
  for (var index = 0; index < rows.length; index++) {
    final path = 'userData.wasteLogEntries[$index]';
    final row = _object(rows[index], path);
    _requireKeys(row, const {
      'entryId',
      'wasteDate',
      'createdAt',
      'category',
      'amountKg',
    }, path);
    final id = _string(row['entryId'], '$path.entryId');
    if (!ids.add(id)) throw const FormatException('Duplicate waste entry IDs.');
    final category = _string(row['category'], '$path.category');
    if (!const {
      'Plastic',
      'Paper & cardboard',
      'Glass',
      'Metal',
      'Organic',
      'Other',
    }.contains(category)) {
      throw FormatException('$path.category is invalid.');
    }
    parsed.add(
      WasteLogEntriesCompanion.insert(
        entryId: id,
        wasteDate: _date(row['wasteDate'], '$path.wasteDate'),
        createdAt: _date(row['createdAt'], '$path.createdAt'),
        category: category,
        amountKg: _positiveNumber(row['amountKg'], '$path.amountKg'),
      ),
    );
  }
  return parsed;
}

List<PlannedTripsCompanion> _parseTrips(Object? value) {
  final rows = _list(value, 'userData.travelTrips');
  final parsed = <PlannedTripsCompanion>[];
  final ids = <String>{};
  for (var index = 0; index < rows.length; index++) {
    final path = 'userData.travelTrips[$index]';
    final row = _object(rows[index], path);
    _requireKeys(row, const {
      'tripId',
      'title',
      'destination',
      'transportMode',
      'tripDate',
      'notes',
      'createdAt',
    }, path);
    final id = _string(row['tripId'], '$path.tripId');
    if (!ids.add(id)) throw const FormatException('Duplicate trip IDs.');
    parsed.add(
      PlannedTripsCompanion.insert(
        tripId: id,
        title: _string(row['title'], '$path.title'),
        destination: _string(row['destination'], '$path.destination'),
        transportMode: _string(row['transportMode'], '$path.transportMode'),
        tripDate: Value(_nullableDate(row['tripDate'], '$path.tripDate')),
        notes: Value(_nullableString(row['notes'], '$path.notes')),
        createdAt: _date(row['createdAt'], '$path.createdAt'),
      ),
    );
  }
  return parsed;
}

List<CommunityJournalPostsCompanion> _parsePosts(Object? value) {
  final rows = _list(value, 'userData.communityPosts');
  final parsed = <CommunityJournalPostsCompanion>[];
  final ids = <String>{};
  for (var index = 0; index < rows.length; index++) {
    final path = 'userData.communityPosts[$index]';
    final row = _object(rows[index], path);
    _requireKeys(row, const {'postId', 'title', 'body', 'createdAt'}, path);
    final id = _string(row['postId'], '$path.postId');
    if (!ids.add(id)) {
      throw const FormatException('Duplicate journal post IDs.');
    }
    parsed.add(
      CommunityJournalPostsCompanion.insert(
        postId: id,
        title: _string(row['title'], '$path.title'),
        body: _string(row['body'], '$path.body'),
        createdAt: _date(row['createdAt'], '$path.createdAt'),
      ),
    );
  }
  return parsed;
}

_ChallengeData _parseChallengeProgress(Object? value) {
  final rows = _list(value, 'userData.challengeProgress');
  final progress = <ChallengeProgressRecordsCompanion>[];
  final completions = <ChallengeDayCompletionsCompanion>[];
  final challengeIds = <String>{};
  for (var index = 0; index < rows.length; index++) {
    final path = 'userData.challengeProgress[$index]';
    final row = _object(rows[index], path);
    _requireKeys(row, const {
      'challengeId',
      'startedAt',
      'completedDays',
    }, path);
    final id = _string(row['challengeId'], '$path.challengeId');
    if (!challengeIds.add(id)) {
      throw const FormatException('Duplicate challenge progress records.');
    }
    progress.add(
      ChallengeProgressRecordsCompanion.insert(
        challengeId: id,
        startedAt: _date(row['startedAt'], '$path.startedAt'),
      ),
    );
    final days = _list(row['completedDays'], '$path.completedDays');
    final completedDayNumbers = <int>{};
    for (var dayIndex = 0; dayIndex < days.length; dayIndex++) {
      final dayPath = '$path.completedDays[$dayIndex]';
      final day = _object(days[dayIndex], dayPath);
      _requireKeys(day, const {'dayNumber', 'completedAt'}, dayPath);
      final dayNumber = day['dayNumber'];
      if (dayNumber is! int || dayNumber < 1) {
        throw FormatException('$dayPath.dayNumber is invalid.');
      }
      if (!completedDayNumbers.add(dayNumber)) {
        throw FormatException('$dayPath has a duplicate day number.');
      }
      completions.add(
        ChallengeDayCompletionsCompanion.insert(
          challengeId: id,
          dayNumber: dayNumber,
          completedAt: _date(day['completedAt'], '$dayPath.completedAt'),
        ),
      );
    }
  }
  return _ChallengeData(progress: progress, completions: completions);
}

List<UserPreferencesCompanion> _parsePreferences(Object? value) {
  final rows = _list(value, 'userData.preferences');
  if (rows.length != 1) {
    throw const FormatException(
      'The export must contain exactly one preferences record.',
    );
  }
  const path = 'userData.preferences[0]';
  final row = _object(rows.single, path);
  _requireKeys(row, const {
    'displayLanguageTag',
    'selectedRegionId',
    'reducedMotion',
    'recyclingCollectionDay',
    'compostDay',
    'updatedAt',
  }, path);
  return [
    UserPreferencesCompanion.insert(
      preferenceId: const Value(1),
      displayLanguageTag: Value(
        _string(row['displayLanguageTag'], '$path.displayLanguageTag'),
      ),
      selectedRegionId: Value(
        _nullableString(row['selectedRegionId'], '$path.selectedRegionId'),
      ),
      reducedMotion: Value(
        _nullableBool(row['reducedMotion'], '$path.reducedMotion'),
      ),
      recyclingCollectionDay: Value(
        _nullableWeekday(
          row['recyclingCollectionDay'],
          '$path.recyclingCollectionDay',
        ),
      ),
      compostDay: Value(
        _nullableWeekday(row['compostDay'], '$path.compostDay'),
      ),
      updatedAt: _date(row['updatedAt'], '$path.updatedAt'),
    ),
  ];
}

Map<String, dynamic> _object(Object? value, String path) {
  if (value is! Map || value.keys.any((key) => key is! String)) {
    throw FormatException('$path must be an object with string keys.');
  }
  return Map<String, dynamic>.from(value);
}

void _requireKeys(
  Map<String, dynamic> value,
  Set<String> expected,
  String path,
) {
  if (value.length != expected.length ||
      expected.any((key) => !value.containsKey(key))) {
    throw FormatException('$path does not match the supported export shape.');
  }
}

List<dynamic> _list(Object? value, String path) {
  if (value is! List) throw FormatException('$path must be an array.');
  return value;
}

String _string(Object? value, String path) {
  if (value is! String) throw FormatException('$path must be a string.');
  return value;
}

String? _nullableString(Object? value, String path) {
  if (value == null) return null;
  return _string(value, path);
}

bool? _nullableBool(Object? value, String path) {
  if (value == null) return null;
  if (value is! bool) throw FormatException('$path must be a boolean or null.');
  return value;
}

DateTime _date(Object? value, String path) {
  final encoded = _string(value, path);
  final date = DateTime.tryParse(encoded);
  if (date == null || date.toUtc().toIso8601String() != encoded) {
    throw FormatException('$path must be a UTC ISO-8601 timestamp.');
  }
  return date;
}

DateTime? _nullableDate(Object? value, String path) {
  if (value == null) return null;
  return _date(value, path);
}

double _nonnegativeNumber(Object? value, String path) {
  if (value is! num || !value.isFinite || value < 0) {
    throw FormatException('$path must be a finite nonnegative number.');
  }
  return value.toDouble();
}

double _positiveNumber(Object? value, String path) {
  final number = _nonnegativeNumber(value, path);
  if (number == 0) throw FormatException('$path must be positive.');
  return number;
}

int? _nullableWeekday(Object? value, String path) {
  if (value == null) return null;
  if (value is! int || value < DateTime.monday || value > DateTime.sunday) {
    throw FormatException('$path must be a weekday or null.');
  }
  return value;
}

List<String> _stringList(Object? value, String path) {
  final rows = _list(value, path);
  for (var index = 0; index < rows.length; index++) {
    if (rows[index] is! String) {
      throw FormatException('$path[$index] must be a string.');
    }
  }
  return rows.cast<String>();
}

class _ChallengeData {
  const _ChallengeData({required this.progress, required this.completions});

  final List<ChallengeProgressRecordsCompanion> progress;
  final List<ChallengeDayCompletionsCompanion> completions;
}
