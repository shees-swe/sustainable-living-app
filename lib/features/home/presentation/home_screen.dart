import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/icons/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/module_destination.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({this.onViewEstimate, super.key});

  final VoidCallback? onViewEstimate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final verdant = Theme.of(context).extension<VerdantColors>()!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _HeroHeader(
              title: l10n.appTitle,
              onViewEstimate: onViewEstimate,
              onSettings: () => context.push(AppRoutes.settings),
              onAccount: () => context.push(AppRoutes.account),
              onGallery: () => context.push(AppRoutes.gallery),
              onContact: () => context.push(AppRoutes.contact),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                l10n.exploreModules,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: ClimateColors.textSecondary,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.05,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final destination = ModuleDestination.modules[index];
                  return _ModuleCard(
                    icon: _moduleIcon(destination.id),
                    title: _moduleTitle(l10n, destination.titleKey),
                    accentColor: _moduleColor(verdant, index),
                    onTap: () => context.push(destination.path),
                  );
                },
                childCount: ModuleDestination.modules.length,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            sliver: SliverToBoxAdapter(
              child: _ModuleCard(
                icon: AppIcons.info,
                title: l10n.aboutUs,
                accentColor: ClimateColors.textSecondary,
                onTap: () => context.push(AppRoutes.about),
                fullWidth: true,
              ),
            ),
          ),
        ],
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
      'carbonFootprintTracker' => AppIcons.leafFill,
      'ecoFriendlyProductSuggestions' => AppIcons.basketFill,
      'sustainableLivingChallenges' => AppIcons.trophyFill,
      'certificationsGuide' => AppIcons.sealCheckFill,
      'wasteReductionTracker' => AppIcons.trashFill,
      'recipesMealPlanning' => AppIcons.cookingPotFill,
      'energyConservationTips' => AppIcons.lightbulbFill,
      'ecoTravelSuggestions' => AppIcons.airplaneFill,
      'communityJournal' => AppIcons.bookOpenFill,
      'progressDashboard' => AppIcons.chartLineUpFill,
      'educationalContent' => AppIcons.graduationCapFill,
      _ => throw ArgumentError.value(
        moduleId,
        'moduleId',
        'Unknown module identifier',
      ),
    };
  }

  static Color _moduleColor(VerdantColors verdant, int index) {
    const palette = [
      Color(0xFF1B5E20), // forest
      Color(0xFFE65100), // amber
      Color(0xFF00695C), // teal
      Color(0xFF4527A0), // deep purple
      Color(0xFF2E7D32), // green
      Color(0xFFC62828), // red
      Color(0xFFF9A825), // yellow
      Color(0xFF0277BD), // light blue
      Color(0xFF6A1B9A), // purple
      Color(0xFF00838F), // cyan
      Color(0xFF558B2F), // light green
    ];
    return palette[index % palette.length];
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.title,
    required this.onViewEstimate,
    required this.onSettings,
    required this.onAccount,
    required this.onGallery,
    required this.onContact,
  });

  final String title;
  final VoidCallback? onViewEstimate;
  final VoidCallback onSettings;
  final VoidCallback onAccount;
  final VoidCallback onGallery;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textScaler = MediaQuery.textScalerOf(context);

    return Container(
      decoration: DesignTokens.heroGradient(context),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 8, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: l10n.moreNavigation,
                    iconColor: Colors.white.withValues(alpha: 0.9),
                    onSelected: (path) {
                      switch (path) {
                        case 'settings':
                          onSettings();
                        case 'account':
                          onAccount();
                        case 'gallery':
                          onGallery();
                        case 'contact':
                          onContact();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'settings',
                        child: Text(l10n.settings),
                      ),
                      PopupMenuItem(
                        value: 'account',
                        child: Text(l10n.account),
                      ),
                      PopupMenuItem(
                        value: 'gallery',
                        child: Text(l10n.imageGallery),
                      ),
                      PopupMenuItem(
                        value: 'contact',
                        child: Text(l10n.contactUs),
                      ),
                    ],
                  ),
                ],
              ),
              if (onViewEstimate != null) ...[
                const SizedBox(height: 16),
                Material(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: onViewEstimate,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            AppIcons.chartLineUp,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: textScaler.scale(20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.viewEstimate,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: textScaler.scale(16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.accentColor,
    required this.onTap,
    this.fullWidth = false,
  });

  final IconData icon;
  final String title;
  final Color accentColor;
  final VoidCallback onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    return Semantics(
      button: true,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        child: InkWell(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          padding: EdgeInsets.all(fullWidth ? 16 : 14),
          child: fullWidth
              ? Row(
                  children: [
                    Container(
                      width: textScaler.scale(DesignTokens.iconChipSize),
                      height: textScaler.scale(DesignTokens.iconChipSize),
                      decoration: DesignTokens.accentChip(accentColor),
                      child: Icon(
                        icon,
                        color: accentColor,
                        size: textScaler.scale(22),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: textScaler.scale(14),
                      color: ClimateColors.textSecondary,
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: textScaler.scale(DesignTokens.iconChipSize),
                      height: textScaler.scale(DesignTokens.iconChipSize),
                      decoration: DesignTokens.accentChip(accentColor),
                      child: Icon(
                        icon,
                        color: accentColor,
                        size: textScaler.scale(22),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
        ),
      ),
    ),
  );
  }
}
