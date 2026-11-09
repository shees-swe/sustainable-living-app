import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

import '../../../core/data/database/app_database.dart';
import '../domain/footprint_calculator.dart';
import '../domain/footprint_estimate.dart';

class FootprintEstimateRepository {
  FootprintEstimateRepository({
    required this.database,
    this.calculator = const FootprintCalculator(),
  });

  final AppDatabase database;
  final FootprintCalculator calculator;

  Future<void> saveCompleteEstimate({
    required FootprintAnswers answers,
    required CompleteEstimate estimate,
  }) async {
    if (estimate.questionnaireVersion != answers.questionnaireVersion ||
        estimate.periodYear != answers.periodYear) {
      throw ArgumentError(
        'Estimate metadata must match its versioned answers.',
      );
    }

    await database.saveEstimate(
      FootprintEstimatesCompanion.insert(
        estimateId: _newEstimateId(),
        createdAt: DateTime.now().toUtc(),
        periodStart: DateTime.utc(answers.periodYear),
        periodEnd: DateTime.utc(answers.periodYear, 12, 31),
        answers: jsonEncode(answers.toJson()),
        estimateValue: estimate.value,
        unit: estimate.unit,
        questionnaireVersion: answers.questionnaireVersion,
        completionState: estimate.completionState.name,
        assumptions: jsonEncode(estimate.assumptions),
      ),
    );
  }

  Future<CompleteEstimate?> loadLatestCompleteEstimate({
    required List<EmissionFactor> factors,
    String? expectedRegionId,
  }) async {
    final rows =
        await (database.select(database.footprintEstimates)
              ..where((row) => row.completionState.equals('complete'))
              ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]))
            .get();
    if (rows.isEmpty) return null;

    final row = rows.first;
    final answers = _decodeAnswers(row.answers);
    if (expectedRegionId != null &&
        (answers.regionId ?? 'demo-region') != expectedRegionId) {
      return null;
    }
    if (answers.questionnaireVersion != row.questionnaireVersion ||
        row.periodStart.year != answers.periodYear ||
        row.periodEnd.year != answers.periodYear) {
      throw const FormatException(
        'Stored estimate metadata does not match its versioned answers.',
      );
    }
    final result = calculator.calculate(answers: answers, factors: factors);
    if (result is! CompleteEstimate ||
        result.value != row.estimateValue ||
        result.unit != row.unit) {
      throw const FormatException(
        'Stored estimate does not match the current calculation factors.',
      );
    }
    return result;
  }

  Future<String?> loadLatestEstimateRegionId() async {
    final row =
        await (database.select(database.footprintEstimates)
              ..where((row) => row.completionState.equals('complete'))
              ..orderBy([(row) => OrderingTerm.desc(row.createdAt)])
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return null;
    return _decodeAnswers(row.answers).regionId ?? 'demo-region';
  }

  FootprintAnswers _decodeAnswers(String encoded) {
    final decoded = jsonDecode(encoded);
    if (decoded is! Map<String, dynamic> ||
        decoded['questionnaireVersion'] is! String ||
        decoded['periodYear'] is! int ||
        decoded['activities'] is! List) {
      throw const FormatException('Stored estimate answers are invalid.');
    }

    final activities = <ActivityInput>[];
    for (final item in decoded['activities'] as List) {
      if (item is! Map<String, dynamic> ||
          item['activityId'] is! String ||
          item['unit'] is! String) {
        throw const FormatException('Stored activity answer is invalid.');
      }
      final rawAmount = item['amount'];
      if (rawAmount != null && rawAmount is! num) {
        throw const FormatException('Stored activity amount is invalid.');
      }
      activities.add(
        ActivityInput(
          activityId: item['activityId'] as String,
          amount: (rawAmount as num?)?.toDouble(),
          unit: item['unit'] as String,
        ),
      );
    }

    return FootprintAnswers(
      questionnaireVersion: decoded['questionnaireVersion'] as String,
      periodYear: decoded['periodYear'] as int,
      regionId: decoded['regionId'] as String?,
      activities: activities,
    );
  }

  String _newEstimateId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0'));
    final value = hex.join();
    return '${value.substring(0, 8)}-${value.substring(8, 12)}-'
        '${value.substring(12, 16)}-${value.substring(16, 20)}-'
        '${value.substring(20)}';
  }
}
