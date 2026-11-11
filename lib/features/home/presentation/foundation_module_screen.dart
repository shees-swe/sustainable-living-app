import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';

class FoundationModuleScreen extends StatelessWidget {
  const FoundationModuleScreen({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(title, maxLines: 2),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: ClimateSpacing.space16,
          vertical: ClimateSpacing.space8,
        ),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.eco_outlined,
              size: 48,
              color: theme.colorScheme.primary,
              semanticLabel: l10n.foundationDestination,
            ),
            title: Text(
              l10n.foundationDestination,
              style: theme.textTheme.titleMedium,
            ),
            subtitle: Text(
              l10n.moduleDetailsComingSoon,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
