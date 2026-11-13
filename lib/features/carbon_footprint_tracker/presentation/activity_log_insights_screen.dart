import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/accessibility/reduced_motion.dart';
import '../../../core/data/database/app_database.dart';
import '../../../core/motion/motion_spec.dart';
import '../../../core/motion/numeric_tick.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/design_components.dart';
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
    final entries = repository?.watchEntries();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(l10n.trackerInsights, maxLines: 2),
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
    final typography = Theme.of(context).extension<ClimateTypography>()!;
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: ClimateSpacing.space16,
        vertical: ClimateSpacing.space16,
      ),
      children: [
        if (insights.isEmpty) ...[
          AppPanel(
            color: DesignTokens.surfaceBlue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppIconBadge(
                  icon: Icons.insights_outlined,
                  backgroundColor: DesignTokens.surface,
                  foregroundColor: DesignTokens.blue,
                ),
                const SizedBox(height: DesignTokens.space16),
                Text(l10n.trackerInsightsCoverage),
                const SizedBox(height: DesignTokens.space16),
                Text(l10n.trackerNoActivities),
              ],
            ),
          ),
        ] else ...[
          AppPanel(
            color: DesignTokens.surfaceBlue,
            padding: const EdgeInsets.all(DesignTokens.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.trackerInsightsCoverage),
                const SizedBox(height: DesignTokens.space16),
                MonoNumericText(text: l10n.trackerInsightsYear(insights.year)),
                const SizedBox(height: DesignTokens.space8),
                NumericTick(
                  value: insights.yearTotalKg,
                  decimalPlaces: 2,
                  style: Theme.of(context).textTheme.displayLarge!
                      .merge(typography.number),
                  suffix: ' kg CO2',
                  suffixStyle: Theme.of(context).textTheme.titleMedium!
                      .merge(typography.unit),
                  textKey: const ValueKey('trackerInsightsYearTotal'),
                ),
              ],
            ),
          ),
          const SizedBox(height: ClimateSpacing.space24),
          AppPanel(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(DesignTokens.space16),
                  child: AppSectionHeading(title: l10n.trackerMonthlyTotals),
                ),
                for (var index = 0; index < insights.months.length; index++)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.space16,
                    ),
                    child: Column(
                      children: [
                        _MonthlyActivityBar(month: insights.months[index]),
                        if (index < insights.months.length - 1)
                          const Divider(height: 1),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: ClimateSpacing.space24),
          AppPanel(
            color: DesignTokens.surfaceSun,
            child: MonoNumericText(
              text: l10n.trackerHighestMonth(
                DateFormat.MMMM(l10n.localeName)
                    .format(DateTime(insights.year, insights.highestMonth!)),
                insights.highestMonthKg.toStringAsFixed(2),
              ),
            ),
          ),
          if (insights.topContributions.isNotEmpty) ...[
            const SizedBox(height: ClimateSpacing.space24),
            AppPanel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(DesignTokens.space16),
                    child: AppSectionHeading(
                      title: l10n.trackerLargestContributions,
                    ),
                  ),
                  for (
                    var index = 0;
                    index < insights.topContributions.length;
                    index++
                  ) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.space16,
                      ),
                      child: _ActivityContribution(
                        entry: insights.topContributions[index],
                      ),
                    ),
                    if (index < insights.topContributions.length - 1)
                      const Divider(height: 1),
                  ],
                ],
              ),
            ),
          ],
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
              Text(monthName),
              MonoNumericText(text: '${month.kg.toStringAsFixed(2)} kg CO2'),
              MonoNumericText(text: shareText),
            ],
          ),
          const SizedBox(height: ClimateSpacing.space8),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: share ?? 0),
            duration: ReducedMotion.duration(context, MotionSpec.optionalFade),
            curve: MotionSpec.optionalFadeCurve,
            builder: (context, value, _) => LinearProgressIndicator(
              key: ValueKey('trackerMonthBar-${month.month}'),
              value: value,
              minHeight: 8,
              backgroundColor: DesignTokens.surfaceMuted,
              color: ClimateColors.emissions,
              semanticsLabel: '$monthName, $shareText',
              semanticsValue: ((share ?? 0) * 100).toStringAsFixed(1),
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
          const SizedBox(height: ClimateSpacing.space8),
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
