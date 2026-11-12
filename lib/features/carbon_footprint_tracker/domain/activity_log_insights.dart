import '../../../core/data/database/app_database.dart';

class ActivityLogInsights {
  const ActivityLogInsights({
    required this.year,
    required this.yearTotalKg,
    required this.yearTotalCents,
    required this.months,
    required this.highestMonth,
    required this.topContributions,
  });

  factory ActivityLogInsights.fromEntries({
    required Iterable<ActivityLogEntry> entries,
    required int year,
  }) {
    final yearEntries = entries
        .where(
          (entry) =>
              entry.category == 'electricity' &&
              entry.activityDate.year == year,
        )
        .toList(growable: false);
    final yearTotalKg = yearEntries.fold<double>(
      0,
      (total, entry) => total + entry.emissionsKg,
    );
    final yearTotalCents = (yearTotalKg * 100).round();
    final monthlyKg = <int, double>{};
    for (final entry in yearEntries) {
      monthlyKg.update(
        entry.activityDate.month,
        (total) => total + entry.emissionsKg,
        ifAbsent: () => entry.emissionsKg,
      );
    }

    final highestMonth = monthlyKg.keys.isEmpty
        ? null
        : monthlyKg.keys.reduce(
            (highest, candidate) => monthlyKg[candidate]! > monthlyKg[highest]!
                ? candidate
                : highest,
          );
    final monthlyCents = {
      for (final month in monthlyKg.keys)
        month: (monthlyKg[month]! * 100).round(),
    };
    if (highestMonth != null) {
      final roundedMonthlySum = monthlyCents.values.fold<int>(
        0,
        (total, cents) => total + cents,
      );
      monthlyCents[highestMonth] =
          monthlyCents[highestMonth]! + yearTotalCents - roundedMonthlySum;
    }

    final months = monthlyKg.keys.toList()..sort();
    final monthlyTotals = [
      for (final month in months)
        MonthlyActivityTotal(
          month: month,
          kgCents: monthlyCents[month]!,
          share: yearTotalKg == 0 ? null : monthlyKg[month]! / yearTotalKg,
        ),
    ];

    final topContributions = [...yearEntries]
      ..sort((first, second) {
        final emissionsOrder = second.emissionsKg.compareTo(first.emissionsKg);
        if (emissionsOrder != 0) return emissionsOrder;
        final dateOrder = second.activityDate.compareTo(first.activityDate);
        if (dateOrder != 0) return dateOrder;
        final createdOrder = second.createdAt.compareTo(first.createdAt);
        if (createdOrder != 0) return createdOrder;
        return first.activityId.compareTo(second.activityId);
      });

    return ActivityLogInsights(
      year: year,
      yearTotalKg: yearTotalKg,
      yearTotalCents: yearTotalCents,
      months: List.unmodifiable(monthlyTotals),
      highestMonth: highestMonth,
      topContributions: List.unmodifiable(topContributions.take(3)),
    );
  }

  final int year;
  final double yearTotalKg;
  final int yearTotalCents;
  final List<MonthlyActivityTotal> months;
  final int? highestMonth;
  final List<ActivityLogEntry> topContributions;

  bool get isEmpty => months.isEmpty;

  double get highestMonthKg =>
      months.singleWhere((total) => total.month == highestMonth).kg;
}

class MonthlyActivityTotal {
  const MonthlyActivityTotal({
    required this.month,
    required this.kgCents,
    required this.share,
  });

  final int month;
  final int kgCents;
  final double? share;

  double get kg => kgCents / 100;
}
