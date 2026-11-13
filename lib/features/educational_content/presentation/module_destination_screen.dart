import 'package:flutter/material.dart';

import '../../../core/accessibility/motion_aware_progress_indicator.dart';
import '../../../core/accessibility/reduced_motion.dart';
import '../../../core/motion/motion_spec.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/design_components.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/educational_article_catalog.dart';

class EducationalContentScreen extends StatefulWidget {
  const EducationalContentScreen({this.catalog, super.key});

  final EducationalArticleCatalog? catalog;

  @override
  State<EducationalContentScreen> createState() =>
      _EducationalContentScreenState();
}

class _EducationalContentScreenState extends State<EducationalContentScreen> {
  static const _allTopicsValue = '';

  late final Future<EducationalArticleCatalog> _catalog;
  final _searchController = TextEditingController();
  String _query = '';
  String? _topic;
  EducationalArticleSortOrder _sortOrder = EducationalArticleSortOrder.title;

  @override
  void initState() {
    super.initState();
    _catalog = widget.catalog == null
        ? EducationalArticleCatalog.loadBundled()
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
        title: Text(l10n.educationalContent, maxLines: 2),
      ),
      body: FutureBuilder<EducationalArticleCatalog>(
        future: _catalog,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(ClimateSpacing.space16),
                child: Text(
                  '${l10n.educationalCatalogLoadFailure}\n${snapshot.error}',
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
          return _buildArticles(context, l10n, catalog);
        },
      ),
    );
  }

  Widget _buildArticles(
    BuildContext context,
    AppLocalizations l10n,
    EducationalArticleCatalog catalog,
  ) {
    final articles = catalog.filter(
      query: _query,
      topic: _topic,
      sort: _sortOrder,
    );
    return ListView(
      key: const ValueKey('educationalArticleList'),
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
                key: const ValueKey('educationalArticleSearchField'),
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  label: Text(l10n.educationalSearchLabel, softWrap: true),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: l10n.educationalClearSearch,
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.clear),
                        ),
                ),
              ),
              const SizedBox(height: DesignTokens.space16),
              _FilterField(
                label: l10n.educationalTopicFilter,
                child: DropdownButtonFormField<String>(
                  key: const ValueKey('educationalTopicFilter'),
                  initialValue: _topic ?? _allTopicsValue,
                  isExpanded: true,
                  decoration: const InputDecoration(),
                  items: [
                    DropdownMenuItem(
                      value: _allTopicsValue,
                      child: Text(l10n.educationalAllTopics, maxLines: 2),
                    ),
                    for (final topic in EducationalArticleCatalog.topics)
                      DropdownMenuItem(
                        value: topic,
                        child: Text(topic, maxLines: 2),
                      ),
                  ],
                  onChanged: (value) => setState(
                    () => _topic = value == _allTopicsValue ? null : value,
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.space16),
              _FilterField(
                label: l10n.educationalSortLabel,
                child: DropdownButtonFormField<EducationalArticleSortOrder>(
                  key: const ValueKey('educationalArticleSort'),
                  initialValue: _sortOrder,
                  isExpanded: true,
                  decoration: const InputDecoration(),
                  items: [
                    DropdownMenuItem(
                      value: EducationalArticleSortOrder.title,
                      child: Text(l10n.educationalSortTitle, maxLines: 2),
                    ),
                    DropdownMenuItem(
                      value: EducationalArticleSortOrder.shortestRead,
                      child: Text(
                        l10n.educationalSortShortestRead,
                        maxLines: 2,
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _sortOrder = value);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DesignTokens.space24),
        if (articles.isEmpty) ...[
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.educationalNoMatches),
                const SizedBox(height: DesignTokens.space8),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    onPressed: _clearFilters,
                    child: Text(l10n.educationalClearFilters),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          for (var index = 0; index < articles.length; index++) ...[
            AppPanel(
              padding: EdgeInsets.zero,
              child: _EducationalArticleRow(
                article: articles[index],
                onTap: () => _openArticle(context, articles[index]),
              ),
            ),
            if (index < articles.length - 1)
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
      _topic = null;
      _sortOrder = EducationalArticleSortOrder.title;
    });
  }

  void _openArticle(BuildContext context, EducationalArticle article) {
    Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _EducationalArticleScreen(article: article),
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

class _FilterField extends StatelessWidget {
  const _FilterField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: ClimateColors.textSecondary),
      ),
      const SizedBox(height: ClimateSpacing.space8),
      child,
    ],
  );
}

class _EducationalArticleRow extends StatelessWidget {
  const _EducationalArticleRow({required this.article, required this.onTap});

  final EducationalArticle article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        key: ValueKey('educationalArticle-${article.title}'),
        padding: const EdgeInsets.symmetric(vertical: ClimateSpacing.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(article.title, style: theme.textTheme.titleMedium),
            const SizedBox(height: ClimateSpacing.space8),
            Text(
              article.topic,
              style: theme.textTheme.bodySmall?.copyWith(
                color: ClimateColors.textSecondary,
              ),
            ),
            const SizedBox(height: ClimateSpacing.space8),
            _ReadingTime(minutes: article.readingTimeMinutes),
          ],
        ),
      ),
    );
  }
}

class _ReadingTime extends StatelessWidget {
  const _ReadingTime({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = Theme.of(context).extension<ClimateTypography>()!;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$minutes', style: typography.number),
          TextSpan(
            text: ' ${l10n.educationalMinuteUnit}',
            style: typography.unit,
          ),
          TextSpan(text: ' ${l10n.educationalReadLabel}'),
        ],
      ),
    );
  }
}

class _EducationalArticleScreen extends StatelessWidget {
  const _EducationalArticleScreen({required this.article});

  final EducationalArticle article;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(l10n.educationalArticle, maxLines: 2),
      ),
      body: ListView(
        key: const ValueKey('educationalArticleDetail'),
        padding: const EdgeInsets.symmetric(
          horizontal: ClimateSpacing.space16,
          vertical: ClimateSpacing.space16,
        ),
        children: [
          AppPanel(
            color: DesignTokens.surfaceBlue,
            padding: const EdgeInsets.all(DesignTokens.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppIconBadge(
                  icon: Icons.menu_book_outlined,
                  backgroundColor: DesignTokens.surface,
                  foregroundColor: DesignTokens.blue,
                ),
                const SizedBox(height: DesignTokens.space16),
                Text(article.title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: DesignTokens.space16),
                Wrap(
                  spacing: DesignTokens.space16,
                  runSpacing: DesignTokens.space8,
                  children: [
                    Text(
                      article.topic,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ClimateColors.textSecondary,
                      ),
                    ),
                    _ReadingTime(minutes: article.readingTimeMinutes),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.space16),
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (
                  var index = 0;
                  index < article.paragraphs.length;
                  index++
                ) ...[
                  _ArticleText(article.paragraphs[index]),
                  if (index < article.paragraphs.length - 1)
                    const SizedBox(height: DesignTokens.space16),
                ],
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.space16),
          AppPanel(
            color: DesignTokens.surfaceSun,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSectionHeading(title: l10n.educationalTakeaway),
                const SizedBox(height: DesignTokens.space8),
                _ArticleText(article.takeaway),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleText extends StatelessWidget {
  const _ArticleText(this.text);

  final String text;

  static final _numberOrUnit = RegExp(
    r'\bkilowatt-hours?\b|\bCO2(?:e)?\b|\bkWh\b|\bkg\b|\btonnes?\b|\bdegrees?\b|'
    r'\d+(?:\.\d+)?',
  );

  @override
  Widget build(BuildContext context) {
    final numberStyle = Theme.of(context)
        .extension<ClimateTypography>()!
        .number;
    final spans = <TextSpan>[];
    var cursor = 0;
    for (final match in _numberOrUnit.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      spans.add(TextSpan(text: match.group(0), style: numberStyle));
      cursor = match.end;
    }
    if (cursor < text.length) spans.add(TextSpan(text: text.substring(cursor)));
    return Text.rich(TextSpan(children: spans));
  }
}
