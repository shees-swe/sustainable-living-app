import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/data/regions/foundation_references.dart';
import '../../../core/data/regions/region_catalog.dart';
import '../../../core/data/regions/region_pack_parser.dart';
import '../../../core/data/regions/region_repository.dart';
import '../../../core/theme/design_tokens.dart';
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
    setState(() => _selectedRegionId = settings.selectedRegionId);
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
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.space4),
        children: [
          Text(
            l10n.onboardingIntro,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: DesignTokens.space3),
          if (!_hasRegionalData)
            Text(
              l10n.chooseRegion,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          if (_hasRegionalData)
            RegionPicker(
              preferences: widget.preferences!,
              catalog: widget.regionCatalog!,
              onSelectionChanged: (regionId) {
                setState(() {
                  _selectedRegionId = regionId;
                  _answerError = null;
                });
              },
            )
          else
            RadioGroup<String>(
              groupValue: _selectedRegion?.regionId,
              onChanged: (regionId) {
                if (regionId == null) return;
                final selectedRegion = foundationEstimateDemoRegions
                    .where((region) => region.regionId == regionId)
                    .first;
                setState(() {
                  _selectedRegion = selectedRegion;
                  _answerError = null;
                });
              },
              child: Column(
                children: [
                  for (final region in foundationEstimateDemoRegions)
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_regionLabel(l10n, region.labelKey)),
                      value: region.regionId,
                    ),
                ],
              ),
            ),
          if (isDemoSelection || selectedPack != null) ...[
            const SizedBox(height: DesignTokens.space2),
            TextField(
              key: const ValueKey('electricityInput'),
              controller: _electricityController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: l10n.annualElectricityUse),
            ),
            if (hasTransportInput) ...[
              const SizedBox(height: DesignTokens.space2),
              TextField(
                key: const ValueKey('travelInput'),
                controller: _travelController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(labelText: l10n.annualTravel),
              ),
            ] else ...[
              const SizedBox(height: DesignTokens.space2),
              Text(l10n.transportDataUnavailable),
              const SizedBox(height: DesignTokens.space2),
              Text(l10n.regionalEstimateContext),
            ],
            if (_answerError != null) ...[
              const SizedBox(height: DesignTokens.space2),
              Text(
                _answerError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: DesignTokens.space3),
            FilledButton(
              onPressed: _continueToEstimate,
              child: Text(
                isDemoSelection
                    ? l10n.calculateDemoEstimate
                    : l10n.calculateSourcedEstimate,
              ),
            ),
          ],
          const SizedBox(height: DesignTokens.space2),
          TextButton(
            onPressed: () => context.go(AppRoutes.home),
            child: Text(l10n.skipAndContinueAsGuest),
          ),
        ],
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

    final period = isDemo
        ? region?.period
        : pack!.emissionFactors.first.validFrom;
    final periodYear = isDemo
        ? int.tryParse(period!)
        : int.tryParse(period!.substring(0, 4));
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
      final demoRegion =
          region ??
          foundationEstimateDemoRegions.singleWhere(
            (item) => item.regionId == _selectedRegionId,
          );
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
