import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainable_living_app/core/theme/app_theme.dart';
import 'package:sustainable_living_app/core/theme/design_tokens.dart';

void main() {
  group('AppTheme', () {
    test('provides green semantic color roles', () {
      final colorScheme = AppTheme.light.colorScheme;

      expect(colorScheme.brightness, Brightness.light);
      expect(colorScheme.primary, isNot(Colors.deepPurple));
      expect(colorScheme.onPrimary, isNot(colorScheme.primary));
      expect(colorScheme.secondary, isNot(colorScheme.surface));
      expect(colorScheme.error, isNot(colorScheme.primary));
    });

    test('provides a readable typography scale', () {
      final textTheme = AppTheme.light.textTheme;

      expect(textTheme.displayLarge, isNotNull);
      expect(textTheme.titleMedium, isNotNull);
      expect(textTheme.bodyMedium, isNotNull);
      expect(textTheme.bodySmall, isNotNull);
      expect(textTheme.bodyMedium!.fontSize, greaterThanOrEqualTo(14));
      expect(
        textTheme.titleMedium!.fontSize,
        greaterThan(textTheme.bodyMedium!.fontSize!),
      );
    });
  });

  group('DesignTokens', () {
    test('provides a consistent spacing scale', () {
      expect(DesignTokens.space1, 4);
      expect(DesignTokens.space2, 8);
      expect(DesignTokens.space3, 12);
      expect(DesignTokens.space4, 16);
      expect(DesignTokens.space2, greaterThan(DesignTokens.space1));
      expect(DesignTokens.space3, greaterThan(DesignTokens.space2));
      expect(DesignTokens.space4, greaterThan(DesignTokens.space3));
    });

    test('provides standard corner-radius tokens', () {
      expect(DesignTokens.radiusSmall, 8);
      expect(DesignTokens.radiusMedium, 16);
      expect(DesignTokens.radiusLarge, 24);
    });
  });
}
