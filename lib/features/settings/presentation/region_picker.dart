import 'package:flutter/material.dart';

import '../../../core/accessibility/motion_aware_progress_indicator.dart';
import '../../../core/data/regions/region_catalog.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/user_preferences_repository.dart';

class RegionPicker extends StatefulWidget {
  const RegionPicker({
    required this.preferences,
    required this.catalog,
    this.onSelectionChanged,
    super.key,
  });

  final UserPreferencesRepository preferences;
  final RegionCatalog catalog;
  final ValueChanged<String?>? onSelectionChanged;

  @override
  State<RegionPicker> createState() => _RegionPickerState();
}

class _RegionPickerState extends State<RegionPicker> {
  late Future<UserPreferencesSettings> _settings = widget.preferences.load();
  String? _errorMessage;

  Future<void> _selectRegion(String? regionId) async {
    try {
      await widget.preferences.selectRegion(regionId);
      if (!mounted) return;
      setState(() {
        _errorMessage = null;
        _settings = widget.preferences.load();
      });
      widget.onSelectionChanged?.call(regionId);
    } on UnsupportedRegionSelection {
      if (!mounted) return;
      setState(() {
        _errorMessage = AppLocalizations.of(context)!
            .regionSelectionUnavailable;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<UserPreferencesSettings>(
      future: _settings,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            '${l10n.regionPreferencesFailure}\n${snapshot.error}',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          );
        }
        final settings = snapshot.data;
        if (settings == null) {
          return Center(
            child: MotionAwareProgressIndicator(semanticsLabel: l10n.loading),
          );
        }

        final selected = settings.selectedRegionId;
        final entry = selected == null
            ? null
            : widget.catalog.regionById(selected);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.chooseRegion,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: ClimateSpacing.space8),
            Text(
              l10n.displayLanguage(
                settings.displayLanguageTag == 'en'
                    ? 'English'
                    : settings.displayLanguageTag,
              ),
            ),
            if (selected != null && entry == null) ...[
              const SizedBox(height: ClimateSpacing.space8),
              Text(
                l10n.savedRegionUnavailable(selected),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            RadioGroup<String>(
              groupValue: selected != null && entry == null ? null : selected,
              onChanged: _selectRegion,
              child: Column(
                children: [
                  for (final region in widget.catalog.regions) ...[
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_regionName(l10n, region.nameKey)),
                      subtitle: region.demoOnly
                          ? Text(l10n.demoOnlyWarning)
                          : Text(l10n.regionCurrency(region.currencyCode)),
                      value: region.regionId,
                    ),
                    const Divider(height: 1),
                  ],
                ],
              ),
            ),
            if (selected == null) Text(l10n.noRegionSelected),
            if (entry != null) ...[
              Text(l10n.regionCurrency(entry.currencyCode)),
              if (entry.demoOnly)
                Text(
                  l10n.demoOnlyWarning,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                )
              else ...[
                const SizedBox(height: ClimateSpacing.space8),
                Text(l10n.transportDataUnavailable),
                Text(l10n.recipeImpactDataUnavailable),
              ],
            ],
            if (_errorMessage case final message?)
              Padding(
                padding: const EdgeInsets.only(top: ClimateSpacing.space8),
                child: Text(
                  message,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        );
      },
    );
  }

  String _regionName(AppLocalizations l10n, String key) => switch (key) {
    'regionPakistan' => l10n.regionPakistan,
    'regionDemoOnly' => l10n.regionDemoOnly,
    _ => throw ArgumentError.value(key, 'key', 'Unknown region name key.'),
  };
}
