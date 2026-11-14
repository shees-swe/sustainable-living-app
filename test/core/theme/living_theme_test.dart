import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/core/theme/living_theme.dart';

double _channel(double v) =>
    v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

double _luminance(Color c) =>
    0.2126 * _channel(c.r) + 0.7152 * _channel(c.g) + 0.0722 * _channel(c.b);

double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  group('LivingTheme', () {
    test('uses the forest ink and lime palette', () {
      final scheme = LivingTheme.light.colorScheme;
      expect(scheme.primary, LivingColors.ink);
      expect(scheme.secondary, LivingColors.lime);
      expect(LivingTheme.light.scaffoldBackgroundColor, LivingColors.ground);
    });

    test('every documented text and surface pair meets WCAG AA', () {
      final pairs = <String, (Color, Color)>{
        'ink on ground': (LivingColors.ink, LivingColors.ground),
        'ink on card': (LivingColors.ink, LivingColors.card),
        'ink on lime': (LivingColors.ink, LivingColors.lime),
        'card on ink': (LivingColors.card, LivingColors.ink),
        'muted on ground': (LivingColors.muted, LivingColors.ground),
        'muted on card': (LivingColors.muted, LivingColors.card),
        'muted on track': (LivingColors.muted, LivingColors.track),
        'onInkMuted on ink': (LivingColors.onInkMuted, LivingColors.ink),
        'emissions on card': (LivingColors.emissions, LivingColors.card),
        'error on card': (LivingColors.error, LivingColors.card),
        'error on ground': (LivingColors.error, LivingColors.ground),
      };
      pairs.forEach((name, pair) {
        expect(
          _contrast(pair.$1, pair.$2),
          greaterThanOrEqualTo(4.5),
          reason: name,
        );
      });
    });

    test('registers every theme extension that AppTheme registers', () {
      // ~30 existing screens call
      // Theme.of(context).extension<ClimateTypography>()!, which crashes if
      // the active theme omits it.
      expect(
        LivingTheme.light.extensions.keys,
        containsAll(AppTheme.light.extensions.keys),
      );
      final typography = LivingTheme.light.extension<ClimateTypography>();
      expect(typography, isNotNull);
      expect(typography!.number.fontFamily, isNotNull);
    });

    test('buttons keep a 48 dp minimum touch target', () {
      final size = LivingTheme.light.filledButtonTheme.style?.minimumSize
          ?.resolve(<WidgetState>{});
      expect(size, const Size(48, 48));
    });
  });
}
