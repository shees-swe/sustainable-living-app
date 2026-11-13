import 'package:flutter/material.dart';

import '../../../core/accessibility/motion_aware_progress_indicator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/design_components.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/energy_tip_catalog.dart';

class EnergyConservationTipsScreen extends StatefulWidget {
  const EnergyConservationTipsScreen({this.catalog, super.key});

  final EnergyTipCatalog? catalog;

  @override
  State<EnergyConservationTipsScreen> createState() =>
      _EnergyConservationTipsScreenState();
}

class _EnergyConservationTipsScreenState
    extends State<EnergyConservationTipsScreen> {
  static const _allCategoriesValue = '';

  late final Future<EnergyTipCatalog> _catalog;
  final _searchController = TextEditingController();
  String _query = '';
  String? _category;

  @override
  void initState() {
    super.initState();
    _catalog = widget.catalog == null
        ? EnergyTipCatalog.loadBundled()
        : Future.value(widget.catalog!);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(l10n.energyConservationTips, maxLines: 2),
      ),
      body: FutureBuilder<EnergyTipCatalog>(
        future: _catalog,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(ClimateSpacing.space16),
                child: Text(
                  '${l10n.energyTipCatalogLoadFailure}\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final catalog = snapshot.data;
          if (catalog == null) {
            return Center(
              child: MotionAwareProgressIndicator(semanticsLabel: l10n.loading),
            );
          }
          return _buildTips(context, l10n, catalog);
        },
      ),
    );
  }

  Widget _buildTips(
    BuildContext context,
    AppLocalizations l10n,
    EnergyTipCatalog catalog,
  ) {
    final theme = Theme.of(context);
    final tips = catalog.filter(query: _query, category: _category);
    return ListView(
      key: const ValueKey('energyTipsList'),
      padding: const EdgeInsets.symmetric(
        horizontal: ClimateSpacing.space16,
        vertical: ClimateSpacing.space16,
      ),
      children: [
        AppPanel(
          color: DesignTokens.surfaceBlue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                key: const ValueKey('energyTipSearchField'),
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  label: Text(l10n.energyTipSearchLabel, softWrap: true),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: l10n.energyTipClearSearch,
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.clear),
                        ),
                ),
              ),
              const SizedBox(height: DesignTokens.space16),
              Text(
                l10n.energyTipCategoryFilter,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: ClimateColors.textSecondary,
                ),
              ),
              const SizedBox(height: DesignTokens.space8),
              DropdownButtonFormField<String>(
                key: const ValueKey('energyTipCategoryFilter'),
                initialValue: _category ?? _allCategoriesValue,
                isExpanded: true,
                decoration: const InputDecoration(),
                items: [
                  DropdownMenuItem(
                    value: _allCategoriesValue,
                    child: Text(l10n.energyTipAllCategories, maxLines: 2),
                  ),
                  for (final category in catalog.categories)
                    DropdownMenuItem(
                      value: category,
                      child: Text(category, maxLines: 2),
                    ),
                ],
                onChanged: (value) => setState(
                  () => _category = value == _allCategoriesValue ? null : value,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DesignTokens.space24),
        if (tips.isEmpty) ...[
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.energyTipNoMatches),
                const SizedBox(height: DesignTokens.space8),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    onPressed: _clearFilters,
                    child: Text(l10n.energyTipClearFilters),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          AppPanel(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var index = 0; index < tips.length; index++) ...[
                  _EnergyTipRow(tip: tips[index]),
                  if (index < tips.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _category = null;
    });
  }
}

class _EnergyTipRow extends StatelessWidget {
  const _EnergyTipRow({required this.tip});

  final EnergyTip tip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      key: ValueKey('energyTip-${tip.title}'),
      padding: const EdgeInsets.symmetric(vertical: ClimateSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tip.title, style: theme.textTheme.titleMedium),
          const SizedBox(height: ClimateSpacing.space8),
          Text(
            tip.category,
            style: theme.textTheme.bodySmall?.copyWith(
              color: ClimateColors.textSecondary,
            ),
          ),
          const SizedBox(height: ClimateSpacing.space8),
          _EnergyTipText(tip.text),
        ],
      ),
    );
  }
}

class _EnergyTipText extends StatelessWidget {
  const _EnergyTipText(this.text);

  final String text;

  static final _numberAndUnit = RegExp(r'[−-]?\d+(?:[.,]\d+)*(?:\s*°C)?');

  @override
  Widget build(BuildContext context) {
    final numberStyle = Theme.of(context)
        .extension<ClimateTypography>()!
        .number;
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in _numberAndUnit.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      spans.add(TextSpan(text: match.group(0), style: numberStyle));
      cursor = match.end;
    }
    if (cursor < text.length) spans.add(TextSpan(text: text.substring(cursor)));
    return Text.rich(
      TextSpan(children: spans),
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}
