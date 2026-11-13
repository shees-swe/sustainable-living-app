import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/icons/app_icons.dart';
import '../../../core/theme/app_theme.dart';
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
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
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
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: ClimateSpacing.space16,
          vertical: ClimateSpacing.space8,
        ),
        children: [
          if (onViewEstimate != null) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(AppIcons.chartLineUp),
              title: Text(l10n.viewEstimate),
              trailing: const Icon(Icons.chevron_right),
              onTap: onViewEstimate,
            ),
            const Divider(height: 1),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: ClimateSpacing.space16,
            ),
            child: Text(
              l10n.exploreModules,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final destination in ModuleDestination.modules) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(_moduleIcon(destination.id)),
              title: Text(_moduleTitle(l10n, destination.titleKey)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(destination.path),
            ),
            const Divider(height: 1),
          ],
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(AppIcons.info),
            title: Text(l10n.aboutUs),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.about),
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
