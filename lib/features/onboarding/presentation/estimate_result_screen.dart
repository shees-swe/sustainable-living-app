import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/accessibility/motion_aware_progress_indicator.dart';
import '../../../core/data/regions/foundation_references.dart';
import '../../../core/data/regions/region_pack_parser.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/estimate_demo_fixtures.dart';
import '../data/footprint_estimate_repository.dart';
import '../domain/footprint_calculator.dart';
import '../domain/footprint_estimate.dart';
import '../domain/reference_comparison.dart';
import '../domain/reference_value.dart';
import 'comparison_rings.dart';

class EstimateResultScreen extends StatefulWidget {
  const EstimateResultScreen({
    required this.repository,
    this.onboardingData,
    this.regionalOnboardingData,
    this.selectedRegionPack,
    this.foundationReferences,
    this.demoRegion,
    super.key,
  });

  final FootprintEstimateRepository? repository;
  final OnboardingRouteData? onboardingData;
  final RegionalOnboardingRouteData? regionalOnboardingData;
  final RegionDataPack? selectedRegionPack;
  final FoundationReferences? foundationReferences;
  final EstimateDemoRegion? demoRegion;

  @override
  State<EstimateResultScreen> createState() => _EstimateResultScreenState();
}

class _EstimateResultScreenState extends State<EstimateResultScreen> {
  late final Future<_EstimateResultData> _result = _loadResult();

  Future<_EstimateResultData> _loadResult() async {
    final region = _resolveRegion();
    final repository = widget.repository;
    final CompleteEstimate estimate;
    final routeAnswers =
        widget.onboardingData?.answers ??
        widget.regionalOnboardingData?.answers;

    if (routeAnswers case final answers?) {
      if (answers.regionId != null && answers.regionId != region.regionId) {
        throw const FormatException(
          'Estimate answers do not match the selected region.',
        );
      }
      final result = const FootprintCalculator().calculate(
        answers: answers,
        factors: region.factors,
      );
      if (result is! CompleteEstimate) {
        throw const FormatException(
          'Incomplete answers cannot produce a result.',
        );
      }
      if (repository == null) {
        throw StateError('Estimate persistence is unavailable.');
      }
      await repository.saveCompleteEstimate(answers: answers, estimate: result);
      estimate = result;
    } else {
      if (repository == null) {
        throw StateError('Estimate persistence is unavailable.');
      }
      final restored = await repository.loadLatestCompleteEstimate(
        factors: region.factors,
        expectedRegionId: region.regionId,
      );
      if (restored == null) {
        throw StateError(
          'No saved guest estimate is available for this region.',
        );
      }
      estimate = restored;
    }

    final basis = EstimateComparisonBasis(
      value: estimate.value,
      unit: estimate.unit,
      period: estimate.periodYear.toString(),
      accountingBoundary: region.accountingBoundary,
    );
    final comparisonService = const ReferenceComparisonService();
    return _EstimateResultData(
      region: region,
      estimate: estimate,
      comparisons: region.references
          .map(
            (reference) => _NamedComparison(
              reference: reference,
              source: reference.sourceId == null
                  ? null
                  : region.sources[reference.sourceId],
              comparison: comparisonService.compare(
                estimate: basis,
                reference: reference,
                sources: region.sources,
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  _EstimateRegion _resolveRegion() {
    if (widget.onboardingData case final routeData?) {
      return _EstimateRegion.fromDemo(routeData.region);
    }
    if (widget.regionalOnboardingData case final routeData?) {
      return _EstimateRegion.fromPack(routeData.region, routeData.references);
    }
    if (widget.selectedRegionPack case final pack?) {
      final references = widget.foundationReferences;
      if (references == null) {
        throw StateError('Foundation references are unavailable.');
      }
      return _EstimateRegion.fromPack(pack, references);
    }
    return _EstimateRegion.fromDemo(
      widget.demoRegion ?? foundationEstimateDemoRegions.single,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.estimateResult)),
      body: FutureBuilder<_EstimateResultData>(
        future: _result,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.space4),
                child: Text(
                  '${l10n.estimateLoadFailure}\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final data = snapshot.data;
          if (data == null) {
            return Center(
              child: MotionAwareProgressIndicator(semanticsLabel: l10n.loading),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(DesignTokens.space4),
            children: [
              if (data.region.demoOnly)
                Semantics(
                  liveRegion: true,
                  child: Text(
                    l10n.demoOnlyWarning,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                )
              else
                Text(l10n.regionalEstimateContext),
              const SizedBox(height: DesignTokens.space2),
              Text(
                _regionLabel(l10n, data.region.labelKey),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (data.region.currencyCode != null)
                Text(l10n.regionCurrency(data.region.currencyCode!)),
              const SizedBox(height: DesignTokens.space2),
              Text(
                l10n.estimateAnnualValue(
                  data.estimate.displayValue,
                  data.estimate.unit,
                ),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: DesignTokens.space3),
              for (final item in data.comparisons)
                ComparisonRing(
                  label: _referenceLabel(l10n, item.reference.referenceId),
                  estimate: data.estimate,
                  comparison: item.comparison,
                  contextualReference: item.reference,
                  contextualSource: item.source,
                ),
              const SizedBox(height: DesignTokens.space3),
              CalculationFactorDisclosure(factors: data.estimate.factorsUsed),
              const SizedBox(height: DesignTokens.space2),
              for (final assumption in data.estimate.assumptions)
                Text(_assumptionLabel(l10n, assumption)),
              const SizedBox(height: DesignTokens.space3),
              FilledButton(
                onPressed: () => context.go(AppRoutes.home),
                child: Text(l10n.continueToHome),
              ),
            ],
          );
        },
      ),
    );
  }

  String _referenceLabel(AppLocalizations l10n, String referenceId) =>
      switch (referenceId) {
        'regional-average' => l10n.regionalAverage,
        'global-average' => l10n.globalAverage,
        'temperature-budget-1-5c' => l10n.temperatureBudget,
        _ => throw ArgumentError.value(
          referenceId,
          'referenceId',
          'Unknown estimate reference',
        ),
      };

  String _regionLabel(AppLocalizations l10n, String labelKey) =>
      switch (labelKey) {
        'regionDemoOnly' => l10n.regionDemoOnly,
        'regionPakistan' => l10n.regionPakistan,
        _ => throw ArgumentError.value(
          labelKey,
          'labelKey',
          'Unknown estimate region label',
        ),
      };

  String _assumptionLabel(AppLocalizations l10n, String assumption) =>
      switch (assumption) {
        'annualizedPerPerson' => l10n.assumptionAnnualizedPerPerson,
        _ => throw ArgumentError.value(
          assumption,
          'assumption',
          'Unknown estimate assumption',
        ),
      };
}

class _EstimateResultData {
  const _EstimateResultData({
    required this.region,
    required this.estimate,
    required this.comparisons,
  });

  final _EstimateRegion region;
  final CompleteEstimate estimate;
  final List<_NamedComparison> comparisons;
}

class _EstimateRegion {
  const _EstimateRegion({
    required this.regionId,
    required this.labelKey,
    required this.accountingBoundary,
    required this.factors,
    required this.references,
    required this.sources,
    required this.demoOnly,
    this.currencyCode,
  });

  factory _EstimateRegion.fromDemo(EstimateDemoRegion region) =>
      _EstimateRegion(
        regionId: region.regionId,
        labelKey: region.labelKey,
        accountingBoundary: region.accountingBoundary,
        factors: region.factors,
        references: region.references,
        sources: {region.source.sourceId: region.source},
        demoOnly: region.demoOnly,
      );

  factory _EstimateRegion.fromPack(
    RegionDataPack pack,
    FoundationReferences foundationReferences,
  ) {
    final sources = <String, ReferenceSource>{
      for (final source in pack.sources.values)
        source.sourceId: ReferenceSource(
          sourceId: source.sourceId,
          title: source.title,
          publisher: source.publisher,
          publicationYear: source.publicationYear,
          url: source.url,
        ),
      for (final source in foundationReferences.sources.values)
        source.sourceId: ReferenceSource(
          sourceId: source.sourceId,
          title: source.title,
          publisher: source.publisher,
          publicationYear: source.publicationYear,
          url: source.url,
          reportVersion: source.reportVersion,
        ),
    };
    final regionalAverage = pack.regionalAverage;
    final globalAverage = foundationReferences.globalAverage;
    final target = foundationReferences.temperatureBudget.reference;
    return _EstimateRegion(
      regionId: pack.region.regionId,
      labelKey: pack.region.nameKey,
      accountingBoundary:
          'Annual household footprint per person using ${pack.region.regionId} regional pack factors.',
      factors: emissionFactorsFromRegionPack(pack),
      references: [
        ReferenceValue(
          referenceId: 'regional-average',
          value: regionalAverage.value,
          unit: regionalAverage.unit,
          period: regionalAverage.period,
          sourceId: regionalAverage.sourceId,
          methodology: regionalAverage.methodology,
          accountingBoundary: regionalAverage.accountingBoundary,
          uncertainty: regionalAverage.uncertainty,
        ),
        ReferenceValue(
          referenceId: globalAverage.referenceId,
          value: globalAverage.value,
          unit: globalAverage.unit,
          period: globalAverage.period,
          sourceId: globalAverage.sourceId,
          methodology: globalAverage.methodology,
          accountingBoundary: globalAverage.accountingBoundary,
          uncertainty: globalAverage.uncertainty,
        ),
        ReferenceValue(
          referenceId: target.referenceId,
          value: target.value,
          unit: target.unit,
          period: target.period,
          sourceId: target.sourceId,
          methodology: target.methodology,
          accountingBoundary: target.accountingBoundary,
          uncertainty: target.uncertainty,
        ),
      ],
      sources: sources,
      demoOnly: false,
      currencyCode: pack.region.currencyCode,
    );
  }

  final String regionId;
  final String labelKey;
  final String accountingBoundary;
  final List<EmissionFactor> factors;
  final List<ReferenceValue> references;
  final Map<String, ReferenceSource> sources;
  final bool demoOnly;
  final String? currencyCode;
}

class _NamedComparison {
  const _NamedComparison({
    required this.reference,
    required this.comparison,
    required this.source,
  });

  final ReferenceValue reference;
  final ReferenceComparisonResult comparison;
  final ReferenceSource? source;
}
