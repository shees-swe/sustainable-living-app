import 'package:flutter/material.dart';

import '../../../core/icons/app_icons.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/module_destination.dart';

/// Shared title, icon, and route lookups for the 11 modules.
abstract final class ModuleLabels {
  static String path(String id) =>
      ModuleDestination.modules.firstWhere((m) => m.id == id).path;

  static String title(AppLocalizations l10n, String id) => switch (id) {
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
    _ => throw ArgumentError.value(id, 'id', 'Unknown module identifier'),
  };

  static IconData icon(String id) => switch (id) {
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
    _ => throw ArgumentError.value(id, 'id', 'Unknown module identifier'),
  };
}
