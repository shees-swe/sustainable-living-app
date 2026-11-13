import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/icons/app_icons.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/design_components.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/module_destination.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({this.onViewEstimate, super.key});

  final VoidCallback? onViewEstimate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight * textScale,
        title: Text(l10n.appTitle, maxLines: 2),
        actions: [
          PopupMenuButton<String>(
            tooltip: l10n.moreNavigation,
            onSelected: (path) => context.push(path),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: AppRoutes.settings,
                child: Text(l10n.settings),
              ),
              PopupMenuItem(
                value: AppRoutes.account,
                child: Text(l10n.account),
              ),
              PopupMenuItem(
                value: AppRoutes.gallery,
                child: Text(l10n.imageGallery),
              ),
              PopupMenuItem(
                value: AppRoutes.contact,
                child: Text(l10n.contactUs),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = textScale >= 1.4
                ? 1
                : constraints.maxWidth >= 900
                ? 3
                : constraints.maxWidth >= 420
                ? 2
                : 1;
            final tileHeight = columns == 1 ? 88 * textScale : 148 * textScale;
            final contentWidth = constraints.maxWidth > 992
                ? 960.0
                : constraints.maxWidth - DesignTokens.space32;
            final tileWidth =
                (contentWidth - DesignTokens.space12 * (columns - 1)) / columns;

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.space16,
                DesignTokens.space16,
                DesignTokens.space16,
                DesignTokens.space32,
              ),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 960),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppPanel(
                              color: DesignTokens.surfaceBlue,
                              padding: const EdgeInsets.all(
                                DesignTokens.space24,
                              ),
                              child: Row(
                                children: [
                                  const AppIconBadge(
                                    icon: AppIcons.leaf,
                                    size: 52,
                                    backgroundColor: DesignTokens.surface,
                                    foregroundColor: DesignTokens.blue,
                                  ),
                                  const SizedBox(width: DesignTokens.space16),
                                  Expanded(
                                    child: Text(
                                      l10n.exploreModules,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (onViewEstimate != null) ...[
                              const SizedBox(height: DesignTokens.space16),
                              _HomeAction(
                                label: l10n.viewEstimate,
                                icon: AppIcons.chartLineUp,
                                onTap: onViewEstimate!,
                              ),
                            ],
                            const SizedBox(height: DesignTokens.space24),
                            Wrap(
                              spacing: DesignTokens.space12,
                              runSpacing: DesignTokens.space12,
                              children: [
                                for (
                                  var index = 0;
                                  index < ModuleDestination.modules.length;
                                  index++
                                )
                                  SizedBox(
                                    width: tileWidth,
                                    height: tileHeight,
                                    child: _ModuleTile(
                                      title: _moduleTitle(
                                        l10n,
                                        ModuleDestination
                                            .modules[index]
                                            .titleKey,
                                      ),
                                      icon: _moduleIcon(
                                        ModuleDestination.modules[index].id,
                                      ),
                                      index: index,
                                      compact: columns == 1,
                                      onTap: () => context.push(
                                        ModuleDestination.modules[index].path,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: DesignTokens.space24),
                            _HomeAction(
                              label: l10n.aboutUs,
                              icon: AppIcons.info,
                              onTap: () => context.push(AppRoutes.about),
                              outlined: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static String _moduleTitle(AppLocalizations l10n, String key) {
    return switch (key) {
      'carbonFootprintTracker' => l10n.carbonFootprintTracker,
      'ecoFriendlyProductSuggestions' => l10n.ecoFriendlyProductSuggestions,
      'sustainableLivingChallenges' => l10n.sustainableLivingChallenges,
      'certificationsGuide' => l10n.certificationsGuide,
      'wasteReductionTracker' => l10n.wasteReductionTracker,
      'recipesMealPlanning' => l10n.recipesMealPlanning,
      'energyConservationTips' => l10n.energyConservationTips,
      'ecoTravelSuggestions' => l10n.ecoTravelSuggestions,
      'communityJournal' => l10n.communityJournal,
      'progressDashboard' => l10n.progressDashboard,
      'educationalContent' => l10n.educationalContent,
      _ => throw ArgumentError.value(key, 'key', 'Unknown module title key'),
    };
  }

  static IconData _moduleIcon(String moduleId) {
    return switch (moduleId) {
      'carbonFootprintTracker' => AppIcons.leaf,
      'ecoFriendlyProductSuggestions' => AppIcons.basket,
      'sustainableLivingChallenges' => AppIcons.trophy,
      'certificationsGuide' => AppIcons.sealCheck,
      'wasteReductionTracker' => AppIcons.trash,
      'recipesMealPlanning' => AppIcons.cookingPot,
      'energyConservationTips' => AppIcons.lightbulb,
      'ecoTravelSuggestions' => AppIcons.airplane,
      'communityJournal' => AppIcons.bookOpen,
      'progressDashboard' => AppIcons.chartLineUp,
      'educationalContent' => AppIcons.graduationCap,
      _ => throw ArgumentError.value(
        moduleId,
        'moduleId',
        'Unknown module identifier',
      ),
    };
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    required this.title,
    required this.icon,
    required this.index,
    required this.compact,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final int index;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (backgroundColor, foregroundColor) = switch (index % 4) {
      0 => (DesignTokens.surfaceBlue, DesignTokens.blue),
      1 => (DesignTokens.surfaceCoral, DesignTokens.coral),
      2 => (DesignTokens.surfaceSun, DesignTokens.sun),
      _ => (DesignTokens.surfaceMuted, DesignTokens.positive),
    };
    final borderRadius = BorderRadius.circular(DesignTokens.radiusCard);
    final content = compact
        ? Row(
            children: [
              AppIconBadge(
                icon: icon,
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                size: 48,
              ),
              const SizedBox(width: DesignTokens.space16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: DesignTokens.space8),
              Icon(
                Icons.arrow_forward,
                size: DesignTokens.iconSmall,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppIconBadge(
                icon: icon,
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                size: 44,
              ),
              const Spacer(),
              Text(title, style: Theme.of(context).textTheme.titleSmall),
            ],
          );

    return Semantics(
      button: true,
      label: title,
      onTap: onTap,
      child: ExcludeSemantics(
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: const BorderSide(color: DesignTokens.dividerSubtle),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius,
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.space16),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeAction extends StatelessWidget {
  const _HomeAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.outlined = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(DesignTokens.radiusControl);
    final color = outlined
        ? Theme.of(context).colorScheme.surface
        : DesignTokens.surfaceSun;

    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      child: ExcludeSemantics(
        child: Material(
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: const BorderSide(color: DesignTokens.dividerSubtle),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius,
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.space16),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: DesignTokens.iconMedium,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: DesignTokens.space12),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.space8),
                  Icon(
                    Icons.arrow_forward,
                    size: DesignTokens.iconSmall,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
