import 'dart:convert';

import '../../../core/data/database/app_database.dart';

class UserDataExporter {
  factory UserDataExporter({
    required AppDatabase database,
    DateTime Function()? clock,
  }) => UserDataExporter._(database, clock);

  UserDataExporter._(this._database, DateTime Function()? clock)
    : _clock = clock ?? DateTime.now;

  static const int exportSchemaVersion = 3;

  final AppDatabase _database;
  final DateTime Function() _clock;

  Future<Map<String, Object?>> exportData() async {
    final createdAt = _clock().toUtc();
    return _database.readConsistentSnapshot(() async {
      final accounts = await _database.select(_database.localAccounts).get();
      final estimates = await _database
          .select(_database.footprintEstimates)
          .get();
      final activityLogEntries = await _database
          .select(_database.activityLogEntries)
          .get();
      final challengeProgressRecords = await _database
          .select(_database.challengeProgressRecords)
          .get();
      final challengeDayCompletions = await _database
          .select(_database.challengeDayCompletions)
          .get();
      final preferences = await _database
          .select(_database.userPreferences)
          .get();

      return {
        'exportSchemaVersion': exportSchemaVersion,
        'createdAt': createdAt.toIso8601String(),
        'userData': {
          'accounts': [
            for (final account in accounts)
              {
                'accountId': account.accountId,
                'loginIdentifier': account.loginIdentifier,
                'createdAt': account.createdAt.toUtc().toIso8601String(),
              },
          ],
          'footprintEstimates': [
            for (final estimate in estimates)
              {
                'estimateId': estimate.estimateId,
                'ownerAccountId': estimate.ownerAccountId,
                'createdAt': estimate.createdAt.toUtc().toIso8601String(),
                'periodStart': estimate.periodStart.toUtc().toIso8601String(),
                'periodEnd': estimate.periodEnd.toUtc().toIso8601String(),
                'answers': _decodeAnswers(estimate.answers),
                'estimateValue': estimate.estimateValue,
                'unit': estimate.unit,
                'questionnaireVersion': estimate.questionnaireVersion,
                'completionState': estimate.completionState,
                'assumptions': _decodeAssumptions(estimate.assumptions),
              },
          ],
          'activityLogEntries': [
            for (final entry in activityLogEntries)
              {
                'activityId': entry.activityId,
                'activityDate': entry.activityDate.toUtc().toIso8601String(),
                'createdAt': entry.createdAt.toUtc().toIso8601String(),
                'category': entry.category,
                'amount': entry.amount,
                'unit': entry.unit,
                'emissionsKg': entry.emissionsKg,
                'regionId': entry.regionId,
                'factorId': entry.factorId,
              },
          ],
          'challengeProgress': [
            for (final progress in challengeProgressRecords)
              {
                'challengeId': progress.challengeId,
                'startedAt': progress.startedAt.toUtc().toIso8601String(),
                'completedDays': [
                  for (final completion in challengeDayCompletions)
                    if (completion.challengeId == progress.challengeId)
                      {
                        'dayNumber': completion.dayNumber,
                        'completedAt': completion.completedAt
                            .toUtc()
                            .toIso8601String(),
                      },
                ],
              },
          ],
          'preferences': [
            for (final preference in preferences)
              {
                'displayLanguageTag': preference.displayLanguageTag,
                'selectedRegionId': preference.selectedRegionId,
                'reducedMotion': preference.reducedMotion,
                'updatedAt': preference.updatedAt.toUtc().toIso8601String(),
              },
          ],
        },
      };
    });
  }

  Map<String, Object?> _decodeAnswers(String encoded) {
    final decoded = jsonDecode(encoded);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Stored estimate answers must be a JSON object.',
      );
    }
    return decoded;
  }

  List<String> _decodeAssumptions(String encoded) {
    final decoded = jsonDecode(encoded);
    if (decoded is! List<dynamic> ||
        decoded.any((assumption) => assumption is! String)) {
      throw const FormatException(
        'Stored estimate assumptions must be a JSON string array.',
      );
    }
    return decoded.cast<String>();
  }
}
