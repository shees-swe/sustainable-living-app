import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/design_components.dart';
import '../../../l10n/generated/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(l10n.aboutUs, maxLines: 2),
      ),
      body: ListView(
        padding: const EdgeInsets.all(ClimateSpacing.space16),
        children: [
          AppPanel(
            color: DesignTokens.surfaceBlue,
            padding: const EdgeInsets.all(DesignTokens.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppIconBadge(
                  icon: Icons.eco_outlined,
                  backgroundColor: DesignTokens.surface,
                  foregroundColor: DesignTokens.blue,
                ),
                const SizedBox(height: DesignTokens.space16),
                Text(
                  l10n.aboutDescription,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
