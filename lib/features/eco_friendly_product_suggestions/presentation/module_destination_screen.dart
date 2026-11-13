import 'package:flutter/material.dart';

import '../../../core/accessibility/motion_aware_progress_indicator.dart';
import '../../../core/accessibility/reduced_motion.dart';
import '../../../core/motion/motion_spec.dart';
import '../../../core/theme/app_theme.dart';
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
    return Scaffold(
      appBar: AppBar(
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(l10n.ecoFriendlyProductSuggestions, maxLines: 2),
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
    final products = catalog.filter(
      query: _query,
      category: _category,
      sort: _sortOrder,
    );
    return ListView(
      key: const ValueKey('productCatalogList'),
      padding: const EdgeInsets.symmetric(
        horizontal: ClimateSpacing.space16,
        vertical: ClimateSpacing.space16,
      ),
      children: [
        TextField(
          key: const ValueKey('productSearchField'),
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            label: Text(l10n.productSearchLabel, maxLines: 2),
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
        const SizedBox(height: ClimateSpacing.space16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.productCategoryFilter,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: ClimateColors.textSecondary),
            ),
            const SizedBox(height: ClimateSpacing.space8),
            DropdownButtonFormField<String>(
              key: const ValueKey('productCategoryFilter'),
              initialValue: _category ?? _allCategoriesValue,
              isExpanded: true,
              decoration: const InputDecoration(),
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
                () => _category = value == _allCategoriesValue ? null : value,
              ),
            ),
          ],
        ),
        const SizedBox(height: ClimateSpacing.space16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.productSortLabel,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: ClimateColors.textSecondary),
            ),
            const SizedBox(height: ClimateSpacing.space8),
            DropdownButtonFormField<ProductSortOrder>(
              key: const ValueKey('productSortFilter'),
              initialValue: _sortOrder,
              isExpanded: true,
              decoration: const InputDecoration(),
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
                if (value != null) setState(() => _sortOrder = value);
              },
            ),
          ],
        ),
        const SizedBox(height: ClimateSpacing.space16),
        if (products.isEmpty) ...[
          Text(l10n.productNoMatches),
          const SizedBox(height: ClimateSpacing.space8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: _clearFilters,
              child: Text(l10n.productClearFilters),
            ),
          ),
        ] else ...[
          for (var index = 0; index < products.length; index++) ...[
            Card(
              child: _ProductRow(
                product: products[index],
                onTap: () => _openDetails(context, products[index]),
              ),
            ),
            if (index < products.length - 1)
              const SizedBox(height: ClimateSpacing.space8),
          ],
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
    return InkWell(
      borderRadius: BorderRadius.circular(ClimateSpacing.radiusLarge),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(ClimateSpacing.space16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: ClimateColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(ClimateSpacing.radiusSmall),
              ),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.shopping_bag_outlined),
              ),
            ),
            const SizedBox(width: ClimateSpacing.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CatalogText(
                    product.name,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: ClimateSpacing.space8),
                  _CatalogText(
                    product.category,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ClimateColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: ClimateSpacing.space8),
                  _CatalogText(product.note),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
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
    return Scaffold(
      appBar: AppBar(
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(l10n.productDetail, maxLines: 2),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: ClimateSpacing.space16,
          vertical: ClimateSpacing.space16,
        ),
        children: [
          _CatalogText(product.name, style: theme.textTheme.headlineSmall),
          const SizedBox(height: ClimateSpacing.space16),
          const Divider(height: 1),
          const SizedBox(height: ClimateSpacing.space16),
          Text(l10n.productCategoryFilter, style: theme.textTheme.titleMedium),
          const SizedBox(height: ClimateSpacing.space8),
          _CatalogText(product.category),
          const SizedBox(height: ClimateSpacing.space16),
          const Divider(height: 1),
          const SizedBox(height: ClimateSpacing.space16),
          Text(l10n.productNoteLabel, style: theme.textTheme.titleMedium),
          const SizedBox(height: ClimateSpacing.space8),
          _CatalogText(product.note),
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
