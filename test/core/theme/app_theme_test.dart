import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AppTheme', () {
    test('uses the cream and verdant light palette', () {
      final colorScheme = AppTheme.light.colorScheme;

      expect(colorScheme.brightness, Brightness.light);
      expect(colorScheme.primary, ClimateColors.verdant);
      expect(colorScheme.onPrimary, ClimateColors.surfaceCard);
      expect(colorScheme.surface, ClimateColors.surfacePrimary);
      expect(colorScheme.onSurface, ClimateColors.textPrimary);
      expect(colorScheme.error, ClimateColors.warning);
      expect(
        AppTheme.light.scaffoldBackgroundColor,
        ClimateColors.surfacePrimary,
      );
    });

    test('uses IBM Plex Sans for headings and body text', () {
      final textTheme = AppTheme.light.textTheme;

      expect(textTheme.displayLarge, isNotNull);
      expect(textTheme.headlineMedium, isNotNull);
      expect(textTheme.titleMedium, isNotNull);
      expect(textTheme.bodyLarge, isNotNull);
      expect(textTheme.bodyMedium, isNotNull);
      expect(textTheme.bodySmall, isNotNull);
      expect(textTheme.displayLarge!.fontFamily, startsWith('IBMPlexSans'));
      expect(textTheme.titleMedium!.fontFamily, startsWith('IBMPlexSans'));
      expect(textTheme.bodyLarge!.fontFamily, startsWith('IBMPlexSans'));
      expect(textTheme.bodyMedium!.fontSize, greaterThanOrEqualTo(14));
      expect(
        textTheme.titleMedium!.fontSize,
        greaterThan(textTheme.bodyMedium!.fontSize!),
      );
    });

    test('exposes IBM Plex Mono styles for numbers, units, and table figures', () {
      final typography = AppTheme.light.extension<ClimateTypography>()!;

      expect(typography.number.fontFamily, startsWith('IBMPlexMono'));
      expect(typography.unit.fontFamily, startsWith('IBMPlexMono'));
      expect(typography.tableFigure.fontFamily, startsWith('IBMPlexMono'));
      expect(typography.number.fontWeight, FontWeight.w400);
      expect(typography.unit.fontWeight, FontWeight.w500);
      expect(typography.tableFigure.fontWeight, FontWeight.w600);
    });

    test('keeps every documented text and surface contrast pair WCAG AA', () {
      final colors = ClimateColors.light;
      const surfaces = [
        ClimateColors.surfacePrimary,
        ClimateColors.surfaceSecondary,
        ClimateColors.surfaceCard,
      ];
      const textColors = [
        ClimateColors.textPrimary,
        ClimateColors.textSecondary,
        ClimateColors.verdant,
        ClimateColors.positiveSaved,
        ClimateColors.emissions,
        ClimateColors.warning,
      ];

      for (final surface in surfaces) {
        for (final text in textColors) {
          expect(
            _contrastRatio(text, surface),
            greaterThanOrEqualTo(4.5),
            reason: '$text on $surface must meet WCAG AA normal-text contrast.',
          );
        }
      }

      expect(
        _contrastRatio(ClimateColors.surfaceCard, ClimateColors.verdant),
        greaterThanOrEqualTo(4.5),
      );
      expect(colors.divider, ClimateColors.divider);
    });

    test('provides subtle cards, clear dividers, and rounded controls', () {
      final theme = AppTheme.light;

      expect(theme.dividerTheme.thickness, 1);
      expect(theme.cardTheme.elevation, 1);
      expect(theme.cardTheme.shape, isA<RoundedRectangleBorder>());
      expect(
        theme.filledButtonTheme.style!.shape!.resolve({}),
        isA<RoundedRectangleBorder>(),
      );
      final buttonShape =
          theme.filledButtonTheme.style!.shape!.resolve({})
              as RoundedRectangleBorder;
      expect(buttonShape.borderRadius, BorderRadius.circular(12));
      expect(ClimateSpacing.values, [8, 16, 24, 32, 40, 48]);
      expect(ClimateSpacing.radiusSmall, 12);
      expect(ClimateSpacing.radiusLarge, 20);
    });

    test('loads bundled IBM Plex assets with runtime fetching disabled', () async {
      GoogleFonts.config.allowRuntimeFetching = false;
      for (final asset in [
        'assets/fonts/IBMPlexSans-Regular.ttf',
        'assets/fonts/IBMPlexSans-Medium.ttf',
        'assets/fonts/IBMPlexSans-SemiBold.ttf',
        'assets/fonts/IBMPlexSans-Bold.ttf',
        'assets/fonts/IBMPlexMono-Regular.ttf',
        'assets/fonts/IBMPlexMono-Medium.ttf',
        'assets/fonts/IBMPlexMono-SemiBold.ttf',
        'assets/fonts/IBMPlexMono-Bold.ttf',
      ]) {
        expect((await rootBundle.load(asset)).lengthInBytes, greaterThan(0));
      }
      expect(GoogleFonts.config.allowRuntimeFetching, isFalse);
    });
  });
}

double _contrastRatio(Color foreground, Color background) {
  final luminances = [foreground.computeLuminance(), background.computeLuminance()]
    ..sort();
  return (luminances[1] + 0.05) / (luminances[0] + 0.05);
}
