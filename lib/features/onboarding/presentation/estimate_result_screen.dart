import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/data/regions/foundation_references.dart';
import '../../../core/data/regions/region_pack_parser.dart';
import '../../../core/motion/numeric_tick.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/estimate_demo_fixtures.dart';
import '../data/footprint_estimate_repository.dart';
import '../domain/footprint_calculator.dart';
import '../domain/footprint_estimate.dart';
import '../domain/lifestyle_budget_share.dart';
import 'estimate_factor_disclosure.dart';

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
    final references =
        widget.foundationReferences ?? await FoundationReferences.loadBundled();
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

    final benchmark = references.temperatureBudget;
    final benchmarkSource = references.sources[benchmark.reference.sourceId];
    if (benchmarkSource == null) {
      throw StateError('The cited lifestyle budget source is unavailable.');
    }
    return _EstimateResultData(
      region: region,
      estimate: estimate,
      benchmark: benchmark,
      benchmarkSource: benchmarkSource,
    );
  }

  _EstimateRegion _resolveRegion() {
    if (widget.onboardingData case final routeData?) {
      return _EstimateRegion.fromDemo(routeData.region);
    }
    if (widget.regionalOnboardingData case final routeData?) {
      return _EstimateRegion.fromPack(routeData.region);
    }
    if (widget.selectedRegionPack case final pack?) {
      return _EstimateRegion.fromPack(pack);
    }
    return _EstimateRegion.fromDemo(
      widget.demoRegion ?? foundationEstimateDemoRegions.single,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(l10n.estimateResult, maxLines: 2),
      ),
      body: FutureBuilder<_EstimateResultData>(
        future: _result,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(ClimateSpacing.space16),
                child: Text(
                  '${l10n.estimateLoadFailure}\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final data = snapshot.data;
          if (data == null) {
            return Center(child: AppSkeleton(semanticsLabel: l10n.loading));
          }

          final budgetShare = _budgetShare(data);
          final categoryTotals = _displayCategoryTotals(data.estimate);
          return ListView(
            key: const ValueKey('estimateResultList'),
            padding: const EdgeInsets.symmetric(
              horizontal: ClimateSpacing.space16,
              vertical: ClimateSpacing.space8,
            ),
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
              const SizedBox(height: ClimateSpacing.space8),
              Text(
                _regionLabel(l10n, data.region.labelKey),
                key: const ValueKey('estimateRegionLabel'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (data.region.currencyCode != null)
                Text(l10n.regionCurrency(data.region.currencyCode!)),
              const SizedBox(height: ClimateSpacing.space16),
              _buildTotal(context, l10n, data.estimate),
              const Divider(height: ClimateSpacing.space24),
              _BudgetSharePanel(
                data: data,
                share: budgetShare,
                demoOnly: data.region.demoOnly,
              ),
              const Divider(height: ClimateSpacing.space24),
              _CategoryBreakdownPanel(
                categories: categoryTotals,
                estimate: data.estimate,
                demoOnly: data.region.demoOnly,
              ),
              const Divider(height: ClimateSpacing.space24),
              _CoveragePanel(
                included: data.estimate.categoryTotals
                    .map((item) => item.category)
                    .toSet(),
                available: data.region.factors
                    .map((factor) => factor.category)
                    .toSet(),
                demoOnly: data.region.demoOnly,
              ),
              const Divider(height: ClimateSpacing.space24),
              EstimateFactorDisclosure(
                factors: data.estimate.factorsUsed,
                demoOnly: data.region.demoOnly,
              ),
              const SizedBox(height: ClimateSpacing.space24),
              for (final assumption in data.estimate.assumptions)
                Text(_assumptionLabel(l10n, assumption)),
              const SizedBox(height: ClimateSpacing.space24),
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

  Widget _buildTotal(
    BuildContext context,
    AppLocalizations l10n,
    CompleteEstimate estimate,
  ) {
    final numberStyle = Theme.of(context)
        .extension<ClimateTypography>()!
        .number;
    final unitStyle = Theme.of(context).extension<ClimateTypography>()!.unit;
    return Semantics(
      label:
          '${l10n.estimateResult}: ${estimate.displayValue} ${estimate.unit}',
      child: NumericTick(
        key: const ValueKey('estimateTotalNumericTick'),
        textKey: const ValueKey('estimateTotal'),
        value: estimate.value,
        decimalPlaces: 2,
        style: Theme.of(context).textTheme.headlineSmall!.merge(numberStyle),
        suffix: ' ${estimate.unit}',
        suffixStyle: Theme.of(context).textTheme.headlineSmall
            ?.merge(unitStyle),
      ),
    );
  }

  double? _budgetShare(_EstimateResultData data) {
    final estimate = data.estimate;
    final benchmark = data.benchmark;
    final reference = benchmark.reference;
    return lifestyleBudgetShare(
      referenceId: reference.referenceId,
      referenceValue: reference.value,
      referenceUnit: reference.unit,
      referencePeriod: reference.period,
      targetYear: benchmark.targetYear,
      estimateValue: estimate.value,
      estimateUnit: estimate.unit,
      assumptions: estimate.assumptions,
    );
  }

  List<_DisplayCategoryTotal> _displayCategoryTotals(
    CompleteEstimate estimate,
  ) {
    final totalCents = (estimate.value * 100).round();
    final cents = estimate.categoryTotals
        .map((category) => (category.value * 100).round())
        .toList();
    if (cents.isNotEmpty) {
      final difference = totalCents - cents.fold<int>(0, (a, b) => a + b);
      var largestIndex = 0;
      for (var index = 1; index < estimate.categoryTotals.length; index++) {
        if (estimate.categoryTotals[index].value >
            estimate.categoryTotals[largestIndex].value) {
          largestIndex = index;
        }
      }
      cents[largestIndex] += difference;
    }
    return [
      for (var index = 0; index < estimate.categoryTotals.length; index++)
        _DisplayCategoryTotal(
          category: estimate.categoryTotals[index].category,
          value: cents[index] / 100,
          share: estimate.value == 0
              ? 0
              : estimate.categoryTotals[index].value / estimate.value,
        ),
    ];
  }

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

class _BudgetSharePanel extends StatelessWidget {
  const _BudgetSharePanel({
    required this.data,
    required this.share,
    required this.demoOnly,
  });

  final _EstimateResultData data;
  final double? share;
  final bool demoOnly;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final numberStyle = Theme.of(context)
        .extension<ClimateTypography>()!
        .number;
    final unitStyle = Theme.of(context).extension<ClimateTypography>()!.unit;
    final reference = data.benchmark.reference;
    final shareText = share == null ? null : (share! * 100).toStringAsFixed(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(title: l10n.budgetShareTitle, demoOnly: demoOnly),
        const SizedBox(height: ClimateSpacing.space8),
        if (shareText case final percent?)
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '${l10n.budgetSharePrefix} '),
                TextSpan(text: percent, style: numberStyle),
                TextSpan(text: '% ${l10n.budgetShareSuffix} '),
                TextSpan(text: '1.5°', style: numberStyle),
                const TextSpan(text: ' budget'),
              ],
            ),
          )
        else
          Text(l10n.budgetShareUnavailable),
        const SizedBox(height: ClimateSpacing.space8),
        if (share case final availableShare?) ...[
          Semantics(
            label: l10n.budgetShareTitle,
            value: '$shareText%',
            child: LinearProgressIndicator(
              key: const ValueKey('budgetShareBar'),
              value: availableShare.clamp(0, 1).toDouble(),
              minHeight: 8,
              backgroundColor: ClimateColors.surfaceSecondary,
              color: ClimateColors.emissions,
            ),
          ),
          const SizedBox(height: ClimateSpacing.space8),
        ],
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${reference.value.toStringAsFixed(1)} ',
                style: numberStyle,
              ),
              TextSpan(text: reference.unit, style: unitStyle),
              TextSpan(text: ' ${l10n.budgetBenchmarkByYear} '),
              TextSpan(
                text: data.benchmark.targetYear.toString(),
                style: numberStyle,
              ),
            ],
          ),
        ),
        MonoNumericText(
          text: l10n.factorSourceDetails(
            data.benchmarkSource.title,
            data.benchmarkSource.publisher,
          ),
        ),
        MonoNumericText(
          text: l10n.publicationYear(data.benchmarkSource.publicationYear),
        ),
        MonoNumericText(text: data.benchmark.reference.methodology),
        MonoNumericText(text: data.benchmark.reference.accountingBoundary),
      ],
    );
  }
}

class _CategoryBreakdownPanel extends StatelessWidget {
  const _CategoryBreakdownPanel({
    required this.categories,
    required this.estimate,
    required this.demoOnly,
  });

  final List<_DisplayCategoryTotal> categories;
  final CompleteEstimate estimate;
  final bool demoOnly;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final numberStyle = Theme.of(context)
        .extension<ClimateTypography>()!
        .number;
    final unitStyle = Theme.of(context).extension<ClimateTypography>()!.unit;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(title: l10n.categoryBreakdownTitle, demoOnly: demoOnly),
        const SizedBox(height: ClimateSpacing.space8),
        for (final item in categories) ...[
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: ClimateSpacing.space8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(_categoryLabel(l10n, item.category))),
                    Text.rich(
                      key: ValueKey('categoryAmount-${item.category}'),
                      TextSpan(
                        children: [
                          TextSpan(
                            text: item.value.toStringAsFixed(2),
                            style: numberStyle,
                          ),
                          TextSpan(text: ' ${estimate.unit}', style: unitStyle),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: ClimateSpacing.space8),
                LinearProgressIndicator(
                  key: ValueKey('categoryShareBar-${item.category}'),
                  value: item.share.clamp(0, 1).toDouble(),
                  minHeight: 8,
                  backgroundColor: ClimateColors.surfaceSecondary,
                  color: ClimateColors.emissions,
                  semanticsLabel: _categoryLabel(l10n, item.category),
                  semanticsValue: '${(item.share * 100).toStringAsFixed(1)}%',
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: (item.share * 100).toStringAsFixed(1),
                          style: numberStyle,
                        ),
                        TextSpan(text: '%', style: unitStyle),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (item != categories.last) const Divider(height: 1),
        ],
      ],
    );
  }
}

class _CoveragePanel extends StatelessWidget {
  const _CoveragePanel({
    required this.included,
    required this.available,
    required this.demoOnly,
  });

  final Set<String> included;
  final Set<String> available;
  final bool demoOnly;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final excluded = available.difference(included);
    return Container(
      key: const ValueKey('estimateCoveragePanel'),
      decoration: BoxDecoration(
        color: ClimateColors.surfaceSecondary,
        border: Border.all(color: ClimateColors.divider),
        borderRadius: BorderRadius.circular(ClimateSpacing.radiusSmall),
      ),
      padding: const EdgeInsets.all(ClimateSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(
            title: l10n.estimateCoverageTitle,
            demoOnly: demoOnly,
          ),
          const SizedBox(height: ClimateSpacing.space16),
          Text(
            l10n.coverageIncludedTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            included.isEmpty
                ? l10n.coverageNoIncludedCategories
                : included
                      .map((category) => _categoryLabel(l10n, category))
                      .join(', '),
          ),
          const SizedBox(height: ClimateSpacing.space16),
          Text(
            l10n.coverageExcludedTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            excluded.isEmpty
                ? l10n.coverageNoExcludedCategories
                : excluded
                      .map((category) => _categoryLabel(l10n, category))
                      .join(', '),
          ),
          const SizedBox(height: ClimateSpacing.space8),
          Text(l10n.coverageFactorScopeNote),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.demoOnly});

  final String title;
  final bool demoOnly;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
      if (demoOnly)
        DemoOnlyTag(label: AppLocalizations.of(context)!.demoOnlyTag),
    ],
  );
}

class _EstimateResultData {
  const _EstimateResultData({
    required this.region,
    required this.estimate,
    required this.benchmark,
    required this.benchmarkSource,
  });

  final _EstimateRegion region;
  final CompleteEstimate estimate;
  final FoundationTemperatureBudget benchmark;
  final FoundationReferenceSource benchmarkSource;
}

class _EstimateRegion {
  const _EstimateRegion({
    required this.regionId,
    required this.labelKey,
    required this.factors,
    required this.demoOnly,
    this.currencyCode,
  });

  factory _EstimateRegion.fromDemo(EstimateDemoRegion region) =>
      _EstimateRegion(
        regionId: region.regionId,
        labelKey: region.labelKey,
        factors: region.factors,
        demoOnly: region.demoOnly,
      );

  factory _EstimateRegion.fromPack(RegionDataPack pack) => _EstimateRegion(
    regionId: pack.region.regionId,
    labelKey: pack.region.nameKey,
    factors: emissionFactorsFromRegionPack(pack),
    demoOnly: false,
    currencyCode: pack.region.currencyCode,
  );

  final String regionId;
  final String labelKey;
  final List<EmissionFactor> factors;
  final bool demoOnly;
  final String? currencyCode;
}

class _DisplayCategoryTotal {
  const _DisplayCategoryTotal({
    required this.category,
    required this.value,
    required this.share,
  });

  final String category;
  final double value;
  final double share;
}

String _categoryLabel(AppLocalizations l10n, String category) =>
    switch (category) {
      'electricity' => l10n.electricityFactor,
      'transport' => l10n.transportFactor,
      'food' => l10n.foodFactor,
      'waste' => l10n.wasteFactor,
      'other' => l10n.otherFactor,
      _ => throw ArgumentError.value(
        category,
        'category',
        'Unknown estimate factor category',
      ),
    };
