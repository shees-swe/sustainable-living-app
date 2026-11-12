import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sustainable_living_app/core/data/database/app_database.dart';
import 'package:sustainable_living_app/features/sustainable_living_challenges/data/challenge_progress_repository.dart';

void main() {
  late AppDatabase database;
  late ChallengeProgressRepository repository;
  late DateTime now;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    now = DateTime(2026, 1, 1);
    repository = ChallengeProgressRepository(
      database: database,
      clock: () => now,
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
    now = DateTime(2026, 1, 8);
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

  test('day two toggles without changing day one', () async {
    await repository.startChallenge('plastic-free-week');
    now = DateTime(2026, 1, 8);
    await repository.setDayCompleted(
      challengeId: 'plastic-free-week',
      totalDays: 7,
      dayNumber: 1,
      completed: true,
    );
    await repository.setDayCompleted(
      challengeId: 'plastic-free-week',
      totalDays: 7,
      dayNumber: 2,
      completed: true,
    );

    var progress = (await repository.readChallengeProgress(
      'plastic-free-week',
    ))!;
    expect(progress.completedDays, {1, 2});

    await repository.setDayCompleted(
      challengeId: 'plastic-free-week',
      totalDays: 7,
      dayNumber: 2,
      completed: false,
    );
    progress = (await repository.readChallengeProgress('plastic-free-week'))!;
    expect(progress.completedDays, {1});
    expect(progress.completedDayCount, 1);

    await repository.setDayCompleted(
      challengeId: 'plastic-free-week',
      totalDays: 7,
      dayNumber: 2,
      completed: true,
    );
    progress = (await repository.readChallengeProgress('plastic-free-week'))!;
    expect(progress.completedDays, {1, 2});
    expect(progress.completedDayCount, 2);
  });

  test('joined today unlocks only day one', () async {
    await repository.startChallenge('plastic-free-week');

    expect(
      repository.isDayUnlocked(
        (await repository.readChallengeProgress('plastic-free-week'))!,
        1,
      ),
      isTrue,
    );
    expect(
      repository.isDayUnlocked(
        (await repository.readChallengeProgress('plastic-free-week'))!,
        2,
      ),
      isFalse,
    );

    await repository.setDayCompleted(
      challengeId: 'plastic-free-week',
      totalDays: 7,
      dayNumber: 2,
      completed: true,
    );
    var progress = (await repository.readChallengeProgress(
      'plastic-free-week',
    ))!;
    expect(progress.completedDays, isEmpty);

    await repository.setDayCompleted(
      challengeId: 'plastic-free-week',
      totalDays: 7,
      dayNumber: 1,
      completed: true,
    );
    progress = (await repository.readChallengeProgress('plastic-free-week'))!;
    expect(progress.completedDays, {1});
  });

  test('three whole calendar days unlock days one through four', () async {
    now = DateTime(2026, 1, 1, 23, 59);
    await repository.startChallenge('plastic-free-week');
    now = DateTime(2026, 1, 4, 0, 1);

    final progress = (await repository.readChallengeProgress(
      'plastic-free-week',
    ))!;
    for (var dayNumber = 1; dayNumber <= 4; dayNumber++) {
      expect(repository.isDayUnlocked(progress, dayNumber), isTrue);
      await repository.setDayCompleted(
        challengeId: 'plastic-free-week',
        totalDays: 7,
        dayNumber: dayNumber,
        completed: true,
      );
    }
    expect(repository.isDayUnlocked(progress, 5), isFalse);
    await repository.setDayCompleted(
      challengeId: 'plastic-free-week',
      totalDays: 7,
      dayNumber: 5,
      completed: true,
    );

    final updated = (await repository.readChallengeProgress(
      'plastic-free-week',
    ))!;
    expect(updated.completedDays, {1, 2, 3, 4});
    expect(updated.completedDayCount, 4);
    expect(updated.fractionFor(7), 4 / 7);
  });

  test('pre-existing future-day progress remains unchanged', () async {
    await database
        .into(database.challengeProgressRecords)
        .insert(
          ChallengeProgressRecordsCompanion.insert(
            challengeId: 'plastic-free-week',
            startedAt: now.toUtc(),
          ),
        );
    await database
        .into(database.challengeDayCompletions)
        .insert(
          ChallengeDayCompletionsCompanion.insert(
            challengeId: 'plastic-free-week',
            dayNumber: 7,
            completedAt: now.toUtc(),
          ),
        );

    final before = (await repository.readChallengeProgress(
      'plastic-free-week',
    ))!;
    await repository.setDayCompleted(
      challengeId: 'plastic-free-week',
      totalDays: 7,
      dayNumber: 6,
      completed: true,
    );

    final after = (await repository.readChallengeProgress(
      'plastic-free-week',
    ))!;
    expect(after.completedDays, before.completedDays);
    expect(after.completedDayCount, before.completedDayCount);
    expect(after.fractionFor(7), before.fractionFor(7));
    expect(after.completedDays, {7});
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
    now = DateTime(2026, 1, 8);
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
    now = DateTime(2026, 1, 8);
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
