import 'package:flutter/material.dart';

import '../../../core/accessibility/motion_aware_progress_indicator.dart';
import '../../../core/accessibility/reduced_motion.dart';
import '../../../core/motion/motion_spec.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/design_components.dart';
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
    return Scaffold(
      appBar: AppBar(
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(l10n.recipesMealPlanning, maxLines: 2),
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
    final numberStyle = theme.extension<ClimateTypography>()!.number;
    return ListView(
      key: const ValueKey('recipeCatalogList'),
      padding: const EdgeInsets.symmetric(
        horizontal: ClimateSpacing.space16,
        vertical: ClimateSpacing.space16,
      ),
      children: [
        AppPanel(
          color: DesignTokens.surfaceSun,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                key: const ValueKey('recipeSearchField'),
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  label: Text(l10n.recipeSearchLabel, softWrap: true),
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
              const SizedBox(height: DesignTokens.space16),
              Text(
                l10n.recipeSeasonFilter,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: ClimateColors.textSecondary,
                ),
              ),
              const SizedBox(height: DesignTokens.space8),
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
        const SizedBox(height: DesignTokens.space24),
        if (recipes.isEmpty) ...[
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.recipeNoMatches),
                const SizedBox(height: DesignTokens.space8),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    onPressed: _clearFilters,
                    child: Text(l10n.recipeClearFilters),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          for (var index = 0; index < recipes.length; index++) ...[
            AppPanel(
              padding: EdgeInsets.zero,
              child: _RecipeRow(
                recipe: recipes[index],
                numberStyle: numberStyle,
                onTap: () => _openDetails(context, recipes[index]),
              ),
            ),
            if (index < recipes.length - 1)
              const SizedBox(height: DesignTokens.space12),
          ],
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
    return InkWell(
      key: ValueKey('recipe-${recipe.name}'),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: ClimateSpacing.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(recipe.name, style: theme.textTheme.titleMedium),
            const SizedBox(height: ClimateSpacing.space8),
            Wrap(
              spacing: ClimateSpacing.space16,
              runSpacing: ClimateSpacing.space8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(recipe.preparationTime, style: numberStyle),
                Text(
                  recipe.season,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: ClimateColors.textSecondary,
                  ),
                ),
              ],
            ),
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
    final numberStyle = theme.extension<ClimateTypography>()!.number;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(l10n.recipeDetail, maxLines: 2),
      ),
      body: ListView(
        key: const ValueKey('recipeDetailList'),
        padding: const EdgeInsets.symmetric(
          horizontal: ClimateSpacing.space16,
          vertical: ClimateSpacing.space16,
        ),
        children: [
          AppPanel(
            color: DesignTokens.surfaceCoral,
            padding: const EdgeInsets.all(DesignTokens.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppIconBadge(
                  icon: Icons.restaurant_outlined,
                  backgroundColor: DesignTokens.surface,
                  foregroundColor: DesignTokens.coral,
                ),
                const SizedBox(height: DesignTokens.space16),
                Text(recipe.name, style: theme.textTheme.headlineSmall),
                const SizedBox(height: DesignTokens.space16),
                Wrap(
                  spacing: DesignTokens.space16,
                  runSpacing: DesignTokens.space12,
                  children: [
                    _RecipeMetadata(
                      label: l10n.recipePreparationTime,
                      value: recipe.preparationTime,
                    ),
                    _RecipeMetadata(
                      label: l10n.recipeServings,
                      value: recipe.servings,
                    ),
                    _RecipeMetadata(
                      label: l10n.recipeSeasonFilter,
                      value: recipe.season,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: ClimateSpacing.space16),
          AppPanel(
            color: DesignTokens.surfaceBlue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSectionHeading(title: l10n.recipeSeasonalNote),
                const SizedBox(height: DesignTokens.space8),
                _RecipeRichText(recipe.seasonalNote),
              ],
            ),
          ),
          const SizedBox(height: ClimateSpacing.space24),
          AppPanel(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(DesignTokens.space16),
                  child: AppSectionHeading(title: l10n.recipeIngredients),
                ),
                for (
                  var index = 0;
                  index < recipe.ingredients.length;
                  index++
                ) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(DesignTokens.space16),
                    child: _RecipeRichText(recipe.ingredients[index]),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: ClimateSpacing.space24),
          AppPanel(
            color: DesignTokens.surfaceSun,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(DesignTokens.space16),
                  child: AppSectionHeading(title: l10n.recipeSteps),
                ),
                for (var index = 0; index < recipe.steps.length; index++) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(DesignTokens.space16),
                    child: _RecipeStepText(
                      recipe.steps[index],
                      numberStyle: numberStyle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeMetadata extends StatelessWidget {
  const _RecipeMetadata({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: ClimateColors.textSecondary,
          ),
        ),
        const SizedBox(height: ClimateSpacing.space8),
        Text(value, style: theme.extension<ClimateTypography>()!.number),
      ],
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
