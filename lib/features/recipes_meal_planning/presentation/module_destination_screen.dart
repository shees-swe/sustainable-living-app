import 'package:flutter/material.dart';

import '../../../core/accessibility/motion_aware_progress_indicator.dart';
import '../../../core/accessibility/reduced_motion.dart';
import '../../../core/motion/motion_spec.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/recipe_catalog.dart';

class RecipesMealPlanningScreen extends StatefulWidget {
  const RecipesMealPlanningScreen({this.catalog, super.key});

  final RecipeCatalog? catalog;

  @override
  State<RecipesMealPlanningScreen> createState() =>
      _RecipesMealPlanningScreenState();
}

class _RecipesMealPlanningScreenState extends State<RecipesMealPlanningScreen> {
  late final Future<RecipeCatalog> _catalog;
  final _searchController = TextEditingController();
  String _query = '';
  String _season = RecipeCatalog.allSeasons;

  @override
  void initState() {
    super.initState();
    _catalog = widget.catalog == null
        ? RecipeCatalog.loadBundled()
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
          l10n.recipesMealPlanning,
          maxLines: 2,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: FutureBuilder<RecipeCatalog>(
        future: _catalog,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(ClimateSpacing.space16),
                child: Text(
                  '${l10n.recipeCatalogLoadFailure}\n${snapshot.error}',
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
          return _buildRecipes(context, l10n, catalog);
        },
      ),
    );
  }

  Widget _buildRecipes(
    BuildContext context,
    AppLocalizations l10n,
    RecipeCatalog catalog,
  ) {
    final recipes = catalog.filter(query: _query, season: _season);
    final theme = Theme.of(context);
    final verdant = theme.extension<VerdantColors>()!;
    final numberStyle = theme.extension<ClimateTypography>()!.number;
    return ListView(
      key: const ValueKey('recipeCatalogList'),
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
                key: const ValueKey('recipeSearchField'),
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  labelText: l10n.recipeSearchLabel,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: l10n.recipeClearSearch,
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
                l10n.recipeSeasonFilter,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: ClimateColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                key: const ValueKey('recipeSeasonFilter'),
                initialValue: _season,
                isExpanded: true,
                decoration: const InputDecoration(),
                items: [
                  for (final season in catalog.seasons)
                    DropdownMenuItem(
                      value: season,
                      child: Text(season, maxLines: 2),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _season = value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (recipes.isEmpty) ...[
          Container(
            decoration: DesignTokens.sectionCard(context),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.soup_kitchen_outlined,
                  size: 48,
                  color: verdant.forestGreen.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.recipeNoMatches,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: ClimateColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _clearFilters,
                  child: Text(l10n.recipeClearFilters),
                ),
              ],
            ),
          ),
        ] else ...[
          Container(
            decoration: DesignTokens.sectionCard(context),
            child: Column(
              children: [
                for (var index = 0; index < recipes.length; index++) ...[
                  _RecipeRow(
                    recipe: recipes[index],
                    numberStyle: numberStyle,
                    onTap: () => _openDetails(context, recipes[index]),
                  ),
                  if (index < recipes.length - 1)
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
      _season = RecipeCatalog.allSeasons;
    });
  }

  void _openDetails(BuildContext context, Recipe recipe) {
    Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _RecipeDetailScreen(recipe: recipe),
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

class _RecipeRow extends StatelessWidget {
  const _RecipeRow({
    required this.recipe,
    required this.numberStyle,
    required this.onTap,
  });

  final Recipe recipe;
  final TextStyle numberStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verdant = theme.extension<VerdantColors>()!;
    return InkWell(
      key: ValueKey('recipe-${recipe.name}'),
      onTap: onTap,
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
                  Text(recipe.name, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: ClimateSpacing.space12,
                    runSpacing: ClimateSpacing.space4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: ClimateColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(recipe.preparationTime, style: numberStyle),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: verdant.tagBackground,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          recipe.season,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: verdant.forestGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: ClimateColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _RecipeDetailScreen extends StatelessWidget {
  const _RecipeDetailScreen({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final verdant = theme.extension<VerdantColors>()!;
    final numberStyle = theme.extension<ClimateTypography>()!.number;
    return Scaffold(
      backgroundColor: verdant.cream,
      appBar: AppBar(
        backgroundColor: verdant.forestGreen,
        foregroundColor: Colors.white,
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(
          l10n.recipeDetail,
          maxLines: 2,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        key: const ValueKey('recipeDetailList'),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // Hero title card
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
                Text(
                  recipe.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _DetailBadge(
                      icon: Icons.schedule,
                      label: recipe.preparationTime,
                    ),
                    _DetailBadge(
                      icon: Icons.people_outline,
                      label: recipe.servings,
                    ),
                    _DetailBadge(
                      icon: Icons.eco_outlined,
                      label: recipe.season,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Seasonal note
          Container(
            decoration: BoxDecoration(
              color: verdant.forestLight,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              border: Border.all(
                color: verdant.forestGreen.withValues(alpha: 0.2),
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.recipeSeasonalNote,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: verdant.forestGreen,
                  ),
                ),
                const SizedBox(height: 6),
                _RecipeRichText(recipe.seasonalNote),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Ingredients
          Container(
            decoration: DesignTokens.sectionCard(context),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.recipeIngredients,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: verdant.forestGreen,
                  ),
                ),
                const SizedBox(height: 8),
                for (
                  var index = 0;
                  index < recipe.ingredients.length;
                  index++
                ) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: ClimateSpacing.space8,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: verdant.forestGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _RecipeRichText(recipe.ingredients[index]),
                        ),
                      ],
                    ),
                  ),
                  if (index < recipe.ingredients.length - 1)
                    const Divider(height: 1),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Steps
          Container(
            decoration: DesignTokens.sectionCard(context),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.recipeSteps,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: verdant.forestGreen,
                  ),
                ),
                const SizedBox(height: 8),
                for (var index = 0; index < recipe.steps.length; index++) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: ClimateSpacing.space12,
                    ),
                    child: _RecipeStepText(
                      recipe.steps[index],
                      numberStyle: numberStyle,
                    ),
                  ),
                  if (index < recipe.steps.length - 1)
                    const Divider(height: 1),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailBadge extends StatelessWidget {
  const _DetailBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeStepText extends StatelessWidget {
  const _RecipeStepText(this.step, {required this.numberStyle});

  final String step;
  final TextStyle numberStyle;

  static final _stepNumber = RegExp(r'^(\d+\.)\s*(.*)$');

  @override
  Widget build(BuildContext context) {
    final match = _stepNumber.firstMatch(step);
    if (match == null) return _RecipeRichText(step);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: match.group(1), style: numberStyle),
          const TextSpan(text: ' '),
          ..._recipeTextSpans(context, match.group(2)!),
        ],
      ),
    );
  }
}

class _RecipeRichText extends StatelessWidget {
  const _RecipeRichText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text.rich(TextSpan(children: _recipeTextSpans(context, text)));
}

List<InlineSpan> _recipeTextSpans(BuildContext context, String text) {
  final numberStyle = Theme.of(context).extension<ClimateTypography>()!.number;
  final pattern = RegExp(
    r'\d+(?:[.,]\d+)*(?:[–-]\d+(?:[.,]\d+)*'
    r')?(?:\s*(?:g|ml|tsp|tbsp|litre|min|minutes|hour|hours))?',
    caseSensitive: false,
  );
  final spans = <InlineSpan>[];
  var cursor = 0;
  for (final match in pattern.allMatches(text)) {
    if (match.start > cursor) {
      spans.add(TextSpan(text: text.substring(cursor, match.start)));
    }
    spans.add(TextSpan(text: match.group(0), style: numberStyle));
    cursor = match.end;
  }
  if (cursor < text.length) {
    spans.add(TextSpan(text: text.substring(cursor)));
  }
  return spans;
}
