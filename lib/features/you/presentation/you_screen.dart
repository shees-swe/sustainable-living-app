import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/icons/app_icons.dart';
import '../../../core/theme/living_theme.dart';
import '../../../core/widgets/living_widgets.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../home/presentation/module_labels.dart';

/// Profile and settings home: optional account, journal, and app info.
class YouScreen extends StatelessWidget {
  const YouScreen({super.key});

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
            Semantics(
              header: true,
              child: Text(l10n.navYou, style: textTheme.headlineMedium),
            ),
            const SizedBox(height: 20),
            LivingCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.account, style: textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    l10n.accountOptionalGuest,
                    style: textTheme.bodyMedium?.copyWith(
                      color: LivingColors.muted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.push(AppRoutes.account),
                    child: Text(l10n.account),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LivingCard(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Column(
                children: [
                  _Row(
                    icon: AppIcons.bookOpen,
                    title: l10n.communityJournal,
                    subtitle: l10n.communityLocalOnly,
                    path: ModuleLabels.path('communityJournal'),
                  ),
                  _Row(
                    icon: Icons.settings_outlined,
                    title: l10n.settings,
                    path: AppRoutes.settings,
                  ),
                  _Row(
                    icon: Icons.privacy_tip_outlined,
                    title: l10n.privacyPolicy,
                    path: AppRoutes.privacyPolicy,
                  ),
                  _Row(
                    icon: AppIcons.info,
                    title: l10n.aboutUs,
                    path: AppRoutes.about,
                  ),
                  _Row(
                    icon: Icons.image_outlined,
                    title: l10n.imageGallery,
                    path: AppRoutes.gallery,
                  ),
                  _Row(
                    icon: Icons.mail_outline,
                    title: l10n.contactUs,
                    path: AppRoutes.contact,
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

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    required this.path,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String path;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(title),
    subtitle: subtitle == null ? null : Text(subtitle!),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => context.push(path),
  );
}
