import 'dart:math';

import 'package:drift/drift.dart';

import '../../../core/data/database/app_database.dart';
import '../../onboarding/domain/footprint_calculator.dart';
import '../../onboarding/domain/footprint_estimate.dart';

class ActivityLogRepository {
  ActivityLogRepository({
    required this.database,
    this.calculator = const FootprintCalculator(),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase database;
  final FootprintCalculator calculator;
  final DateTime Function() _clock;

  Stream<List<ActivityLogEntry>> watchEntries() =>
      (database.select(database.activityLogEntries)..orderBy([
            (entry) => OrderingTerm.desc(entry.activityDate),
            (entry) => OrderingTerm.desc(entry.createdAt),
          ]))
          .watch();

  Future<void> addElectricity({
    required DateTime date,
    required double amountKwh,
    required String regionId,
    required List<EmissionFactor> factors,
  }) async {
    if (!amountKwh.isFinite || amountKwh < 0) {
      throw const InvalidEstimateInput(
        'Activity amount must be finite and nonnegative.',
      );
    }

    final estimate = calculator.calculate(
      answers: FootprintAnswers(
        questionnaireVersion: 'activity-log-v1',
        periodYear: date.year,
        regionId: regionId,
        activities: [
          ActivityInput(
            activityId: 'electricity',
            amount: amountKwh,
            unit: 'kWh',
          ),
        ],
      ),
      factors: factors,
    );
    if (estimate is! CompleteEstimate) {
      throw StateError('The electricity activity could not be calculated.');
    }

    await database
        .into(database.activityLogEntries)
        .insert(
          ActivityLogEntriesCompanion.insert(
            activityId: _newActivityId(),
            activityDate: DateTime(date.year, date.month, date.day),
            createdAt: _clock().toUtc(),
            category: 'electricity',
            amount: amountKwh,
            unit: 'kWh',
            emissionsKg: estimate.value,
            regionId: regionId,
            factorId: estimate.factorsUsed.single.factorId,
          ),
        );
  }

  Future<void> deleteEntry(String activityId) async {
    await (database.delete(
      database.activityLogEntries,
    )..where((entry) => entry.activityId.equals(activityId))).go();
  }

  String _newActivityId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final value = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0'));
    final hex = value.join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}
