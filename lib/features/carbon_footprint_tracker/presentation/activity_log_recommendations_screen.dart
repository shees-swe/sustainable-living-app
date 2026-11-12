import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/data/database/app_database.dart';
import '../../../core/data/regions/foundation_references.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../onboarding/domain/footprint_estimate.dart';
import '../../onboarding/presentation/estimate_factor_disclosure.dart';
import '../data/activity_log_repository.dart';
import '../domain/activity_log_recommendations.dart';

class ActivityLogRecommendationsScreen extends StatefulWidget {
  const ActivityLogRecommendationsScreen({
    required this.year,
    required this.factors,
    this.references,
    this.repository,
    super.key,
  });

  final int year;
  final List<EmissionFactor> factors;
  final FoundationReferences? references;
  final ActivityLogRepository? repository;

  @override
  State<ActivityLogRecommendationsScreen> createState() =>
      _ActivityLogRecommendationsScreenState();
}

class _ActivityLogRecommendationsScreenState
    extends State<ActivityLogRecommendationsScreen> {
  late final Future<FoundationReferences> _references;

  @override
  void initState() {
    super.initState();
    _references = widget.references == null
        ? FoundationReferences.loadBundled()
        : Future.value(widget.references);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final verdant = Theme.of(context).extension<VerdantColors>()!;
    final entries = widget.repository?.watchEntries();
    return Scaffold(
      backgroundColor: verdant.cream,
      appBar: AppBar(
        backgroundColor: verdant.forestGreen,
        foregroundColor: Colors.white,
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(
          l10n.trackerRecommendations,
          maxLines: 2,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: FutureBuilder<FoundationReferences>(
        future: _references,
        builder: (context, referenceSnapshot) {
          if (referenceSnapshot.hasError) {
            return Center(
              child: Text(
                '${l10n.trackerLoadFailure}\n${referenceSnapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }
          final references = referenceSnapshot.data;
          if (references == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return StreamBuilder<List<ActivityLogEntry>>(
            stream: entries,
            builder: (context, entrySnapshot) {
              if (entrySnapshot.hasError) {
                return Center(child: Text(l10n.trackerLoadFailure));
              }
              if (entries != null &&
                  entrySnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final recommendations = ActivityLogRecommendations.fromEntries(
                entries: entrySnapshot.data ?? const <ActivityLogEntry>[],
                year: widget.year,
                factors: widget.factors,
                references: references,
              );
              return _ActivityLogRecommendationsBody(
                recommendations: recommendations,
                references: references,
              );
            },
          );
        },
      ),
    );
  }
}

class _ActivityLogRecommendationsBody extends StatelessWidget {
  const _ActivityLogRecommendationsBody({
    required this.recommendations,
    required this.references,
  });

  final ActivityLogRecommendations recommendations;
  final FoundationReferences references;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final verdant = Theme.of(context).extension<VerdantColors>()!;
    final numberStyle = Theme.of(context)
        .extension<ClimateTypography>()!
        .number;
    final monthName = recommendations.peakMonth == null
        ? ''
        : DateFormat.MMMM(
            l10n.localeName,
          ).format(DateTime(recommendations.year, recommendations.peakMonth!));
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Coverage Card
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
                  l10n.trackerRecommendationsCoverage,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: verdant.forestDeep,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (recommendations.isEmpty) ...[
          const SizedBox(height: 16),
          Container(
            decoration: DesignTokens.sectionCard(context),
            padding: const EdgeInsets.all(24),
            child: Center(child: Text(l10n.trackerNoActivities)),
          ),
        ] else ...[
          const SizedBox(height: 16),
          // Actionable Recommendation Scenario Card
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
                Text(
                  l10n.trackerRecommendationScenarioLabel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.trackerRecommendationPeakMonth(monthName),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(color: Colors.white),
                    children: [
                      TextSpan(text: l10n.trackerRecommendationCutPrefix),
                      TextSpan(
                        text: '10',
                        style: numberStyle.copyWith(color: Colors.white),
                      ),
                      TextSpan(
                        text: l10n.trackerRecommendationCutSuffix(monthName),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      DesignTokens.radiusSmall,
                    ),
                  ),
                  child: MonoNumericText(
                    text:
                        '${recommendations.scenarioSavingsKg!.toStringAsFixed(2)} '
                        'kg CO2',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Metrics Card
          if (recommendations.averageMonthKg case final average?) ...[
            Container(
              decoration: DesignTokens.sectionCard(context),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RecommendationMetric(
                    label: l10n.trackerRecommendationAverageMonth,
                    value: '${average.toStringAsFixed(2)} kg CO2',
                  ),
                  const Divider(height: 1),
                  _RecommendationMetric(
                    label: l10n.trackerRecommendationLowestMonth(
                      DateFormat.MMMM(l10n.localeName).format(
                        DateTime(
                          recommendations.year,
                          recommendations.lowestMonth!,
                        ),
                      ),
                    ),
                    value:
                        '${recommendations.lowestMonthKg!.toStringAsFixed(2)} '
                        'kg CO2',
                  ),
                  const Divider(height: 1),
                  _RecommendationMetric(
                    label: l10n.trackerRecommendationMonthlyGap,
                    value:
                        '${recommendations.monthlyGapKg!.toStringAsFixed(2)} '
                        'kg CO2',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Budget Comparison Card
          if (recommendations.budgetShare case final share?) ...[
            Container(
              decoration: DesignTokens.sectionCard(context),
              padding: const EdgeInsets.all(16),
              child: _BudgetRecommendation(
                share: share,
                references: references,
                numberStyle: numberStyle,
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _RecommendationMetric extends StatelessWidget {
  const _RecommendationMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: ClimateSpacing.space12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label)),
        MonoNumericText(text: value),
      ],
    ),
  );
}

class _BudgetRecommendation extends StatelessWidget {
  const _BudgetRecommendation({
    required this.share,
    required this.references,
    required this.numberStyle,
  });

  final double share;
  final FoundationReferences references;
  final TextStyle numberStyle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final verdant = Theme.of(context).extension<VerdantColors>()!;
    final benchmark = references.temperatureBudget;
    final source = references.sources[benchmark.reference.sourceId]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.flag_rounded, color: verdant.forestGreen, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.budgetShareTitle,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: verdant.forestGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: l10n.trackerRecommendationBudgetPrefix),
              TextSpan(
                text: (share * 100).toStringAsFixed(1),
                style: numberStyle,
              ),
              TextSpan(text: l10n.trackerRecommendationBudgetMiddle),
              TextSpan(
                text: benchmark.reference.value.toStringAsFixed(1),
                style: numberStyle,
              ),
              TextSpan(text: l10n.trackerRecommendationBudgetSuffix),
              TextSpan(
                text: benchmark.targetYear.toString(),
                style: numberStyle,
              ),
              TextSpan(text: l10n.trackerRecommendationBudgetEnd),
            ],
          ),
        ),
        const SizedBox(height: 8),
        MonoNumericText(
          text:
              '${source.title} · ${source.publisher} '
              '(${source.publicationYear})',
        ),
      ],
    );
  }
}
