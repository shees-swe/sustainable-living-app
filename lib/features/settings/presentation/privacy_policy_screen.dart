import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/accessibility/motion_aware_progress_indicator.dart';
import '../../../core/theme/app_theme.dart';
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
      appBar: AppBar(
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(l10n.privacyPolicy, maxLines: 2),
      ),
      body: FutureBuilder<String>(
        future: _policy,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(ClimateSpacing.space16),
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
                  const SizedBox(height: ClimateSpacing.space8),
                  Text(l10n.loadingPrivacyPolicy),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: ClimateSpacing.space16,
              vertical: ClimateSpacing.space8,
            ),
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
          bottom: ClimateSpacing.space8,
          top: ClimateSpacing.space24,
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
      return Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.circle, size: 8),
            title: Text(text.substring(2)),
          ),
          const Divider(height: 1),
        ],
      );
    }

    final numberStyle = Theme.of(context)
        .extension<ClimateTypography>()!
        .number;
    final children = <InlineSpan>[];
    var cursor = 0;
    for (final match in RegExp(r'\d+').allMatches(text)) {
      if (match.start > cursor) {
        children.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      children.add(TextSpan(text: match.group(0), style: numberStyle));
      cursor = match.end;
    }
    if (cursor < text.length) {
      children.add(TextSpan(text: text.substring(cursor)));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: ClimateSpacing.space16),
      child: SelectableText.rich(
        TextSpan(
          style: Theme.of(context).textTheme.bodyLarge,
          children: children,
        ),
      ),
    );
  }
}
