import 'package:flutter/material.dart';

import '../../../core/accessibility/reduced_motion.dart';
import '../../../core/motion/motion_spec.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/design_components.dart';
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
    final certifications = widget.catalog.filter(
      query: _query,
      category: _category,
    );

    return Scaffold(
      appBar: AppBar(
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(l10n.certificationsGuide, maxLines: 2),
      ),
      body: ListView(
        key: const ValueKey('certificationDirectoryList'),
        padding: const EdgeInsets.all(DesignTokens.space16),
        children: [
          AppPanel(
            color: DesignTokens.surfaceBlue,
            padding: const EdgeInsets.all(DesignTokens.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppIconBadge(
                  icon: Icons.verified_outlined,
                  backgroundColor: DesignTokens.surface,
                  foregroundColor: DesignTokens.blue,
                ),
                const SizedBox(height: DesignTokens.space16),
                Text(
                  l10n.certificationsSection,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: DesignTokens.space8),
                Text(
                  l10n.certificationDisclaimer,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: ClimateColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.space16),
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  key: const ValueKey('certificationSearchField'),
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    label: Text(l10n.certificationSearchLabel, softWrap: true),
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
                const SizedBox(height: DesignTokens.space16),
                Text(
                  l10n.certificationCategoryFilter,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: ClimateColors.textSecondary,
                  ),
                ),
                const SizedBox(height: DesignTokens.space8),
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
          const SizedBox(height: DesignTokens.space24),
          if (certifications.isEmpty) ...[
            AppPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.certificationNoMatches),
                  const SizedBox(height: DesignTokens.space8),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton(
                      onPressed: _clearFilters,
                      child: Text(l10n.certificationClearFilters),
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
                      const Divider(height: 1),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: DesignTokens.space24),
          AppSectionHeading(title: l10n.checkBrandSection),
          const SizedBox(height: DesignTokens.space12),
          AppPanel(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppIconBadge(
              icon: Icons.verified_outlined,
              backgroundColor: DesignTokens.surfaceBlue,
              foregroundColor: DesignTokens.blue,
              size: 44,
              iconSize: DesignTokens.iconSmall,
            ),
            const SizedBox(width: DesignTokens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DirectoryText(
                    certification.name,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: DesignTokens.space8),
                  _DirectoryText(
                    certification.category,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ClimateColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: DesignTokens.space8),
            Icon(
              Icons.arrow_forward,
              size: DesignTokens.iconSmall,
              color: theme.colorScheme.onSurfaceVariant,
            ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ClimateSpacing.space16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: ClimateSpacing.space32,
            child: _DirectoryText(
              '$number',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ClimateColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DirectoryText(point.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: ClimateSpacing.space8),
                _DirectoryText(point.text),
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
    return Scaffold(
      appBar: AppBar(
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(l10n.certificationDetail, maxLines: 2),
      ),
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.space16),
        children: [
          AppPanel(
            color: DesignTokens.surfaceBlue,
            padding: const EdgeInsets.all(DesignTokens.space24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppIconBadge(
                  icon: Icons.verified_outlined,
                  backgroundColor: DesignTokens.surface,
                  foregroundColor: DesignTokens.blue,
                ),
                const SizedBox(width: DesignTokens.space16),
                Expanded(
                  child: _DirectoryText(
                    certification.name,
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.space16),
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSectionHeading(title: l10n.certificationCategoryFilter),
                const SizedBox(height: DesignTokens.space8),
                _DirectoryText(certification.category),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.space12),
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSectionHeading(title: l10n.certificationMeaningLabel),
                const SizedBox(height: DesignTokens.space8),
                _DirectoryText(certification.meaning),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.space12),
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSectionHeading(title: l10n.certificationWhereSeenLabel),
                const SizedBox(height: DesignTokens.space8),
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
