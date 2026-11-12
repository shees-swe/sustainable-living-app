import 'package:flutter/material.dart';

import '../../../core/accessibility/reduced_motion.dart';
import '../../../core/motion/motion_spec.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/certification_catalog.dart';

class CertificationsGuideScreen extends StatefulWidget {
  const CertificationsGuideScreen({required this.catalog, super.key});

  final CertificationCatalog catalog;

  @override
  State<CertificationsGuideScreen> createState() =>
      _CertificationsGuideScreenState();
}

class _CertificationsGuideScreenState extends State<CertificationsGuideScreen> {
  static const _allCategoriesValue = '';

  final _searchController = TextEditingController();
  String _query = '';
  String? _category;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final verdant = theme.extension<VerdantColors>()!;
    final certifications = widget.catalog.filter(
      query: _query,
      category: _category,
    );

    return Scaffold(
      backgroundColor: verdant.cream,
      appBar: AppBar(
        backgroundColor: verdant.forestGreen,
        foregroundColor: Colors.white,
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(
          l10n.certificationsGuide,
          maxLines: 2,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        key: const ValueKey('certificationDirectoryList'),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // Info card
          Container(
            decoration: BoxDecoration(
              color: verdant.forestLight,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              border: Border.all(
                color: verdant.forestGreen.withValues(alpha: 0.2),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.certificationsSection,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: verdant.forestGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.certificationDisclaimer,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: ClimateColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Search & filter card
          Container(
            decoration: DesignTokens.sectionCard(context),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  key: const ValueKey('certificationSearchField'),
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    labelText: l10n.certificationSearchLabel,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: l10n.certificationClearSearch,
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
                  l10n.certificationCategoryFilter,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: ClimateColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  key: const ValueKey('certificationCategoryFilter'),
                  initialValue: _category ?? _allCategoriesValue,
                  isExpanded: true,
                  decoration: const InputDecoration(),
                  items: [
                    DropdownMenuItem(
                      value: _allCategoriesValue,
                      child: Text(l10n.certificationAllCategories),
                    ),
                    for (final category in widget.catalog.categories)
                      DropdownMenuItem(
                        value: category,
                        child: Text(category, maxLines: 2),
                      ),
                  ],
                  onChanged: (value) => setState(
                    () =>
                        _category = value == _allCategoriesValue ? null : value,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Certifications list
          if (certifications.isEmpty) ...[
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
                    l10n.certificationNoMatches,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: ClimateColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _clearFilters,
                    child: Text(l10n.certificationClearFilters),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              decoration: DesignTokens.sectionCard(context),
              child: Column(
                children: [
                  for (
                    var index = 0;
                    index < certifications.length;
                    index++
                  ) ...[
                    _CertificationRow(
                      certification: certifications[index],
                      onTap: () => _openDetails(context, certifications[index]),
                    ),
                    if (index < certifications.length - 1)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          // Brand check guide card
          Container(
            decoration: DesignTokens.sectionCard(context),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.checkBrandSection,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: verdant.forestGreen,
                  ),
                ),
                const SizedBox(height: 12),
                for (
                  var index = 0;
                  index < widget.catalog.guidePoints.length;
                  index++
                ) ...[
                  _GuidePointRow(
                    number: index + 1,
                    point: widget.catalog.guidePoints[index],
                  ),
                  if (index < widget.catalog.guidePoints.length - 1)
                    const Divider(height: 1),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _category = null;
    });
  }

  void _openDetails(BuildContext context, Certification certification) {
    Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _CertificationDetailScreen(certification: certification),
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

class _CertificationRow extends StatelessWidget {
  const _CertificationRow({required this.certification, required this.onTap});

  final Certification certification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verdant = theme.extension<VerdantColors>()!;
    return InkWell(
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
                  _DirectoryText(
                    certification.name,
                    style: theme.textTheme.titleSmall,
                  ),
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
                    child: _DirectoryText(
                      certification.category,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: verdant.forestGreen,
                      ),
                    ),
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

class _GuidePointRow extends StatelessWidget {
  const _GuidePointRow({required this.number, required this.point});

  final int number;
  final BrandCheckPoint point;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verdant = theme.extension<VerdantColors>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ClimateSpacing.space16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: verdant.forestGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DirectoryText(point.title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                _DirectoryText(
                  point.text,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: ClimateColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CertificationDetailScreen extends StatelessWidget {
  const _CertificationDetailScreen({required this.certification});

  final Certification certification;

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
          l10n.certificationDetail,
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
                _DirectoryText(
                  certification.name,
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
                  child: _DirectoryText(
                    certification.category,
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
                  l10n.certificationMeaningLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: verdant.forestGreen,
                  ),
                ),
                const SizedBox(height: 8),
                _DirectoryText(certification.meaning),
                const SizedBox(height: 16),
                Text(
                  l10n.certificationWhereSeenLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: verdant.forestGreen,
                  ),
                ),
                const SizedBox(height: 8),
                _DirectoryText(certification.whereSeen),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectoryText extends StatelessWidget {
  const _DirectoryText(this.text, {this.style});

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
