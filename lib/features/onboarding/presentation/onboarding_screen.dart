import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/data/regions/foundation_references.dart';
import '../../../core/data/regions/region_catalog.dart';
import '../../../core/data/regions/region_pack_parser.dart';
import '../../../core/data/regions/region_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/estimate_demo_fixtures.dart';
import '../domain/footprint_estimate.dart';
import '../../settings/data/user_preferences_repository.dart';
import '../../settings/presentation/region_picker.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    this.regionRepository,
    this.foundationReferences,
    this.regionCatalog,
    this.preferences,
    super.key,
  });

  final RegionRepository? regionRepository;
  final FoundationReferences? foundationReferences;
  final RegionCatalog? regionCatalog;
  final UserPreferencesRepository? preferences;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _electricityController = TextEditingController();
  final _travelController = TextEditingController();
  EstimateDemoRegion? _selectedRegion;
  String? _selectedRegionId;
  String? _answerError;

  bool get _hasRegionalData =>
      widget.regionRepository != null ||
      widget.foundationReferences != null ||
      widget.regionCatalog != null ||
      widget.preferences != null;

  @override
  void initState() {
    super.initState();
    if (_hasRegionalData &&
        (widget.regionRepository == null ||
            widget.foundationReferences == null ||
            widget.regionCatalog == null ||
            widget.preferences == null)) {
      throw ArgumentError(
        'Regional onboarding requires packs, references, catalog, and preferences.',
      );
    }
    if (_hasRegionalData) _loadSelectedRegion();
  }

  Future<void> _loadSelectedRegion() async {
    final settings = await widget.preferences!.load();
    if (!mounted) return;
    setState(() {
      _selectedRegionId = settings.selectedRegionId;
      _selectedRegion = _demoRegionForCatalogSelection(
        settings.selectedRegionId,
      );
    });
  }

  @override
  void dispose() {
    _electricityController.dispose();
    _travelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedPack = _selectedPack;
    final isDemoSelection = _hasRegionalData
        ? _selectedRegionId == 'demo-region'
        : _selectedRegion != null;
    final hasTransportInput =
        isDemoSelection ||
        selectedPack?.emissionFactors.any(
              (factor) => factor.activityId == 'transport',
            ) ==
            true;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.onboarding)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            ClimateSpacing.space24,
            ClimateSpacing.space16,
            ClimateSpacing.space24,
            ClimateSpacing.space24,
          ),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: ClimateColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(
                      ClimateSpacing.radiusSmall,
                    ),
                  ),
                  child: Icon(
                    Icons.eco_outlined,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: ClimateSpacing.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live lighter on the planet',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: ClimateSpacing.space8),
            Text(
              l10n.onboardingIntro,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: ClimateSpacing.space24),
            Card(
              child: DecoratedBox(
                decoration: const BoxDecoration(),
                child: Padding(
                  padding: const EdgeInsets.all(ClimateSpacing.space16),
                  child: _hasRegionalData
                      ? RegionPicker(
                          preferences: widget.preferences!,
                          catalog: widget.regionCatalog!,
                          onSelectionChanged: (regionId) {
                            setState(() {
                              _selectedRegionId = regionId;
                              _selectedRegion = _demoRegionForCatalogSelection(
                                regionId,
                              );
                              _answerError = null;
                            });
                          },
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!_hasRegionalData)
                              Text(
                                l10n.chooseRegion,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            const SizedBox(height: 8),
                            RadioGroup<String>(
                              groupValue: _selectedRegion?.regionId,
                              onChanged: (regionId) {
                                if (regionId == null) return;
                                final selectedRegion =
                                    foundationEstimateDemoRegions
                                        .where(
                                          (region) =>
                                              region.regionId == regionId,
                                        )
                                        .first;
                                setState(() {
                                  _selectedRegion = selectedRegion;
                                  _answerError = null;
                                });
                              },
                              child: Column(
                                children: [
                                  for (final region
                                      in foundationEstimateDemoRegions)
                                    Container(
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: ClimateColors.divider,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: RadioListTile<String>(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                          _regionLabel(l10n, region.labelKey),
                                        ),
                                        value: region.regionId,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            if (isDemoSelection || selectedPack != null) ...[
              const SizedBox(height: ClimateSpacing.space16),
              TextField(
                key: const ValueKey('electricityInput'),
                controller: _electricityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.annualElectricityUse,
                  filled: true,
                  fillColor: ClimateColors.surfaceCard,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              ),
              if (hasTransportInput) ...[
                const SizedBox(height: ClimateSpacing.space16),
                TextField(
                  key: const ValueKey('travelInput'),
                  controller: _travelController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.annualTravel,
                    filled: true,
                    fillColor: ClimateColors.surfaceCard,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: ClimateSpacing.space16),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    l10n.transportDataUnavailable,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.regionalEstimateContext,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (_answerError != null) ...[
                const SizedBox(height: 12),
                Text(
                  _answerError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: ClimateSpacing.space24),
              FilledButton(
                onPressed: _continueToEstimate,
                style: Theme.of(context).filledButtonTheme.style?.copyWith(
                  minimumSize: const WidgetStatePropertyAll(
                    Size.fromHeight(48),
                  ),
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                child: Text(
                  isDemoSelection
                      ? l10n.calculateDemoEstimate
                      : l10n.calculateSourcedEstimate,
                ),
              ),
            ],
            const SizedBox(height: ClimateSpacing.space16),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => context.go(AppRoutes.home),
                child: Text(l10n.skipAndContinueAsGuest),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _continueToEstimate() {
    final region = _selectedRegion;
    final pack = _selectedPack;
    final isDemo = _hasRegionalData
        ? _selectedRegionId == 'demo-region'
        : region != null;
    if (!isDemo && pack == null) return;
    if (isDemo && region == null && !_hasRegionalData) return;

    final electricity = _parseAmount(_electricityController.text);
    final hasTransport =
        isDemo ||
        pack?.emissionFactors.any(
              (factor) => factor.activityId == 'transport',
            ) ==
            true;
    final travel = hasTransport ? _parseAmount(_travelController.text) : null;
    if (electricity == null || (hasTransport && travel == null)) {
      setState(() {
        _answerError =
            _electricityController.text.trim().isEmpty ||
                (hasTransport && _travelController.text.trim().isEmpty)
            ? AppLocalizations.of(context)!.incompleteEstimateAnswers
            : AppLocalizations.of(context)!.invalidEstimateAnswer;
      });
      return;
    }

    final period = isDemo ? region?.period : _firstFactorValidFrom(pack);
    final periodYear = period == null
        ? null
        : isDemo
        ? int.tryParse(period)
        : period.length >= 4
        ? int.tryParse(period.substring(0, 4))
        : null;
    if (periodYear == null) {
      setState(() {
        _answerError = AppLocalizations.of(context)!.estimateDataUnavailable;
      });
      return;
    }
    final activities = <ActivityInput>[
      ActivityInput(
        activityId: 'electricity',
        amount: electricity,
        unit: 'kWh',
      ),
      if (hasTransport)
        ActivityInput(activityId: 'transport', amount: travel, unit: 'km'),
    ];
    final answers = FootprintAnswers(
      questionnaireVersion: '1',
      periodYear: periodYear,
      regionId: isDemo ? 'demo-region' : pack!.region.regionId,
      activities: activities,
    );
    if (isDemo) {
      final demoRegion = region;
      if (demoRegion == null) {
        setState(() {
          _answerError = AppLocalizations.of(context)!.estimateDataUnavailable;
        });
        return;
      }
      context.push(
        AppRoutes.estimateResult,
        extra: OnboardingRouteData(region: demoRegion, answers: answers),
      );
      return;
    }
    final references = widget.foundationReferences;
    if (references == null) {
      setState(() {
        _answerError = AppLocalizations.of(context)!
            .sourcedEstimateDataUnavailable;
      });
      return;
    }
    context.push(
      AppRoutes.estimateResult,
      extra: RegionalOnboardingRouteData(
        region: pack!,
        references: references,
        answers: answers,
      ),
    );
  }

  EstimateDemoRegion? _demoRegionForCatalogSelection(String? regionId) {
    if (regionId == null) return null;
    final catalogRegion = widget.regionCatalog!.regionById(regionId);
    if (catalogRegion == null || !catalogRegion.demoOnly) return null;
    for (final region in foundationEstimateDemoRegions) {
      if (region.regionId == catalogRegion.regionId) return region;
    }
    return null;
  }

  String? _firstFactorValidFrom(RegionDataPack? pack) {
    if (pack == null || pack.emissionFactors.isEmpty) return null;
    return pack.emissionFactors.first.validFrom;
  }

  RegionDataPack? get _selectedPack {
    final regionId = _selectedRegionId;
    if (!_hasRegionalData || regionId == null || regionId == 'demo-region') {
      return null;
    }
    return widget.regionRepository!.regionById(regionId);
  }

  double? _parseAmount(String input) {
    final amount = double.tryParse(input.trim());
    if (amount == null || !amount.isFinite || amount < 0) return null;
    return amount;
  }

  String _regionLabel(AppLocalizations l10n, String labelKey) =>
      switch (labelKey) {
        'regionDemoOnly' => l10n.regionDemoOnly,
        _ => throw ArgumentError.value(
          labelKey,
          'labelKey',
          'Unknown estimate region label',
        ),
      };
}
