import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/motion/motion_spec.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/footprint_estimate.dart';
import '../domain/reference_value.dart';

class ComparisonRing extends StatelessWidget {
  const ComparisonRing({
    required this.label,
    required this.estimate,
    required this.comparison,
    this.contextualReference,
    this.contextualSource,
    super.key,
  });

  final String label;
  final CompleteEstimate estimate;
  final ReferenceComparisonResult comparison;
  final ReferenceValue? contextualReference;
  final ReferenceSource? contextualSource;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final source = comparison.source;
    final referenceValue = comparison.value;
    if (comparison.status != ReferenceComparisonStatus.available ||
        source == null ||
        referenceValue == null) {
      final reference = contextualReference;
      final contextSource = contextualSource;
      return Semantics(
        container: true,
        label: reference == null || contextSource == null
            ? '$label. ${l10n.referenceUnavailable}'
            : '$label. ${l10n.contextualReferenceOnly} '
                  '${_format(reference.value!)} ${reference.unit}. '
                  '${contextSource.title}, ${contextSource.publisher}, '
                  '${contextSource.publicationYear}. ${reference.period}. '
                  '${reference.methodology}. ${reference.accountingBoundary}.',
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Text(l10n.referenceUnavailable),
                if (reference != null && contextSource != null) ...[
                  const SizedBox(height: 8),
                  Text(l10n.contextualReferenceOnly),
                  Text(
                    l10n.referenceComparisonValue(
                      _format(reference.value!),
                      reference.unit!,
                    ),
                  ),
                  Text(l10n.comparisonPeriod(reference.period!)),
                  Text(
                    l10n.comparisonSource(
                      contextSource.title,
                      contextSource.publisher,
                    ),
                  ),
                  Text(l10n.publicationYear(contextSource.publicationYear)),
                  Text(l10n.referenceMethodology(reference.methodology!)),
                  Text(reference.accountingBoundary!),
                ] else
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12)),
              ],
            ),
          ),
        ),
      );
    }

    return Semantics(
      container: true,
      label:
          '$label. ${estimate.displayValue} ${estimate.unit}; reference '
          '${_format(referenceValue)} ${comparison.unit}. '
          '${source.title}, ${source.publisher}, ${source.publicationYear}. '
          '${comparison.period}. ${comparison.methodology}.',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              if (referenceValue == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(l10n.zeroReferenceCannotBeCharted),
                )
              else
                _AvailableRing(estimate: estimate, reference: comparison),
              Text(
                l10n.estimateComparisonValue(
                  estimate.displayValue,
                  estimate.unit,
                ),
              ),
              Text(
                l10n.referenceComparisonValue(
                  _format(referenceValue),
                  comparison.unit!,
                ),
              ),
              Text(l10n.comparisonPeriod(comparison.period!)),
              Text(l10n.comparisonSource(source.title, source.publisher)),
              Text(l10n.publicationYear(source.publicationYear)),
              Text(comparison.methodology!),
              Text(comparison.accountingBoundary!),
            ],
          ),
        ),
      ),
    );
  }

  static String _format(double value) => value.toStringAsFixed(2);
}

class CalculationFactorDisclosure extends StatelessWidget {
  const CalculationFactorDisclosure({required this.factors, super.key});

  final List<EmissionFactor> factors;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.factorsUsedInEstimate,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        for (final factor in factors)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              l10n.factorApplication(
                _factorCategory(l10n, factor.category),
                factor.value.toString(),
                factor.numeratorUnit,
                factor.denominatorUnit,
              ),
            ),
            subtitle: Text(
              '${l10n.factorSourceDetails(factor.source.title, factor.source.publisher ?? factor.source.title)}\n'
              '${l10n.publicationYear(factor.source.publicationYear)}\n'
              '${l10n.factorValidFrom(factor.validFrom)}\n'
              '${factor.methodology}',
            ),
          ),
      ],
    );
  }

  String _factorCategory(AppLocalizations l10n, String category) =>
      switch (category) {
        'electricity' => l10n.electricityFactor,
        'transport' => l10n.transportFactor,
        _ => throw ArgumentError.value(
          category,
          'category',
          'Unknown estimate factor category',
        ),
      };
}

class _AvailableRing extends StatefulWidget {
  const _AvailableRing({required this.estimate, required this.reference});

  final CompleteEstimate estimate;
  final ReferenceComparisonResult reference;

  @override
  State<_AvailableRing> createState() => _AvailableRingState();
}

class _AvailableRingState extends State<_AvailableRing>
    with SingleTickerProviderStateMixin {
  late final SpringMotionController _motion;
  bool? _reducedMotion;
  double? _lastTarget;

  double get _targetRatio => (widget.estimate.value / widget.reference.value!)
      .clamp(0.0, 1.0)
      .toDouble();

  @override
  void initState() {
    super.initState();
    _motion = SpringMotionController(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (_reducedMotion != reducedMotion || _lastTarget == null) {
      _reducedMotion = reducedMotion;
      _retarget();
    }
  }

  @override
  void didUpdateWidget(covariant _AvailableRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.estimate.value != widget.estimate.value ||
        oldWidget.reference.value != widget.reference.value) {
      _retarget();
    }
  }

  void _retarget() {
    final target = _targetRatio;
    if (_lastTarget == target && _reducedMotion == true) return;
    _lastTarget = target;
    _motion.retarget(
      target,
      reducedMotion: _reducedMotion ?? MediaQuery.disableAnimationsOf(context),
    );
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final target = widget.reference.value!;

    return AnimatedBuilder(
      animation: _motion.controller,
      builder: (context, child) {
        final ratio = _motion.controller.value;
        return Row(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Semantics(
                excludeSemantics: true,
                child: PieChart(
                  PieChartData(
                    startDegreeOffset: -90,
                    centerSpaceRadius: 38,
                    sectionsSpace: 2,
                    sections: [
                      PieChartSectionData(
                        value: ratio,
                        color: Theme.of(context).colorScheme.primary,
                        radius: 14,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: 1 - ratio,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        radius: 14,
                        showTitle: false,
                      ),
                    ],
                  ),
                  duration: Duration.zero,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.referenceShare(
                  (math.max(widget.estimate.value / target, 0) * 100).round(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
