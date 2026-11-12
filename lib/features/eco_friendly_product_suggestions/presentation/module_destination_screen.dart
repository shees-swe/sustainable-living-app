import 'package:flutter/material.dart';

import '../../../core/accessibility/motion_aware_progress_indicator.dart';
import '../../../core/accessibility/reduced_motion.dart';
import '../../../core/motion/motion_spec.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/product_catalog.dart';

class EcoFriendlyProductSuggestionsScreen extends StatefulWidget {
  const EcoFriendlyProductSuggestionsScreen({this.catalog, super.key});

  final ProductCatalog? catalog;

  @override
  State<EcoFriendlyProductSuggestionsScreen> createState() =>
      _EcoFriendlyProductSuggestionsScreenState();
}

class _EcoFriendlyProductSuggestionsScreenState
    extends State<EcoFriendlyProductSuggestionsScreen> {
  static const _allCategoriesValue = '';

  late final Future<ProductCatalog> _catalog;
  final _searchController = TextEditingController();
  String _query = '';
  String? _category;
  ProductSortOrder _sortOrder = ProductSortOrder.ascending;

  @override
  void initState() {
    super.initState();
    _catalog = widget.catalog == null
        ? ProductCatalog.loadBundled()
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
          l10n.ecoFriendlyProductSuggestions,
          maxLines: 2,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: FutureBuilder<ProductCatalog>(
        future: _catalog,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(ClimateSpacing.space16),
                child: Text(
                  '${l10n.productCatalogLoadFailure}\n${snapshot.error}',
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
          return _buildCatalog(context, l10n, catalog);
        },
      ),
    );
  }

  Widget _buildCatalog(
    BuildContext context,
    AppLocalizations l10n,
    ProductCatalog catalog,
  ) {
    final verdant = Theme.of(context).extension<VerdantColors>()!;
    final products = catalog.filter(
      query: _query,
      category: _category,
      sort: _sortOrder,
    );
    return ListView(
      key: const ValueKey('productCatalogList'),
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
                key: const ValueKey('productSearchField'),
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  labelText: l10n.productSearchLabel,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: l10n.productClearSearch,
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.clear),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.productCategoryFilter,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: ClimateColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          key: const ValueKey('productCategoryFilter'),
                          initialValue: _category ?? _allCategoriesValue,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: _allCategoriesValue,
                              child: Text(l10n.productAllCategories),
                            ),
                            for (final category in ProductCatalog.categories)
                              DropdownMenuItem(
                                value: category,
                                child: Text(category, maxLines: 2),
                              ),
                          ],
                          onChanged: (value) => setState(
                            () => _category =
                                value == _allCategoriesValue ? null : value,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.productSortLabel,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: ClimateColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<ProductSortOrder>(
                          key: const ValueKey('productSortFilter'),
                          initialValue: _sortOrder,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: ProductSortOrder.ascending,
                              child: Text(l10n.productSortAscending),
                            ),
                            DropdownMenuItem(
                              value: ProductSortOrder.descending,
                              child: Text(l10n.productSortDescending),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _sortOrder = value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Results
        if (products.isEmpty) ...[
          Container(
            decoration: DesignTokens.sectionCard(context),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: verdant.forestGreen.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.productNoMatches,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ClimateColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _clearFilters,
                  child: Text(l10n.productClearFilters),
                ),
              ],
            ),
          ),
        ] else ...[
          Container(
            decoration: DesignTokens.sectionCard(context),
            child: Column(
              children: [
                for (var index = 0; index < products.length; index++) ...[
                  _ProductRow(
                    product: products[index],
                    onTap: () => _openDetails(context, products[index]),
                  ),
                  if (index < products.length - 1)
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
      _sortOrder = ProductSortOrder.ascending;
    });
  }

  void _openDetails(BuildContext context, SuggestedProduct product) {
    Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _ProductDetailScreen(product: product),
        transitionDuration: ReducedMotion.duration(
          context,
          MotionSpec.optionalFade,
        ),
        reverseTransitionDuration: ReducedMotion.duration(
          context,
          MotionSpec.optionalFade,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation.drive(
                CurveTween(curve: MotionSpec.optionalFadeCurve),
              ),
              child: child,
            ),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product, required this.onTap});

  final SuggestedProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verdant = theme.extension<VerdantColors>()!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: ClimateSpacing.space16,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CatalogText(product.name, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: verdant.tagBackground,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: _CatalogText(
                      product.category,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: verdant.forestGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _CatalogText(
                    product.note,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ClimateColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: ClimateColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductDetailScreen extends StatelessWidget {
  const _ProductDetailScreen({required this.product});

  final SuggestedProduct product;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final verdant = theme.extension<VerdantColors>()!;
    return Scaffold(
      backgroundColor: verdant.cream,
      appBar: AppBar(
        backgroundColor: verdant.forestGreen,
        foregroundColor: Colors.white,
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(
          l10n.productDetail,
          maxLines: 2,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [verdant.forestGreen, verdant.forestDeep],
              ),
              borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CatalogText(
                  product.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: _CatalogText(
                    product.category,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: DesignTokens.sectionCard(context),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.productNoteLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: verdant.forestGreen,
                  ),
                ),
                const SizedBox(height: 8),
                _CatalogText(
                  product.note,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogText extends StatelessWidget {
  const _CatalogText(this.text, {this.style});

  final String text;
  final TextStyle? style;

  static final _numberPattern = RegExp(r'\d+(?:[.,]\d+)*(?:%|W)?');

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
