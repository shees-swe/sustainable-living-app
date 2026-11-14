import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/database/app_database.dart';
import '../../../core/icons/app_icons.dart';
import '../../../core/theme/living_theme.dart';
import '../../../core/widgets/living_widgets.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../carbon_footprint_tracker/data/activity_log_repository.dart';
import 'module_labels.dart';

/// Tab-shell Home: this year's logged emissions, quick actions, and links.
/// All Explore modules live on the Explore tab; About, Settings, and the rest
/// live on the You tab.
class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({
    this.onViewEstimate,
    this.activityLogRepository,
    super.key,
  });

  final VoidCallback? onViewEstimate;
  final ActivityLogRepository? activityLogRepository;

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
            Text(
              l10n.appTitle,
              style: textTheme.labelMedium?.copyWith(
                color: LivingColors.muted,
              ),
            ),
            const SizedBox(height: 2),
            Semantics(
              header: true,
              child: Text(l10n.homeYourWeek, style: textTheme.headlineMedium),
            ),
            const SizedBox(height: 20),
            _EmissionsHero(repository: activityLogRepository),
            const SizedBox(height: 16),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _ActionCard(
                      label: l10n.trackerAddEntry,
                      path: ModuleLabels.path('carbonFootprintTracker'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(
                      label: l10n.wasteAddEntry,
                      path: ModuleLabels.path('wasteReductionTracker'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(
                      label: l10n.homeQuickRecipes,
                      path: ModuleLabels.path('recipesMealPlanning'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (onViewEstimate != null) ...[
              _LinkTile(
                icon: AppIcons.chartLineUp,
                label: l10n.viewEstimate,
                onTap: onViewEstimate,
              ),
              const SizedBox(height: 12),
            ],
            _LinkTile(
              icon: AppIcons.chartLineUp,
              label: l10n.progressDashboard,
              onTap: () => context.push(ModuleLabels.path('progressDashboard')),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmissionsHero extends StatelessWidget {
  const _EmissionsHero({required this.repository});

  final ActivityLogRepository? repository;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final year = DateTime.now().year;
    return LivingHeroCard(
      child: StreamBuilder<List<ActivityLogEntry>>(
        stream: repository?.watchEntries(),
        builder: (context, snapshot) {
          final entries = snapshot.data;
          final total = entries
              ?.where((entry) => entry.activityDate.year == year)
              .fold<double>(0, (sum, entry) => sum + entry.emissionsKg);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.trackerPeriodTotal(year),
                style: textTheme.labelMedium?.copyWith(
                  color: LivingColors.onInkMuted,
                ),
              ),
              const SizedBox(height: 6),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: total == null ? '—' : total.toStringAsFixed(1),
                      style: textTheme.displaySmall?.copyWith(
                        color: LivingColors.card,
                      ),
                    ),
                    TextSpan(
                      text: '  kg CO₂e',
                      style: textTheme.bodyMedium?.copyWith(
                        color: LivingColors.onInkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    context.push(ModuleLabels.path('carbonFootprintTracker')),
                child: Text(l10n.trackerAddEntry),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.label, required this.path});

  final String label;
  final String path;

  @override
  Widget build(BuildContext context) => LivingTile(
    onTap: () => context.push(path),
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.add_rounded),
        const SizedBox(height: 10),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    ),
  );
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => LivingTile(
    onTap: onTap,
    child: Row(
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.titleSmall),
        ),
        const Icon(Icons.chevron_right),
      ],
    ),
  );
}
