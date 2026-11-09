import 'dart:convert';

import '../../../core/data/database/app_database.dart';

class UserDataExporter {
  factory UserDataExporter({
    required AppDatabase database,
    DateTime Function()? clock,
  }) => UserDataExporter._(database, clock);

  UserDataExporter._(this._database, DateTime Function()? clock)
    : _clock = clock ?? DateTime.now;

  static const int exportSchemaVersion = 1;

  final AppDatabase _database;
  final DateTime Function() _clock;

  Future<Map<String, Object?>> exportData() async {
    final createdAt = _clock().toUtc();
    return _database.readConsistentSnapshot(() async {
      final accounts = await _database.select(_database.localAccounts).get();
      final estimates = await _database
          .select(_database.footprintEstimates)
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
