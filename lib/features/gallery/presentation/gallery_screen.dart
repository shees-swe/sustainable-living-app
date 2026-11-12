import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

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
          l10n.imageGallery,
          maxLines: 2,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
            child: Center(
              child: Container(
                decoration: DesignTokens.sectionCard(context),
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: verdant.forestLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.photo_library_outlined,
                        size: 32,
                        color: verdant.forestGreen,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.galleryEmpty,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: ClimateColors.textSecondary,
                      ),
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
