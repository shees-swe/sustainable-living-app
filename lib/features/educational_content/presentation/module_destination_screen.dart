import 'package:flutter/material.dart';

import '../../../core/accessibility/motion_aware_progress_indicator.dart';
import '../../../core/accessibility/reduced_motion.dart';
import '../../../core/motion/motion_spec.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_tokens.dart';
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
    final verdant = Theme.of(context).extension<VerdantColors>()!;
    return Scaffold(
      backgroundColor: verdant.cream,
      appBar: AppBar(
        backgroundColor: verdant.forestGreen,
        foregroundColor: Colors.white,
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(
          l10n.educationalContent,
          maxLines: 2,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        scrolledUnderElevation: 0,
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
    final verdant = Theme.of(context).extension<VerdantColors>()!;
    final articles = catalog.filter(
      query: _query,
      topic: _topic,
      sort: _sortOrder,
    );
    return ListView(
      key: const ValueKey('educationalArticleList'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Search & Filter Card
        Container(
          decoration: DesignTokens.sectionCard(context),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                key: const ValueKey('educationalArticleSearchField'),
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  labelText: l10n.educationalSearchLabel,
                  prefixIcon: const Icon(Icons.search),
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _FilterField(
                      label: l10n.educationalTopicFilter,
                      child: DropdownButtonFormField<String>(
                        key: const ValueKey('educationalTopicFilter'),
                        initialValue: _topic ?? _allTopicsValue,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
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
                          () => _topic =
                              value == _allTopicsValue ? null : value,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FilterField(
                      label: l10n.educationalSortLabel,
                      child: DropdownButtonFormField<EducationalArticleSortOrder>(
                        key: const ValueKey('educationalArticleSort'),
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
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (articles.isEmpty) ...[
          Container(
            decoration: DesignTokens.sectionCard(context),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.article_outlined,
                  size: 48,
                  color: verdant.forestGreen.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.educationalNoMatches,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ClimateColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _clearFilters,
                  child: Text(l10n.educationalClearFilters),
                ),
              ],
            ),
          ),
        ] else ...[
          Container(
            decoration: DesignTokens.sectionCard(context),
            child: Column(
              children: [
                for (var index = 0; index < articles.length; index++) ...[
                  _EducationalArticleRow(
                    article: articles[index],
                    onTap: () => _openArticle(context, articles[index]),
                  ),
                  if (index < articles.length - 1)
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
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: ClimateColors.textSecondary,
        ),
      ),
      const SizedBox(height: 4),
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
    final verdant = theme.extension<VerdantColors>()!;
    return InkWell(
      onTap: onTap,
      child: Padding(
        key: ValueKey('educationalArticle-${article.title}'),
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
                  Text(article.title, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: ClimateSpacing.space12,
                    runSpacing: ClimateSpacing.space4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
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
                          article.topic,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: verdant.forestGreen,
                          ),
                        ),
                      ),
                      _ReadingTime(minutes: article.readingTimeMinutes),
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

class _ReadingTime extends StatelessWidget {
  const _ReadingTime({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = Theme.of(context).extension<ClimateTypography>()!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timer_outlined, size: 14, color: ClimateColors.textSecondary),
        const SizedBox(width: 4),
        Text.rich(
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
          style: TextStyle(color: ClimateColors.textSecondary, fontSize: 12),
        ),
      ],
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
    final verdant = theme.extension<VerdantColors>()!;
    return Scaffold(
      backgroundColor: verdant.cream,
      appBar: AppBar(
        backgroundColor: verdant.forestGreen,
        foregroundColor: Colors.white,
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(
          l10n.educationalArticle,
          maxLines: 2,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        key: const ValueKey('educationalArticleDetail'),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // Hero article header
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
                  article.title,
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        article.topic,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '${article.readingTimeMinutes} ${l10n.educationalMinuteUnit} ${l10n.educationalReadLabel}',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
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
          // Paragraphs
          Container(
            decoration: DesignTokens.sectionCard(context),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < article.paragraphs.length; index++) ...[
                  _ArticleText(article.paragraphs[index]),
                  if (index < article.paragraphs.length - 1)
                    const SizedBox(height: ClimateSpacing.space16),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Key takeaway card
          Container(
            decoration: BoxDecoration(
              color: verdant.forestLight,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              border: Border.all(
                color: verdant.forestGreen.withValues(alpha: 0.3),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_rounded,
                      color: verdant.forestGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.educationalTakeaway,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: verdant.forestGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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
    return Text.rich(
      TextSpan(children: spans),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        height: 1.6,
      ),
    );
  }
}
