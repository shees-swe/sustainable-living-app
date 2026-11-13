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
        padding: const EdgeInsets.fromLTRB(
          ClimateSpacing.space16,
          ClimateSpacing.space16,
          ClimateSpacing.space16,
          112,
        ),
        children: [
          Card(
            color: ClimateColors.surfaceSecondary,
            child: Padding(
              padding: const EdgeInsets.all(ClimateSpacing.space16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    AppIcons.leaf,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: ClimateSpacing.space16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.onboardingIntro,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (onViewEstimate != null) ...[
            const SizedBox(height: ClimateSpacing.space16),
            Card(
              child: ListTile(
                leading: const Icon(AppIcons.chartLineUp),
                title: Text(l10n.viewEstimate),
                trailing: const Icon(Icons.chevron_right),
                onTap: onViewEstimate,
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.only(
              top: ClimateSpacing.space24,
              bottom: ClimateSpacing.space16,
            ),
            child: Text(
              l10n.exploreModules,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          for (final destination in ModuleDestination.modules.take(2)) ...[
            Card(
              child: ListTile(
                minVerticalPadding: ClimateSpacing.space16,
                leading: Icon(
                  _moduleIcon(destination.id),
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  _moduleTitle(l10n, destination.titleKey),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(destination.path),
              ),
            ),
            const SizedBox(height: ClimateSpacing.space8),
          ],
          Wrap(
            spacing: ClimateSpacing.space8,
            runSpacing: ClimateSpacing.space8,
            children: [
              for (final destination in ModuleDestination.modules.skip(2))
                _moduleCard(context, l10n, destination),
            ],
          ),
          const SizedBox(height: ClimateSpacing.space8),
          Card(
            child: ListTile(
              leading: const Icon(AppIcons.info),
              title: Text(l10n.aboutUs),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.about),
            ),
          ),
        ],
      ),
    );
  }

  Widget _moduleCard(
    BuildContext context,
    AppLocalizations l10n,
    ModuleDestination destination,
  ) {
    final size = MediaQuery.sizeOf(context).width;
    final columns = MediaQuery.textScalerOf(context).scale(1) > 1.3 ? 1 : 2;
    final width = columns == 1 ? size - 32 : (size - 40) / 2;
    return SizedBox(
      width: width,
      child: Card(
        child: ListTile(
          minVerticalPadding: ClimateSpacing.space16,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: ClimateSpacing.space16,
            vertical: ClimateSpacing.space8,
          ),
          leading: Icon(
            _moduleIcon(destination.id),
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            _moduleTitle(l10n, destination.titleKey),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(destination.path),
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
