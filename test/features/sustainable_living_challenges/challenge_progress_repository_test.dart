import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/features/sustainable_living_challenges/data/challenge_progress_repository.dart';

void main() {
  late AppDatabase database;
  late ChallengeProgressRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = ChallengeProgressRepository(
      database: database,
      clock: () => DateTime.utc(2026, 1, 1),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'starting a challenge creates a record with zero completed days',
    () async {
      await repository.startChallenge('plastic-free-week');

      final progress = await repository.readChallengeProgress(
        'plastic-free-week',
      );
      expect(progress, isNotNull);
      expect(progress!.completedDayCount, 0);
      expect(progress.completedDays, isEmpty);
    },
  );

  test('marking and unmarking days updates the exact progress', () async {
    await repository.startChallenge('plastic-free-week');
    await repository.setDayCompleted(
      challengeId: 'plastic-free-week',
      totalDays: 7,
      dayNumber: 2,
      completed: true,
    );
    await repository.setDayCompleted(
      challengeId: 'plastic-free-week',
      totalDays: 7,
      dayNumber: 5,
      completed: true,
    );

    var progress = (await repository.readChallengeProgress(
      'plastic-free-week',
    ))!;
    expect(progress.completedDayCount, 2);
    expect(progress.completedDays, {2, 5});
    expect(progress.fractionFor(7), 2 / 7);

    await repository.setDayCompleted(
      challengeId: 'plastic-free-week',
      totalDays: 7,
      dayNumber: 2,
      completed: false,
    );
    progress = (await repository.readChallengeProgress('plastic-free-week'))!;
    expect(progress.completedDayCount, 1);
    expect(progress.completedDays, {5});
    expect(progress.fractionFor(7), 1 / 7);
  });

  test('progress survives closing and reopening the database', () async {
    final directory = await Directory.systemTemp.createTemp(
      'challenge-progress-test-',
    );
    final databasePath = p.join(directory.path, 'challenges.sqlite');
    var persistentDatabase = AppDatabase.forTesting(
      NativeDatabase(File(databasePath)),
    );
    addTearDown(() async {
      await persistentDatabase.close();
      await directory.delete(recursive: true);
    });

    var persistentRepository = ChallengeProgressRepository(
      database: persistentDatabase,
    );
    await persistentRepository.startChallenge('grow-a-plant');
    await persistentRepository.setDayCompleted(
      challengeId: 'grow-a-plant',
      totalDays: 30,
      dayNumber: 1,
      completed: true,
    );
    await persistentDatabase.close();

    persistentDatabase = AppDatabase.forTesting(
      NativeDatabase(File(databasePath)),
    );
    persistentRepository = ChallengeProgressRepository(
      database: persistentDatabase,
    );
    final progress = await persistentRepository.readChallengeProgress(
      'grow-a-plant',
    );
    expect(progress, isNotNull);
    expect(progress!.completedDays, {1});
  });

  test('reset clears the record and all marked days', () async {
    await repository.startChallenge('plastic-free-week');
    await repository.setDayCompleted(
      challengeId: 'plastic-free-week',
      totalDays: 7,
      dayNumber: 1,
      completed: true,
    );

    await repository.resetChallenge('plastic-free-week');

    expect(await repository.readChallengeProgress('plastic-free-week'), isNull);
    expect(
      await database.select(database.challengeDayCompletions).get(),
      isEmpty,
    );
  });

  test('all marked days define completion without inferred progress', () async {
    await repository.startChallenge('five-minute-showers');
    for (var day = 1; day <= 7; day++) {
      await repository.setDayCompleted(
        challengeId: 'five-minute-showers',
        totalDays: 7,
        dayNumber: day,
        completed: true,
      );
    }

    final progress = (await repository.readChallengeProgress(
      'five-minute-showers',
    ))!;
    expect(progress.completedDayCount, 7);
    expect(progress.isCompleteFor(7), isTrue);
  });

  test('active challenges keep independent day marks', () async {
    await repository.startChallenge('plastic-free-week');
    await repository.startChallenge('grow-a-plant');
    await repository.setDayCompleted(
      challengeId: 'plastic-free-week',
      totalDays: 7,
      dayNumber: 1,
      completed: true,
    );
    await repository.setDayCompleted(
      challengeId: 'grow-a-plant',
      totalDays: 30,
      dayNumber: 2,
      completed: true,
    );

    final progress = {
      for (final item in await repository.readProgress())
        item.challengeId: item,
    };
    expect(progress['plastic-free-week']!.completedDays, {1});
    expect(progress['grow-a-plant']!.completedDays, {2});
  });
}
