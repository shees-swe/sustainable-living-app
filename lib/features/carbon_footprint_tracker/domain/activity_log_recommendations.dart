import '../../../core/data/database/app_database.dart';
import '../../../core/data/regions/foundation_references.dart';
import '../../onboarding/domain/footprint_estimate.dart';
import '../../onboarding/domain/lifestyle_budget_share.dart';
import 'activity_log_insights.dart';

class ActivityLogRecommendations {
  const ActivityLogRecommendations({
    required this.year,
    required this.yearTotalKg,
    required this.peakMonth,
    required this.peakMonthKg,
    required this.scenarioSavingsKg,
    required this.averageMonthKg,
    required this.lowestMonth,
    required this.lowestMonthKg,
    required this.monthlyGapKg,
    required this.budgetShare,
  });

  factory ActivityLogRecommendations.fromEntries({
    required Iterable<ActivityLogEntry> entries,
    required int year,
    required List<EmissionFactor> factors,
    required FoundationReferences references,
  }) {
    final yearEntries = entries
        .where(
          (entry) =>
              entry.category == 'electricity' &&
              entry.activityDate.year == year,
        )
        .toList(growable: false);
    final insights = ActivityLogInsights.fromEntries(
      entries: yearEntries,
      year: year,
    );
    final yearTotalCents = insights.yearTotalCents;
    final yearTotalKg = yearTotalCents / 100;
    final monthlyCents = {
      for (final month in insights.months) month.month: month.kgCents,
    };
    final months = monthlyCents.keys.toList()..sort();
    if (months.isEmpty) {
      return ActivityLogRecommendations(
        year: year,
        yearTotalKg: 0,
        peakMonth: null,
        peakMonthKg: null,
        scenarioSavingsKg: null,
        averageMonthKg: null,
        lowestMonth: null,
        lowestMonthKg: null,
        monthlyGapKg: null,
        budgetShare: null,
      );
    }

    var peakMonth = months.first;
    var lowestMonth = months.first;
    for (final month in months.skip(1)) {
      if (monthlyCents[month]! > monthlyCents[peakMonth]!) {
        peakMonth = month;
      }
      if (monthlyCents[month]! < monthlyCents[lowestMonth]!) {
        lowestMonth = month;
      }
    }

    final peakMonthCents = monthlyCents[peakMonth]!;
    final peakMonthKg = peakMonthCents / 100;
    final averageMonthCents = months.length < 2
        ? null
        : (yearTotalCents / months.length).round();
    final lowestMonthCents = months.length < 2
        ? null
        : monthlyCents[lowestMonth]!;
    final averageMonthKg = averageMonthCents == null
        ? null
        : averageMonthCents / 100;
    final lowestMonthKg = lowestMonthCents == null
        ? null
        : lowestMonthCents / 100;
    final benchmark = references.temperatureBudget;
    final budgetShare =
        _hasCompatibleLoggedFactors(yearEntries, factors) &&
            references.sources.containsKey(benchmark.reference.sourceId)
        ? lifestyleBudgetShare(
            referenceId: benchmark.reference.referenceId,
            referenceValue: benchmark.reference.value,
            referenceUnit: benchmark.reference.unit,
            referencePeriod: benchmark.reference.period,
            targetYear: benchmark.targetYear,
            estimateValue: yearTotalKg,
            estimateUnit: 'kg CO2e/year',
            assumptions: const ['annualizedPerPerson'],
          )
        : null;

    return ActivityLogRecommendations(
      year: year,
      yearTotalKg: yearTotalKg,
      peakMonth: peakMonth,
      peakMonthKg: peakMonthKg,
      scenarioSavingsKg: ((peakMonthCents + 5) ~/ 10) / 100,
      averageMonthKg: averageMonthKg,
      lowestMonth: lowestMonthKg == null ? null : lowestMonth,
      lowestMonthKg: lowestMonthKg,
      monthlyGapKg: averageMonthCents == null || lowestMonthCents == null
          ? null
          : (averageMonthCents - lowestMonthCents) / 100,
      budgetShare: budgetShare,
    );
  }

  final int year;
  final double yearTotalKg;
  final int? peakMonth;
  final double? peakMonthKg;
  final double? scenarioSavingsKg;
  final double? averageMonthKg;
  final int? lowestMonth;
  final double? lowestMonthKg;
  final double? monthlyGapKg;
  final double? budgetShare;

  bool get isEmpty => peakMonth == null;
}

bool _hasCompatibleLoggedFactors(
  List<ActivityLogEntry> entries,
  List<EmissionFactor> factors,
) {
  if (entries.isEmpty) return false;
  for (final entry in entries) {
    if (entry.unit != 'kWh') return false;
    final matches = factors
        .where((factor) => factor.factorId == entry.factorId)
        .toList(growable: false);
    if (matches.length != 1) return false;
    final factor = matches.single;
    if (factor.category != 'electricity' ||
        factor.activityId != 'electricity' ||
        factor.denominatorUnit != 'kWh' ||
        !const {'kg CO2', 'kg CO2e'}.contains(factor.numeratorUnit)) {
      return false;
    }
  }
  // Logged CO2 is numerically equivalent in CO2e; electricity is reported as
  // a lower bound because the remaining lifestyle categories are excluded.
  return true;
}
