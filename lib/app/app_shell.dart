import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/accessibility/reduced_motion.dart';
import '../core/icons/app_icons.dart';
import '../core/theme/living_theme.dart';
import '../features/home/domain/module_destination.dart';
import '../l10n/generated/app_localizations.dart';
import 'router.dart';

/// The five bottom-bar tabs. Every existing route belongs to exactly one tab,
/// so the bar stays visible and highlights correctly on module screens.
enum AppTab {
  home,
  track,
  goals,
  explore,
  you;

  String get rootPath => switch (this) {
    AppTab.home => AppRoutes.home,
    AppTab.track => _modulePath('carbonFootprintTracker'),
    AppTab.goals => _modulePath('sustainableLivingChallenges'),
    AppTab.explore => AppRoutes.explore,
    AppTab.you => AppRoutes.you,
  };

  IconData get icon => switch (this) {
    AppTab.home => Icons.home_outlined,
    AppTab.track => AppIcons.leaf,
    AppTab.goals => AppIcons.trophy,
    AppTab.explore => Icons.explore_outlined,
    AppTab.you => Icons.person_outline,
  };

  String label(AppLocalizations l10n) => switch (this) {
    AppTab.home => l10n.navHome,
    AppTab.track => l10n.navTrack,
    AppTab.goals => l10n.navGoals,
    AppTab.explore => l10n.navExplore,
    AppTab.you => l10n.navYou,
  };

  static String _modulePath(String id) =>
      ModuleDestination.modules.firstWhere((m) => m.id == id).path;

  static AppTab _tabForModule(String id) => switch (id) {
    'carbonFootprintTracker' || 'wasteReductionTracker' => AppTab.track,
    'sustainableLivingChallenges' || 'progressDashboard' => AppTab.goals,
    'communityJournal' => AppTab.you,
    _ => AppTab.explore,
  };

  static bool _matches(String location, String path) =>
      location == path || location.startsWith('$path/');

  static AppTab fromLocation(String location) {
    for (final module in ModuleDestination.modules) {
      if (_matches(location, module.path)) return _tabForModule(module.id);
    }
    if (_matches(location, AppRoutes.explore)) return AppTab.explore;
    for (final path in [
      AppRoutes.you,
      AppRoutes.account,
      AppRoutes.settings,
      AppRoutes.privacyPolicy,
      AppRoutes.about,
      AppRoutes.gallery,
      AppRoutes.contact,
    ]) {
      if (_matches(location, path)) return AppTab.you;
    }
    return AppTab.home;
  }
}

/// Wraps tab destinations with the floating bottom bar. Used by a
/// [ShellRoute] in the router when `useTabShell` is true.
class AppShell extends StatelessWidget {
  const AppShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Scaffold(
      body: child,
      bottomNavigationBar: keyboardOpen
          ? null
          : LivingNavBar(
              selected: AppTab.fromLocation(location),
              onSelected: (tab) => context.go(tab.rootPath),
            ),
    );
  }
}

class LivingNavBar extends StatelessWidget {
  const LivingNavBar({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final AppTab selected;
  final ValueChanged<AppTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final reduced = ReducedMotion.isEnabled(context);
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 68),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: LivingColors.ink,
          borderRadius: BorderRadius.circular(LivingShape.navBar),
        ),
        child: Row(
          children: [
            for (final tab in AppTab.values)
              Expanded(
                flex: tab == selected ? 5 : 2,
                // A nested Row keeps each item at its natural height. Using
                // Center here would expand to the full available height and
                // make the bar fill the screen.
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: _NavItem(
                        tab: tab,
                        label: tab.label(l10n),
                        selected: tab == selected,
                        reducedMotion: reduced,
                        onTap: () => onSelected(tab),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.label,
    required this.selected,
    required this.reducedMotion,
    required this.onTap,
  });

  final AppTab tab;
  final String label;
  final bool selected;
  final bool reducedMotion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final duration = reducedMotion
        ? Duration.zero
        : const Duration(milliseconds: 220);
    final labelStyle = Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(color: LivingColors.ink);
    return Semantics(
      button: true,
      selected: selected,
      child: Tooltip(
        message: label,
        excludeFromSemantics: selected,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: AnimatedContainer(
              duration: duration,
              curve: Curves.easeOutCubic,
              constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
              padding: EdgeInsets.symmetric(horizontal: selected ? 14 : 0),
              decoration: ShapeDecoration(
                color: selected ? LivingColors.lime : Colors.transparent,
                shape: const StadiumBorder(),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    tab.icon,
                    size: 22,
                    color: selected
                        ? LivingColors.ink
                        : LivingColors.onInkMuted,
                  ),
                  if (selected) ...[
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: labelStyle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
