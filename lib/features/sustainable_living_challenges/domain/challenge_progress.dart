class ChallengeProgress {
  const ChallengeProgress({
    required this.challengeId,
    required this.startedAt,
    required this.completedDays,
  });

  final String challengeId;
  final DateTime startedAt;
  final Set<int> completedDays;

  int get completedDayCount => completedDays.length;

  bool isDayUnlocked(int dayNumber, DateTime now) {
    return isDayUnlockedFrom(
      startedAt: startedAt,
      dayNumber: dayNumber,
      now: now,
    );
  }

  static bool isDayUnlockedFrom({
    required DateTime startedAt,
    required int dayNumber,
    required DateTime now,
  }) {
    if (dayNumber < 1) {
      throw ArgumentError.value(dayNumber, 'dayNumber', 'Must be positive.');
    }

    final joinedAt = startedAt.toLocal();
    final today = now.toLocal();
    final elapsedCalendarDays = DateTime.utc(today.year, today.month, today.day)
        .difference(DateTime.utc(joinedAt.year, joinedAt.month, joinedAt.day))
        .inDays;
    return elapsedCalendarDays >= dayNumber - 1;
  }

  double fractionFor(int totalDays) {
    if (totalDays < 1) {
      throw ArgumentError.value(totalDays, 'totalDays', 'Must be positive.');
    }
    return completedDayCount / totalDays;
  }

  bool isCompleteFor(int totalDays) => completedDays.length == totalDays;
}
