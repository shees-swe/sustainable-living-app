import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/widgets/design_components.dart';
import '../../../l10n/generated/app_localizations.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(l10n.contactUs, maxLines: 2),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.all(ClimateSpacing.space16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: AppPanel(
                color: DesignTokens.surfaceCoral,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppIconBadge(
                      icon: Icons.contact_support_outlined,
                      backgroundColor: DesignTokens.surface,
                      foregroundColor: DesignTokens.coral,
                    ),
                    const SizedBox(height: DesignTokens.space16),
                    Text(
                      l10n.contactUnavailable,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
