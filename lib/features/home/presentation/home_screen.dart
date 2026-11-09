import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/icons/app_icons.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/module_destination.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({this.onViewEstimate, super.key});

  final VoidCallback? onViewEstimate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          PopupMenuButton<String>(
            tooltip: l10n.moreNavigation,
            onSelected: (path) => context.go(path),
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
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.space4),
        children: [
          if (onViewEstimate != null) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onViewEstimate,
                icon: const Icon(AppIcons.chartLineUp),
                label: Text(l10n.viewEstimate),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.space2),
          ],
          Padding(
            padding: const EdgeInsets.only(
              bottom: DesignTokens.space3,
              top: DesignTokens.space2,
            ),
            child: Text(
              l10n.exploreModules,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          for (final destination in ModuleDestination.modules) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.go(destination.path),
                icon: Icon(_moduleIcon(destination.id)),
                label: Text(_moduleTitle(l10n, destination.titleKey)),
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  minimumSize: const Size.fromHeight(56),
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.space4,
                    vertical: DesignTokens.space3,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      DesignTokens.radiusMedium,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.space2),
          ],
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => context.go(AppRoutes.about),
              icon: const Icon(AppIcons.info),
              label: Text(l10n.aboutUs),
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.space4,
                ),
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
