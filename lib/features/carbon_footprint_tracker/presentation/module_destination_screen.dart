import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/data/database/app_database.dart';
import '../../../core/accessibility/reduced_motion.dart';
import '../../../core/motion/motion_spec.dart';
import '../../../core/motion/numeric_tick.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../onboarding/domain/footprint_estimate.dart';
import '../../onboarding/presentation/estimate_factor_disclosure.dart';
import '../data/activity_log_repository.dart';
import 'activity_log_insights_screen.dart';

class CarbonFootprintDestinationScreen extends StatelessWidget {
  const CarbonFootprintDestinationScreen({
    this.repository,
    this.regionId,
    this.factors = const [],
    super.key,
  });

  final ActivityLogRepository? repository;
  final String? regionId;
  final List<EmissionFactor> factors;

  EmissionFactor? get _electricityFactor {
    final matches = factors
        .where((factor) => factor.activityId == 'electricity')
        .toList(growable: false);
    return matches.length == 1 ? matches.single : null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final entries = repository?.watchEntries();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(l10n.carbonFootprintTracker, maxLines: 2),
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
          final loggedEntries = snapshot.data ?? const <ActivityLogEntry>[];
          final currentYear = DateTime.now().year;
          final periodTotal = loggedEntries
              .where((entry) => entry.activityDate.year == currentYear)
              .fold<double>(0, (total, entry) => total + entry.emissionsKg);
          return _ActivityLogBody(
            entries: loggedEntries,
            periodYear: currentYear,
            periodTotal: periodTotal,
            repository: repository,
            regionId: regionId,
            factors: factors,
            electricityFactor: _electricityFactor,
          );
        },
      ),
    );
  }
}

class _ActivityLogBody extends StatelessWidget {
  const _ActivityLogBody({
    required this.entries,
    required this.periodYear,
    required this.periodTotal,
    required this.repository,
    required this.regionId,
    required this.factors,
    required this.electricityFactor,
  });

  final List<ActivityLogEntry> entries;
  final int periodYear;
  final double periodTotal;
  final ActivityLogRepository? repository;
  final String? regionId;
  final List<EmissionFactor> factors;
  final EmissionFactor? electricityFactor;

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
        MonoNumericText(text: l10n.trackerPeriodTotal(periodYear)),
        const SizedBox(height: ClimateSpacing.space8),
        NumericTick(
          value: periodTotal,
          decimalPlaces: 2,
          style: Theme.of(context).textTheme.displayLarge!
              .merge(typography.number),
          suffix: ' kg CO2',
          suffixStyle: Theme.of(context).textTheme.titleMedium!
              .merge(typography.unit),
          textKey: const ValueKey('trackerPeriodTotalValue'),
        ),
        const SizedBox(height: ClimateSpacing.space8),
        Text(l10n.trackerCoverage),
        const SizedBox(height: ClimateSpacing.space24),
        OutlinedButton(
          onPressed: () => Navigator.of(context).push<void>(
            PageRouteBuilder<void>(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  ActivityLogInsightsScreen(
                    repository: repository,
                    year: periodYear,
                  ),
              transitionDuration: ReducedMotion.duration(
                context,
                MotionSpec.optionalFade,
              ),
              reverseTransitionDuration: ReducedMotion.duration(
                context,
                MotionSpec.optionalFade,
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(
                        opacity: animation.drive(
                          CurveTween(curve: MotionSpec.optionalFadeCurve),
                        ),
                        child: child,
                      ),
            ),
          ),
          child: Text(l10n.trackerViewInsights),
        ),
        const SizedBox(height: ClimateSpacing.space16),
        FilledButton.icon(
          onPressed: () => _showCategoryPicker(context),
          icon: const Icon(Icons.add),
          label: Text(l10n.trackerAddEntry),
        ),
        const SizedBox(height: ClimateSpacing.space24),
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: ClimateSpacing.space16,
            ),
            child: Text(l10n.trackerNoActivities),
          )
        else
          for (final entry in entries) ...[
            _ActivityRow(
              entry: entry,
              onDelete: () => _deleteEntry(context, entry.activityId),
            ),
            const Divider(height: 1),
          ],
      ],
    );
  }

  Future<void> _showCategoryPicker(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final factorAvailable =
        repository != null && regionId != null && electricityFactor != null;
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: ClimateSpacing.space8),
          children: [
            ListTile(
              title: Text(l10n.trackerElectricity),
              subtitle: factorAvailable
                  ? Text(l10n.trackerElectricityUnit)
                  : Text(l10n.trackerSelectedRegionFactorUnavailable),
              enabled: factorAvailable,
              onTap: factorAvailable
                  ? () => Navigator.of(context).pop('electricity')
                  : null,
            ),
            const Divider(height: 1),
            ListTile(
              title: Text(l10n.trackerTransport),
              subtitle: Text(l10n.trackerFactorUnavailable),
              enabled: false,
            ),
            const Divider(height: 1),
            ListTile(
              title: Text(l10n.trackerFood),
              subtitle: Text(l10n.trackerFactorUnavailable),
              enabled: false,
            ),
          ],
        ),
      ),
    );
    if (selected == 'electricity' && context.mounted) {
      await _showElectricityEntry(context);
    }
  }

  Future<void> _showElectricityEntry(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final factor = electricityFactor;
    final repo = repository;
    final currentRegionId = regionId;
    if (factor == null || repo == null || currentRegionId == null) return;

    final result = await showDialog<_ActivityFormResult>(
      context: context,
      builder: (context) => _ElectricityEntryDialog(factor: factor),
    );
    if (result == null || !context.mounted) return;

    try {
      await repo.addElectricity(
        date: result.date,
        amountKwh: result.amountKwh,
        regionId: currentRegionId,
        factors: factors,
      );
    } on Exception {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.trackerSaveFailure)));
      }
    }
  }

  Future<void> _deleteEntry(BuildContext context, String activityId) async {
    final l10n = AppLocalizations.of(context)!;
    final repo = repository;
    if (repo == null) return;
    try {
      await repo.deleteEntry(activityId);
    } on Exception {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.trackerDeleteFailure)));
      }
    }
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.entry, required this.onDelete});

  final ActivityLogEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final numberStyle = Theme.of(context)
        .extension<ClimateTypography>()!
        .number;
    final date = DateFormat.yMMMd(l10n.localeName).format(entry.activityDate);
    final category = switch (entry.category) {
      'electricity' => l10n.trackerElectricity,
      _ => entry.category,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ClimateSpacing.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: ClimateSpacing.space8,
                  runSpacing: ClimateSpacing.space8,
                  children: [
                    Text(date, style: numberStyle),
                    Text(category),
                  ],
                ),
                const SizedBox(height: ClimateSpacing.space8),
                Wrap(
                  spacing: ClimateSpacing.space16,
                  runSpacing: ClimateSpacing.space8,
                  children: [
                    Text(
                      '${entry.amount.toStringAsFixed(2)} ${entry.unit}',
                      style: numberStyle,
                    ),
                    Text(
                      '${entry.emissionsKg.toStringAsFixed(3)} kg CO2',
                      style: numberStyle,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.trackerDeleteEntry,
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _ElectricityEntryDialog extends StatefulWidget {
  const _ElectricityEntryDialog({required this.factor});

  final EmissionFactor factor;

  @override
  State<_ElectricityEntryDialog> createState() =>
      _ElectricityEntryDialogState();
}

class _ElectricityEntryDialogState extends State<_ElectricityEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final numberStyle = Theme.of(context)
        .extension<ClimateTypography>()!
        .number;
    final source = widget.factor.source;
    return AlertDialog(
      scrollable: true,
      title: Text(l10n.trackerAddElectricity),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: _pickDate,
              child: Text(
                '${l10n.trackerDateLabel}: '
                '${DateFormat.yMMMd(l10n.localeName).format(_date)}',
                style: numberStyle,
              ),
            ),
            TextFormField(
              key: const ValueKey('trackerAmountField'),
              controller: _amountController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: numberStyle,
              decoration: InputDecoration(
                labelText: l10n.trackerAmountLabel,
                suffixText: 'kWh',
                suffixStyle: numberStyle,
              ),
              validator: (value) {
                final amount = double.tryParse(value?.trim() ?? '');
                if (amount == null || !amount.isFinite || amount < 0) {
                  return l10n.trackerInvalidAmount;
                }
                return null;
              },
            ),
            const SizedBox(height: ClimateSpacing.space16),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text:
                        '${l10n.factorSourceDetails(source.title, source.publisher ?? source.title)} (',
                  ),
                  TextSpan(
                    text:
                        '${widget.factor.value} ${widget.factor.numeratorUnit} / '
                        '${widget.factor.denominatorUnit}',
                    style: numberStyle,
                  ),
                  const TextSpan(text: ')'),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.trackerSaveEntry)),
      ],
    );
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (selected != null && mounted) {
      setState(() {
        _date = selected;
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      _ActivityFormResult(
        date: _date,
        amountKwh: double.parse(_amountController.text.trim()),
      ),
    );
  }
}

class _ActivityFormResult {
  const _ActivityFormResult({required this.date, required this.amountKwh});

  final DateTime date;
  final double amountKwh;
}
