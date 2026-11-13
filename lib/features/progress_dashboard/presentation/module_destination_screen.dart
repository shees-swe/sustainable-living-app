import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/accessibility/motion_aware_progress_indicator.dart';
import '../../../core/data/database/app_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/design_components.dart';
import '../../../features/carbon_footprint_tracker/data/activity_log_repository.dart';
import '../../../features/carbon_footprint_tracker/domain/activity_log_insights.dart';
import '../../../features/community_journal/data/community_post_repository.dart';
import '../../../features/eco_travel_suggestions/data/travel_trip_repository.dart';
import '../../../features/sustainable_living_challenges/data/challenge_progress_repository.dart';
import '../../../features/sustainable_living_challenges/domain/challenge_progress.dart';
import '../../../features/waste_reduction_tracker/data/waste_log_repository.dart';
import '../../../features/waste_reduction_tracker/domain/waste_month_summary.dart';
import '../../../l10n/generated/app_localizations.dart';

class ProgressDashboardScreen extends StatefulWidget {
  const ProgressDashboardScreen({
    required this.activityLogRepository,
    required this.wasteLogRepository,
    required this.challengeProgressRepository,
    required this.travelTripRepository,
    required this.communityPostRepository,
    super.key,
  });

  final ActivityLogRepository activityLogRepository;
  final WasteLogRepository wasteLogRepository;
  final ChallengeProgressRepository challengeProgressRepository;
  final TravelTripRepository travelTripRepository;
  final CommunityPostRepository communityPostRepository;

  @override
  State<ProgressDashboardScreen> createState() =>
      _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState extends State<ProgressDashboardScreen> {
  late final Stream<List<ActivityLogEntry>> _activityStream = widget
      .activityLogRepository
      .watchEntries();
  late final Stream<List<WasteLogEntry>> _wasteStream = widget
      .wasteLogRepository
      .watchEntries();
  late final Stream<List<ChallengeProgress>> _challengeStream = widget
      .challengeProgressRepository
      .watchProgress();
  late final Stream<List<PlannedTrip>> _tripStream = widget.travelTripRepository
      .watchTrips();
  late final Stream<List<CommunityJournalPost>> _postStream = widget
      .communityPostRepository
      .watchPosts();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(l10n.progressDashboard, maxLines: 2),
      ),
      body: StreamBuilder<List<ActivityLogEntry>>(
        stream: _activityStream,
        builder: (context, activitySnapshot) {
          if (activitySnapshot.hasError) {
            return _LoadFailure(
              message: '${l10n.progressLoadFailure}\n${activitySnapshot.error}',
            );
          }
          final activities = activitySnapshot.data;
          if (activities == null) return _Loading(label: l10n.loading);
          return StreamBuilder<List<WasteLogEntry>>(
            stream: _wasteStream,
            builder: (context, wasteSnapshot) {
              if (wasteSnapshot.hasError) {
                return _LoadFailure(
                  message:
                      '${l10n.progressLoadFailure}\n${wasteSnapshot.error}',
                );
              }
              final wasteEntries = wasteSnapshot.data;
              if (wasteEntries == null) return _Loading(label: l10n.loading);
              return StreamBuilder<List<ChallengeProgress>>(
                stream: _challengeStream,
                builder: (context, challengeSnapshot) {
                  if (challengeSnapshot.hasError) {
                    return _LoadFailure(
                      message:
                          '${l10n.progressLoadFailure}\n${challengeSnapshot.error}',
                    );
                  }
                  final challenges = challengeSnapshot.data;
                  if (challenges == null) return _Loading(label: l10n.loading);
                  return StreamBuilder<List<PlannedTrip>>(
                    stream: _tripStream,
                    builder: (context, tripSnapshot) {
                      if (tripSnapshot.hasError) {
                        return _LoadFailure(
                          message:
                              '${l10n.progressLoadFailure}\n${tripSnapshot.error}',
                        );
                      }
                      final trips = tripSnapshot.data;
                      if (trips == null) return _Loading(label: l10n.loading);
                      return StreamBuilder<List<CommunityJournalPost>>(
                        stream: _postStream,
                        builder: (context, postSnapshot) {
                          if (postSnapshot.hasError) {
                            return _LoadFailure(
                              message:
                                  '${l10n.progressLoadFailure}\n${postSnapshot.error}',
                            );
                          }
                          final posts = postSnapshot.data;
                          if (posts == null) {
                            return _Loading(label: l10n.loading);
                          }
                          return _DashboardList(
                            activityEntries: activities,
                            wasteEntries: wasteEntries,
                            challenges: challenges,
                            trips: trips,
                            posts: posts,
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _DashboardList extends StatelessWidget {
  const _DashboardList({
    required this.activityEntries,
    required this.wasteEntries,
    required this.challenges,
    required this.trips,
    required this.posts,
  });

  final List<ActivityLogEntry> activityEntries;
  final List<WasteLogEntry> wasteEntries;
  final List<ChallengeProgress> challenges;
  final List<PlannedTrip> trips;
  final List<CommunityJournalPost> posts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final year = DateTime.now().year;
    final carbonInsights = ActivityLogInsights.fromEntries(
      entries: activityEntries,
      year: year,
    );
    final wasteMonths =
        wasteEntries
            .where((entry) => entry.wasteDate.year == year)
            .map((entry) => entry.wasteDate.month)
            .toSet()
            .toList()
          ..sort();
    final wasteTrend = [
      for (final month in wasteMonths)
        WasteMonthSummary.fromEntries(
          entries: wasteEntries,
          month: DateTime(year, month),
        ),
    ];
    final hasAnyData =
        activityEntries.isNotEmpty ||
        wasteEntries.isNotEmpty ||
        challenges.isNotEmpty ||
        trips.isNotEmpty ||
        posts.isNotEmpty;

    return ListView(
      key: const ValueKey('progressDashboardList'),
      padding: const EdgeInsets.symmetric(
        horizontal: ClimateSpacing.space16,
        vertical: ClimateSpacing.space16,
      ),
      children: [
        if (!hasAnyData) ...[
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
                Text(l10n.progressOverallEmpty),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.space16),
        ],
        _DashboardSection(
          title: l10n.progressCarbonTitle,
          color: DesignTokens.surfaceBlue,
          children: _carbonContent(context, l10n, year, carbonInsights),
        ),
        const SizedBox(height: DesignTokens.space16),
        _DashboardSection(
          title: l10n.progressWasteTitle,
          color: DesignTokens.surfaceSun,
          children: _wasteContent(context, l10n, year, wasteTrend),
        ),
        const SizedBox(height: DesignTokens.space16),
        _DashboardSection(
          title: l10n.progressChallengesTitle,
          color: DesignTokens.surfaceCoral,
          children: _challengeContent(context, l10n),
        ),
        const SizedBox(height: DesignTokens.space16),
        _DashboardSection(
          title: l10n.progressTravelTitle,
          color: DesignTokens.surfaceBlue,
          children: _countContent(
            l10n.progressTravelEmpty,
            l10n.progressTripsPlanned,
            trips.length,
            'progressTravelTripCount',
          ),
        ),
        const SizedBox(height: DesignTokens.space16),
        _DashboardSection(
          title: l10n.progressJournalTitle,
          color: DesignTokens.surfaceCoral,
          children: _countContent(
            l10n.progressJournalEmpty,
            l10n.progressPostsWritten,
            posts.length,
            'progressJournalPostCount',
          ),
        ),
        const SizedBox(height: DesignTokens.space16),
        AppPanel(
          color: DesignTokens.surfaceMuted,
          child: Text(l10n.progressPurchasesScope),
        ),
      ],
    );
  }

  List<Widget> _carbonContent(
    BuildContext context,
    AppLocalizations l10n,
    int year,
    ActivityLogInsights insights,
  ) {
    if (activityEntries.isEmpty) return [Text(l10n.progressCarbonEmpty)];
    final totalKg = activityEntries.fold<double>(
      0,
      (total, entry) => total + entry.emissionsKg,
    );
    final maxCents = insights.months.isEmpty
        ? 0
        : insights.months
              .map((month) => month.kgCents)
              .reduce((first, second) => first > second ? first : second);
    return [
      _Metric(
        label: l10n.progressCarbonTotal,
        value: '${totalKg.toStringAsFixed(2)} kg CO2e',
        valueKey: const ValueKey('progressCarbonAllTimeTotal'),
      ),
      const SizedBox(height: ClimateSpacing.space16),
      Text(
        l10n.progressMonthlyTrendThisYear,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      if (insights.months.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: ClimateSpacing.space8),
          child: Text(l10n.progressNoCurrentYearTrend),
        )
      else
        for (var index = 0; index < insights.months.length; index++) ...[
          if (index > 0) const Divider(height: 1),
          _MonthlyTrendRow(
            month: DateFormat.MMMM(l10n.localeName)
                .format(DateTime(year, insights.months[index].month)),
            kgCents: insights.months[index].kgCents,
            maxKgCents: maxCents,
            unit: 'kg CO2e',
            rowKey: ValueKey(
              'progressCarbonMonth-${insights.months[index].month}',
            ),
          ),
        ],
    ];
  }

  List<Widget> _wasteContent(
    BuildContext context,
    AppLocalizations l10n,
    int year,
    List<WasteMonthSummary> trend,
  ) {
    if (wasteEntries.isEmpty) return [Text(l10n.progressWasteEmpty)];
    final totalKg = wasteEntries.fold<double>(
      0,
      (total, entry) => total + entry.amountKg,
    );
    final maxCents = trend.isEmpty
        ? 0
        : trend
              .map((month) => month.totalKgCents)
              .reduce((first, second) => first > second ? first : second);
    return [
      _Metric(
        label: l10n.progressWasteTotal,
        value: '${totalKg.toStringAsFixed(2)} kg',
        valueKey: const ValueKey('progressWasteAllTimeTotal'),
      ),
      const SizedBox(height: ClimateSpacing.space16),
      Text(
        l10n.progressMonthlyTrendThisYear,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      if (trend.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: ClimateSpacing.space8),
          child: Text(l10n.progressNoCurrentYearTrend),
        )
      else
        for (var index = 0; index < trend.length; index++) ...[
          if (index > 0) const Divider(height: 1),
          _MonthlyTrendRow(
            month: DateFormat.MMMM(l10n.localeName)
                .format(DateTime(year, trend[index].month)),
            kgCents: trend[index].totalKgCents,
            maxKgCents: maxCents,
            unit: 'kg',
            rowKey: ValueKey('progressWasteMonth-${trend[index].month}'),
          ),
        ],
    ];
  }

  List<Widget> _challengeContent(BuildContext context, AppLocalizations l10n) {
    if (challenges.isEmpty) return [Text(l10n.progressChallengesEmpty)];
    final daysChecked = challenges.fold<int>(
      0,
      (total, progress) => total + progress.completedDayCount,
    );
    return [
      Wrap(
        spacing: ClimateSpacing.space24,
        runSpacing: ClimateSpacing.space16,
        children: [
          _Metric(
            label: l10n.progressChallengesJoined,
            value: '${challenges.length}',
            valueKey: const ValueKey('progressChallengeCount'),
          ),
          _Metric(
            label: l10n.progressDaysChecked,
            value: '$daysChecked',
            valueKey: const ValueKey('progressChallengeDaysChecked'),
          ),
        ],
      ),
    ];
  }

  List<Widget> _countContent(
    String emptyMessage,
    String label,
    int count,
    String valueKey,
  ) => [
    if (count == 0)
      Text(emptyMessage)
    else
      _Metric(label: label, value: '$count', valueKey: ValueKey(valueKey)),
  ];
}

class _DashboardSection extends StatelessWidget {
  const _DashboardSection({
    required this.title,
    required this.children,
    this.color,
  });

  final String title;
  final List<Widget> children;
  final Color? color;

  @override
  Widget build(BuildContext context) => AppPanel(
    color: color,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeading(title: title),
        const SizedBox(height: DesignTokens.space12),
        ...children,
      ],
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.valueKey,
  });

  final String label;
  final String value;
  final Key valueKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typography = theme.extension<ClimateTypography>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: ClimateColors.textSecondary,
          ),
        ),
        const SizedBox(height: ClimateSpacing.space8),
        Text(
          value,
          key: valueKey,
          style: theme.textTheme.titleLarge?.merge(typography.number),
        ),
      ],
    );
  }
}

class _MonthlyTrendRow extends StatelessWidget {
  const _MonthlyTrendRow({
    required this.month,
    required this.kgCents,
    required this.maxKgCents,
    required this.unit,
    required this.rowKey,
  });

  final String month;
  final int kgCents;
  final int maxKgCents;
  final String unit;
  final Key rowKey;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<ClimateTypography>()!;
    final amount = (kgCents / 100).toStringAsFixed(2);
    final ratio = maxKgCents <= 0
        ? 0.0
        : (kgCents / maxKgCents).clamp(0.0, 1.0).toDouble();
    return Padding(
      key: rowKey,
      padding: const EdgeInsets.symmetric(vertical: ClimateSpacing.space8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: ClimateSpacing.space16,
            runSpacing: ClimateSpacing.space8,
            children: [
              Text(month),
              Text('$amount $unit', style: typography.number),
            ],
          ),
          const SizedBox(height: ClimateSpacing.space8),
          Semantics(
            label: month,
            value: '$amount $unit',
            child: ExcludeSemantics(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: DesignTokens.surfaceMuted,
                  borderRadius: BorderRadius.circular(
                    ClimateSpacing.radiusSmall,
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 8,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FractionallySizedBox(
                      widthFactor: ratio,
                      heightFactor: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: ClimateColors.cobalt,
                          borderRadius: BorderRadius.circular(
                            ClimateSpacing.radiusSmall,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) =>
      Center(child: MotionAwareProgressIndicator(semanticsLabel: label));
}

class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(ClimateSpacing.space16),
      child: Text(message, textAlign: TextAlign.center),
    ),
  );
}
