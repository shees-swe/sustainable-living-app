import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/living_theme.dart';
import '../../../core/widgets/living_widgets.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../home/presentation/module_labels.dart';

/// Hub for the six Explore modules, shown in two columns.
class ExploreHubScreen extends StatelessWidget {
  const ExploreHubScreen({super.key});

  static const moduleIds = <String>[
    'ecoFriendlyProductSuggestions',
    'ecoTravelSuggestions',
    'recipesMealPlanning',
    'certificationsGuide',
    'energyConservationTips',
    'educationalContent',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Semantics(
              header: true,
              child: Text(l10n.navExplore, style: textTheme.headlineMedium),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.exploreModules,
              style: textTheme.labelMedium?.copyWith(color: LivingColors.muted),
            ),
            const SizedBox(height: 20),
            for (var i = 0; i < moduleIds.length; i += 2)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _ModuleTile(id: moduleIds[i])),
                      const SizedBox(width: 12),
                      Expanded(child: _ModuleTile(id: moduleIds[i + 1])),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LivingTile(
      onTap: () => context.push(ModuleLabels.path(id)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 132),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                color: LivingColors.ink,
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(ModuleLabels.icon(id), color: LivingColors.lime),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              ModuleLabels.title(l10n, id),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}
