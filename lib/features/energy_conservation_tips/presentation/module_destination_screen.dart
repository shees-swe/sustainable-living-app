import 'package:flutter/material.dart';

import '../../../core/accessibility/motion_aware_progress_indicator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_tokens.dart';
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
    final verdant = Theme.of(context).extension<VerdantColors>()!;
    return Scaffold(
      backgroundColor: verdant.cream,
      appBar: AppBar(
        backgroundColor: verdant.forestGreen,
        foregroundColor: Colors.white,
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(
          l10n.energyConservationTips,
          maxLines: 2,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        scrolledUnderElevation: 0,
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
    final verdant = theme.extension<VerdantColors>()!;
    final tips = catalog.filter(query: _query, category: _category);
    return ListView(
      key: const ValueKey('energyTipsList'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Search & filter card
        Container(
          decoration: DesignTokens.sectionCard(context),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                key: const ValueKey('energyTipSearchField'),
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  labelText: l10n.energyTipSearchLabel,
                  prefixIcon: const Icon(Icons.search),
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
              const SizedBox(height: 12),
              Text(
                l10n.energyTipCategoryFilter,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: ClimateColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
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
        const SizedBox(height: 16),
        if (tips.isEmpty) ...[
          Container(
            decoration: DesignTokens.sectionCard(context),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 48,
                  color: verdant.forestGreen.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.energyTipNoMatches,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: ClimateColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _clearFilters,
                  child: Text(l10n.energyTipClearFilters),
                ),
              ],
            ),
          ),
        ] else ...[
          Container(
            decoration: DesignTokens.sectionCard(context),
            child: Column(
              children: [
                for (var index = 0; index < tips.length; index++) ...[
                  _EnergyTipRow(tip: tips[index]),
                  if (index < tips.length - 1)
                    const Divider(height: 1, indent: 16, endIndent: 16),
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
    final verdant = theme.extension<VerdantColors>()!;
    return Padding(
      key: ValueKey('energyTip-${tip.title}'),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: ClimateSpacing.space16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(tip.title, style: theme.textTheme.titleSmall),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: verdant.tagBackground,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tip.category,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: verdant.forestGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        height: 1.5,
      ),
    );
  }
}
