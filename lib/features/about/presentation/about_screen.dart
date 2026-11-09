import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutUs)),
      body: Padding(
        padding: const EdgeInsets.all(DesignTokens.space4),
        child: Text(
          l10n.aboutDescription,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
