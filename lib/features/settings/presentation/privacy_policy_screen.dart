import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/accessibility/motion_aware_progress_indicator.dart';
import '../../../core/theme/app_theme.dart';
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
    final verdant = Theme.of(context).extension<VerdantColors>()!;

    return Scaffold(
      backgroundColor: verdant.cream,
      appBar: AppBar(
        backgroundColor: verdant.forestGreen,
        foregroundColor: Colors.white,
        toolbarHeight:
            kToolbarHeight * MediaQuery.textScalerOf(context).scale(1),
        title: Text(
          l10n.privacyPolicy,
          maxLines: 2,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        scrolledUnderElevation: 0,
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Container(
                decoration: DesignTokens.sectionCard(context),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final line in policy.split('\n'))
                      if (line.trim().isNotEmpty) _buildPolicyLine(context, line),
                  ],
                ),
              ),
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
      final verdant = Theme.of(context).extension<VerdantColors>()!;
      return Padding(
        padding: const EdgeInsets.only(
          bottom: ClimateSpacing.space8,
          top: ClimateSpacing.space24,
        ),
        child: Text(
          heading,
          style: (headingLevel == 1
                  ? Theme.of(context).textTheme.headlineSmall
                  : Theme.of(context).textTheme.titleLarge)
              ?.copyWith(
            color: verdant.forestGreen,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    if (text.startsWith('- ')) {
      final verdant = Theme.of(context).extension<VerdantColors>()!;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: verdant.forestGreen,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text.substring(2),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
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
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.6,
          ),
          children: children,
        ),
      ),
    );
  }
}
