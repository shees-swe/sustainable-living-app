import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/accessibility/motion_aware_progress_indicator.dart';
import '../../../core/accessibility/reduced_motion.dart';
import '../../../core/data/database/app_database.dart';
import '../../../core/motion/motion_spec.dart';
import '../../../core/motion/numeric_tick.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/waste_log_repository.dart';
import '../domain/waste_category.dart';
import '../domain/waste_month_summary.dart';

class WasteReductionTrackerScreen extends StatefulWidget {
  const WasteReductionTrackerScreen({required this.repository, super.key});

  final WasteLogRepository repository;

  @override
  State<WasteReductionTrackerScreen> createState() =>
      _WasteReductionTrackerScreenState();
}

class _WasteReductionTrackerScreenState
    extends State<WasteReductionTrackerScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(l10n.wasteReductionTracker, maxLines: 2),
      ),
      body: StreamBuilder<List<WasteLogEntry>>(
        stream: widget.repository.watchEntries(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(l10n.wasteLoadFailure));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: MotionAwareProgressIndicator(semanticsLabel: l10n.loading),
            );
          }
          final entries = snapshot.data ?? const <WasteLogEntry>[];
          final summary = WasteMonthSummary.fromEntries(
            entries: entries,
            month: DateTime.now(),
          );
          return _WasteTrackerBody(
            entries: entries,
            summary: summary,
            onAdd: () => _addEntry(context),
            onDelete: (entryId) => _deleteEntry(context, entryId),
          );
        },
      ),
    );
  }

  Future<void> _addEntry(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showGeneralDialog<_WasteEntryFormResult>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: ReducedMotion.duration(
        context,
        MotionSpec.optionalFade,
      ),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const _WasteEntryDialog(),
      transitionBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(
            opacity: animation.drive(
              CurveTween(curve: MotionSpec.optionalFadeCurve),
            ),
            child: child,
          ),
    );
    if (result == null || !context.mounted) return;

    try {
      await widget.repository.addEntry(
        date: result.date,
        category: result.category,
        amountKg: result.amountKg,
      );
    } on Exception {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.wasteSaveFailure)));
      }
    }
  }

  Future<void> _deleteEntry(BuildContext context, String entryId) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await widget.repository.deleteEntry(entryId);
    } on Exception {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.wasteDeleteFailure)));
      }
    }
  }
}

class _WasteTrackerBody extends StatelessWidget {
  const _WasteTrackerBody({
    required this.entries,
    required this.summary,
    required this.onAdd,
    required this.onDelete,
  });

  final List<WasteLogEntry> entries;
  final WasteMonthSummary summary;
  final VoidCallback onAdd;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final typography = theme.extension<ClimateTypography>()!;
    final month = DateTime(summary.year, summary.month);
    final monthLabel = DateFormat.yMMMM(l10n.localeName).format(month);
    return ListView(
      key: const ValueKey('wasteTrackerList'),
      padding: const EdgeInsets.symmetric(
        horizontal: ClimateSpacing.space16,
        vertical: ClimateSpacing.space16,
      ),
      children: [
        Text(l10n.wasteEstimateNote),
        const SizedBox(height: ClimateSpacing.space24),
        Text(l10n.wasteMonthSummary, style: theme.textTheme.titleMedium),
        const SizedBox(height: ClimateSpacing.space8),
        _NumberAwareText(monthLabel, style: typography.number),
        const SizedBox(height: ClimateSpacing.space16),
        Text(
          l10n.wasteMonthTotal,
          style: theme.textTheme.bodySmall?.copyWith(
            color: ClimateColors.textSecondary,
          ),
        ),
        NumericTick(
          value: summary.totalKg,
          decimalPlaces: 2,
          style: theme.textTheme.displayLarge!.merge(typography.number),
          suffix: ' kg',
          suffixStyle: theme.textTheme.titleMedium!.merge(typography.unit),
          textKey: const ValueKey('wasteMonthTotalValue'),
        ),
        if (summary.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: ClimateSpacing.space8),
            child: Text(l10n.wasteMonthEmpty),
          )
        else
          for (var index = 0; index < summary.categories.length; index++) ...[
            _WasteCategoryTotalRow(total: summary.categories[index]),
            if (index < summary.categories.length - 1) const Divider(height: 1),
          ],
        const SizedBox(height: ClimateSpacing.space24),
        FilledButton.icon(
          key: const ValueKey('wasteAddEntryButton'),
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: Text(l10n.wasteAddEntry),
        ),
        const SizedBox(height: ClimateSpacing.space24),
        Text(l10n.wasteLogSection, style: theme.textTheme.titleMedium),
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: ClimateSpacing.space16,
            ),
            child: Text(l10n.wasteNoEntries),
          )
        else
          for (final entry in entries) ...[
            _WasteEntryRow(
              entry: entry,
              onDelete: () => onDelete(entry.entryId),
            ),
            const Divider(height: 1),
          ],
      ],
    );
  }
}

class _WasteCategoryTotalRow extends StatelessWidget {
  const _WasteCategoryTotalRow({required this.total});

  final WasteCategoryMonthTotal total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = _categoryLabel(l10n, total.category);
    final amount = '${(total.kgCents / 100).toStringAsFixed(2)} kg';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ClimateSpacing.space8),
      child: Wrap(
        spacing: ClimateSpacing.space16,
        runSpacing: ClimateSpacing.space8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(label),
          Text(
            amount,
            style: Theme.of(context).extension<ClimateTypography>()!.number,
          ),
        ],
      ),
    );
  }
}

class _WasteEntryRow extends StatelessWidget {
  const _WasteEntryRow({required this.entry, required this.onDelete});

  final WasteLogEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final numberStyle = Theme.of(context)
        .extension<ClimateTypography>()!
        .number;
    final date = DateFormat.yMMMd(l10n.localeName).format(entry.wasteDate);
    final category = _categoryLabel(
      l10n,
      WasteCategory.fromValue(entry.category),
    );
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
                    _NumberAwareText(date, style: numberStyle),
                    Text(category),
                  ],
                ),
                const SizedBox(height: ClimateSpacing.space8),
                Text(
                  '${entry.amountKg.toStringAsFixed(2)} kg',
                  style: numberStyle,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.wasteDeleteEntry,
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _WasteEntryDialog extends StatefulWidget {
  const _WasteEntryDialog();

  @override
  State<_WasteEntryDialog> createState() => _WasteEntryDialogState();
}

class _WasteEntryDialogState extends State<_WasteEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  DateTime _date = DateTime.now();
  WasteCategory _category = WasteCategory.values.first;

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
    return AlertDialog(
      scrollable: true,
      title: Text(l10n.wasteAddEntry),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: _pickDate,
              child: Wrap(
                spacing: ClimateSpacing.space8,
                children: [
                  Text(l10n.wasteDateLabel),
                  _NumberAwareText(
                    DateFormat.yMMMd(l10n.localeName).format(_date),
                    style: numberStyle,
                  ),
                ],
              ),
            ),
            const SizedBox(height: ClimateSpacing.space8),
            Text(
              l10n.wasteCategoryLabel,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: ClimateColors.textSecondary),
            ),
            const SizedBox(height: ClimateSpacing.space8),
            DropdownButtonFormField<WasteCategory>(
              key: const ValueKey('wasteCategoryPicker'),
              initialValue: _category,
              isExpanded: true,
              decoration: const InputDecoration(),
              items: [
                for (final category in WasteCategory.values)
                  DropdownMenuItem(
                    value: category,
                    child: Text(_categoryLabel(l10n, category), maxLines: 2),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: ClimateSpacing.space16),
            TextFormField(
              key: const ValueKey('wasteAmountField'),
              controller: _amountController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: numberStyle,
              decoration: InputDecoration(
                labelText: l10n.wasteAmountLabel,
                suffixText: 'kg',
                suffixStyle: numberStyle,
              ),
              validator: (value) {
                final amount = double.tryParse(value?.trim() ?? '');
                if (amount == null || !amount.isFinite || amount <= 0) {
                  return l10n.wasteInvalidAmount;
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.wasteSaveEntry)),
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
      setState(() => _date = selected);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      _WasteEntryFormResult(
        date: _date,
        category: _category,
        amountKg: double.parse(_amountController.text.trim()),
      ),
    );
  }
}

class _WasteEntryFormResult {
  const _WasteEntryFormResult({
    required this.date,
    required this.category,
    required this.amountKg,
  });

  final DateTime date;
  final WasteCategory category;
  final double amountKg;
}

String _categoryLabel(AppLocalizations l10n, WasteCategory category) =>
    switch (category) {
      WasteCategory.plastic => l10n.wastePlastic,
      WasteCategory.paperAndCardboard => l10n.wastePaperCardboard,
      WasteCategory.glass => l10n.wasteGlass,
      WasteCategory.metal => l10n.wasteMetal,
      WasteCategory.organic => l10n.wasteOrganic,
      WasteCategory.other => l10n.wasteOther,
    };

class _NumberAwareText extends StatelessWidget {
  const _NumberAwareText(this.text, {this.style});

  final String text;
  final TextStyle? style;

  static final _numberPattern = RegExp(r'\d+(?:[.,]\d+)*');

  @override
  Widget build(BuildContext context) {
    final numberStyle = Theme.of(context)
        .extension<ClimateTypography>()!
        .number;
    final spans = <TextSpan>[];
    var cursor = 0;
    for (final match in _numberPattern.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      spans.add(TextSpan(text: match.group(0), style: numberStyle));
      cursor = match.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }
    return Text.rich(TextSpan(children: spans), style: style);
  }
}
