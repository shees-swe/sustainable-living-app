import 'package:drift/drift.dart';

import '../../../core/data/database/app_database.dart';
import '../domain/challenge_progress.dart';

class ChallengeProgressRepository {
  ChallengeProgressRepository({
    required this.database,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase database;
  final DateTime Function() _clock;

  Stream<List<ChallengeProgress>> watchProgress() =>
      _progressQuery().watch().map(_mapRows);

  Future<List<ChallengeProgress>> readProgress() async =>
      _mapRows(await _progressQuery().get());

  Future<ChallengeProgress?> readChallengeProgress(String challengeId) async {
    for (final progress in await readProgress()) {
      if (progress.challengeId == challengeId) return progress;
    }
    return null;
  }

  Future<void> startChallenge(String challengeId) async {
    _requireChallengeId(challengeId);
    await database
        .into(database.challengeProgressRecords)
        .insert(
          ChallengeProgressRecordsCompanion.insert(
            challengeId: challengeId,
            startedAt: _clock().toUtc(),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> setDayCompleted({
    required String challengeId,
    required int totalDays,
    required int dayNumber,
    required bool completed,
  }) async {
    _requireChallengeId(challengeId);
    if (totalDays < 1 || dayNumber < 1 || dayNumber > totalDays) {
      throw ArgumentError(
        'Day number must be between 1 and the challenge duration.',
      );
    }

    await database.transaction(() async {
      final progress = await (database.select(
        database.challengeProgressRecords,
      )..where((row) => row.challengeId.equals(challengeId))).getSingleOrNull();
      if (progress == null) {
        throw StateError('Start the challenge before marking a day complete.');
      }

      final mark = database.challengeDayCompletions;
      final whereDay =
          (mark.challengeId.equals(challengeId) &
          mark.dayNumber.equals(dayNumber));
      if (completed) {
        await database
            .into(mark)
            .insert(
              ChallengeDayCompletionsCompanion.insert(
                challengeId: challengeId,
                dayNumber: dayNumber,
                completedAt: _clock().toUtc(),
              ),
              mode: InsertMode.insertOrIgnore,
            );
      } else {
        await (database.delete(mark)..where((row) => whereDay)).go();
      }
    });
  }

  Future<void> resetChallenge(String challengeId) async {
    _requireChallengeId(challengeId);
    await (database.delete(
      database.challengeProgressRecords,
    )..where((row) => row.challengeId.equals(challengeId))).go();
  }

  JoinedSelectStatement<HasResultSet, dynamic> _progressQuery() {
    final query = database.select(database.challengeProgressRecords).join([
      leftOuterJoin(
        database.challengeDayCompletions,
        database.challengeDayCompletions.challengeId.equalsExp(
          database.challengeProgressRecords.challengeId,
        ),
      ),
    ]);
    query.orderBy([
      OrderingTerm.asc(database.challengeProgressRecords.challengeId),
      OrderingTerm.asc(database.challengeDayCompletions.dayNumber),
    ]);
    return query;
  }

  List<ChallengeProgress> _mapRows(List<TypedResult> rows) {
    final values = <String, _ProgressAccumulator>{};
    for (final row in rows) {
      final record = row.readTable(database.challengeProgressRecords);
      final completion = row.readTableOrNull(database.challengeDayCompletions);
      final progress = values.putIfAbsent(
        record.challengeId,
        () => _ProgressAccumulator(record.startedAt),
      );
      if (completion != null) progress.completedDays.add(completion.dayNumber);
    }
    return [
      for (final entry in values.entries)
        ChallengeProgress(
          challengeId: entry.key,
          startedAt: entry.value.startedAt,
          completedDays: Set.unmodifiable(entry.value.completedDays),
        ),
    ];
  }
}

class _ProgressAccumulator {
  _ProgressAccumulator(this.startedAt);

  final DateTime startedAt;
  final Set<int> completedDays = {};
}

void _requireChallengeId(String challengeId) {
  if (challengeId.trim().isEmpty) {
    throw ArgumentError.value(challengeId, 'challengeId', 'Must not be empty.');
  }
}
