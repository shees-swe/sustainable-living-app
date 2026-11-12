import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/accessibility/reduced_motion.dart';
import '../../../core/data/database/app_database.dart';
import '../../../core/motion/motion_spec.dart';
import '../../../core/motion/numeric_tick.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/activity_log_repository.dart';
import '../domain/activity_log_insights.dart';
import '../../onboarding/presentation/estimate_factor_disclosure.dart';

class ActivityLogInsightsScreen extends StatelessWidget {
  const ActivityLogInsightsScreen({
    required this.year,
    this.repository,
    super.key,
  });

  final int year;
  final ActivityLogRepository? repository;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final verdant = Theme.of(context).extension<VerdantColors>()!;
    final entries = repository?.watchEntries();
    return Scaffold(
      backgroundColor: verdant.cream,
      appBar: AppBar(
        backgroundColor: verdant.forestGreen,
        foregroundColor: Colors.white,
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(
          l10n.trackerInsights,
          maxLines: 2,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: StreamBuilder<List<ActivityLogEntry>>(
        stream: entries,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(l10n.trackerLoadFailure));
          }
          if (entries != null &&
              snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final insights = ActivityLogInsights.fromEntries(
            entries: snapshot.data ?? const <ActivityLogEntry>[],
            year: year,
          );
          return _ActivityLogInsightsBody(insights: insights);
        },
      ),
    );
  }
}

class _ActivityLogInsightsBody extends StatelessWidget {
  const _ActivityLogInsightsBody({required this.insights});

  final ActivityLogInsights insights;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final verdant = Theme.of(context).extension<VerdantColors>()!;
    final typography = Theme.of(context).extension<ClimateTypography>()!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Coverage info
        Container(
          decoration: BoxDecoration(
            color: verdant.forestLight,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            border: Border.all(
              color: verdant.forestGreen.withValues(alpha: 0.2),
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: verdant.forestGreen),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.trackerInsightsCoverage,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: verdant.forestDeep,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (insights.isEmpty) ...[
          const SizedBox(height: 16),
          Container(
            decoration: DesignTokens.sectionCard(context),
            padding: const EdgeInsets.all(24),
            child: Center(child: Text(l10n.trackerNoActivities)),
          ),
        ] else ...[
          const SizedBox(height: 16),
          // Hero Total
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [verdant.forestGreen, verdant.forestDeep],
              ),
              borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MonoNumericText(
                  text: l10n.trackerInsightsYear(insights.year),
                ),
                const SizedBox(height: 8),
                NumericTick(
                  value: insights.yearTotalKg,
                  decimalPlaces: 2,
                  style: Theme.of(context).textTheme.displayLarge!
                      .merge(typography.number)
                      .copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                  suffix: ' kg CO2',
                  suffixStyle: Theme.of(context).textTheme.titleMedium!
                      .merge(typography.unit)
                      .copyWith(color: Colors.white.withValues(alpha: 0.8)),
                  textKey: const ValueKey('trackerInsightsYearTotal'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Monthly Totals Card
          Container(
            decoration: DesignTokens.sectionCard(context),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.trackerMonthlyTotals,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: verdant.forestGreen,
                  ),
                ),
                const SizedBox(height: 12),
                for (final month in insights.months) ...[
                  _MonthlyActivityBar(month: month),
                  if (month != insights.months.last)
                    const Divider(height: 1),
                ],
                if (insights.highestMonth != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: verdant.amberLight,
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusSmall,
                      ),
                      border: Border.all(
                        color: verdant.amber.withValues(alpha: 0.3),
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          size: 18,
                          color: verdant.amber,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: MonoNumericText(
                            text: l10n.trackerHighestMonth(
                              DateFormat.MMMM(l10n.localeName).format(
                                DateTime(
                                  insights.year,
                                  insights.highestMonth!,
                                ),
                              ),
                              insights.highestMonthKg.toStringAsFixed(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Largest Contributions Card
          Container(
            decoration: DesignTokens.sectionCard(context),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.trackerLargestContributions,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: verdant.forestGreen,
                  ),
                ),
                const SizedBox(height: 8),
                for (
                  var index = 0;
                  index < insights.topContributions.length;
                  index++
                ) ...[
                  _ActivityContribution(
                    entry: insights.topContributions[index],
                  ),
                  if (index < insights.topContributions.length - 1)
                    const Divider(height: 1),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _MonthlyActivityBar extends StatelessWidget {
  const _MonthlyActivityBar({required this.month});

  final MonthlyActivityTotal month;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final verdant = Theme.of(context).extension<VerdantColors>()!;
    final monthName = DateFormat.MMMM(l10n.localeName)
        .format(DateTime(2000, month.month));
    final share = month.share;
    final shareText = share == null
        ? l10n.trackerShareUnavailable
        : l10n.trackerShareOfYear((share * 100).toStringAsFixed(1));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ClimateSpacing.space8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: ClimateSpacing.space16,
            runSpacing: ClimateSpacing.space8,
            children: [
              Text(
                monthName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              MonoNumericText(text: '${month.kg.toStringAsFixed(2)} kg CO2'),
              MonoNumericText(text: shareText),
            ],
          ),
          const SizedBox(height: ClimateSpacing.space8),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: share ?? 0),
            duration: ReducedMotion.duration(context, MotionSpec.optionalFade),
            curve: MotionSpec.optionalFadeCurve,
            builder: (context, value, _) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                key: ValueKey('trackerMonthBar-${month.month}'),
                value: value,
                minHeight: 8,
                backgroundColor: verdant.forestLight,
                color: verdant.amber,
                semanticsLabel: '$monthName, $shareText',
                semanticsValue: ((share ?? 0) * 100).toStringAsFixed(1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityContribution extends StatelessWidget {
  const _ActivityContribution({required this.entry});

  final ActivityLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final date = DateFormat.yMMMd(l10n.localeName).format(entry.activityDate);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ClimateSpacing.space8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonoNumericText(text: date),
          const SizedBox(height: ClimateSpacing.space4),
          MonoNumericText(
            text:
                '${entry.amount.toStringAsFixed(2)} kWh · '
                '${entry.emissionsKg.toStringAsFixed(3)} kg CO2',
          ),
        ],
      ),
    );
  }
}
