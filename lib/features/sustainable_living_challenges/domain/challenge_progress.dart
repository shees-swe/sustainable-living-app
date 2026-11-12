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

  double fractionFor(int totalDays) {
    if (totalDays < 1) {
      throw ArgumentError.value(totalDays, 'totalDays', 'Must be positive.');
    }
    return completedDayCount / totalDays;
  }

  bool isCompleteFor(int totalDays) => completedDays.length == totalDays;
}
