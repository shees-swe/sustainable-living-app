import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
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
          Text(
            l10n.aboutDescription,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
