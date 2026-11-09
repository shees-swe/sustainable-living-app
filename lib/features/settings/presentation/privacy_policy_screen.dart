import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/accessibility/motion_aware_progress_indicator.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late final Future<String> _policy = rootBundle.loadString(
    'assets/content/privacy_policy_en.md',
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyPolicy)),
      body: FutureBuilder<String>(
        future: _policy,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.space4),
                child: Text(
                  '${l10n.privacyPolicyLoadFailure}\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final policy = snapshot.data;
          if (policy == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MotionAwareProgressIndicator(
                    semanticsLabel: l10n.loadingPrivacyPolicy,
                  ),
                  const SizedBox(height: DesignTokens.space2),
                  Text(l10n.loadingPrivacyPolicy),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(DesignTokens.space4),
            children: [
              for (final line in policy.split('\n'))
                if (line.trim().isNotEmpty) _buildPolicyLine(context, line),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPolicyLine(BuildContext context, String line) {
    final text = line.trim();
    final headingLevel = text.startsWith('## ')
        ? 2
        : text.startsWith('# ')
        ? 1
        : 0;
    if (headingLevel > 0) {
      final heading = text.substring(headingLevel == 1 ? 2 : 3);
      return Padding(
        padding: const EdgeInsets.only(
          bottom: DesignTokens.space2,
          top: DesignTokens.space3,
        ),
        child: Text(
          heading,
          style: headingLevel == 1
              ? Theme.of(context).textTheme.headlineSmall
              : Theme.of(context).textTheme.titleLarge,
        ),
      );
    }

    if (text.startsWith('- ')) {
      return Padding(
        padding: const EdgeInsets.only(left: DesignTokens.space3),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.circle, size: 8),
          title: Text(text.substring(2)),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.space3),
      child: SelectableText(text),
    );
  }
}
