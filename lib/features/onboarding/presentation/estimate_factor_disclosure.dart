import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/footprint_estimate.dart';

class EstimateFactorDisclosure extends StatelessWidget {
  const EstimateFactorDisclosure({
    required this.factors,
    required this.demoOnly,
    super.key,
  });

  final List<EmissionFactor> factors;
  final bool demoOnly;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final numberStyle = Theme.of(context)
        .extension<ClimateTypography>()!
        .number;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.factorsUsedInEstimate,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (demoOnly) DemoOnlyTag(label: l10n.demoOnlyTag),
          ],
        ),
        for (var index = 0; index < factors.length; index++) ...[
          if (index > 0) const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: ClimateSpacing.space8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            '${_factorCategory(l10n, factors[index].category)}: ',
                      ),
                      TextSpan(
                        text: factors[index].value.toString(),
                        style: numberStyle,
                      ),
                      TextSpan(
                        text:
                            ' ${factors[index].numeratorUnit} per '
                            '${factors[index].denominatorUnit}',
                        style: numberStyle,
                      ),
                    ],
                  ),
                ),
                MonoNumericText(
                  text: l10n.factorSourceDetails(
                    factors[index].source.title,
                    factors[index].source.publisher ??
                        factors[index].source.title,
                  ),
                ),
                MonoNumericText(
                  text: l10n.publicationYear(
                    factors[index].source.publicationYear,
                  ),
                ),
                MonoNumericText(
                  text: l10n.factorValidFrom(factors[index].validFrom),
                ),
                MonoNumericText(text: factors[index].methodology),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _factorCategory(AppLocalizations l10n, String category) =>
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
}

class DemoOnlyTag extends StatelessWidget {
  const DemoOnlyTag({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Theme.of(context).colorScheme.error,
      fontWeight: FontWeight.w600,
    ),
  );
}

class MonoNumericText extends StatelessWidget {
  const MonoNumericText({required this.text, super.key});

  final String text;

  static final _numberOrUnitPattern = RegExp(
    r'\d+(?:[.,]\d+)*(?:°[A-Za-z]*)?|(?:kg|t)\s+CO2e?(?:/person)?(?:/year)?|kWh|km|%',
  );

  @override
  Widget build(BuildContext context) {
    final numberStyle = Theme.of(context)
        .extension<ClimateTypography>()!
        .number;
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in _numberOrUnitPattern.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      spans.add(TextSpan(text: match.group(0), style: numberStyle));
      cursor = match.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }
    return Text.rich(TextSpan(children: spans));
  }
}
