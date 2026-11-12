import 'package:flutter/material.dart';

abstract final class DesignTokens {
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 24;
  static const double space6 = 32;

  static const double radiusSmall = 8;
  static const double radiusMedium = 16;
  static const double radiusLarge = 24;

  static const double cardElevation = 0;
  static const double iconChipSize = 44;

  static BoxDecoration sectionCard(BuildContext context) {
    final colors =
        Theme.of(context).extension<VerdantColors>() ?? VerdantColors.light;
    return BoxDecoration(
      color: colors.cardSurface,
      borderRadius: BorderRadius.circular(radiusMedium),
      border: Border.all(color: colors.cardBorder, width: 1),
    );
  }

  static BoxDecoration heroGradient(BuildContext context) {
    final colors =
        Theme.of(context).extension<VerdantColors>() ?? VerdantColors.light;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [colors.forestGreen, colors.forestDeep],
      ),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(radiusLarge),
        bottomRight: Radius.circular(radiusLarge),
      ),
    );
  }

  static BoxDecoration accentChip(Color color) => BoxDecoration(
    color: color.withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(radiusSmall),
  );
}

@immutable
class VerdantColors extends ThemeExtension<VerdantColors> {
  const VerdantColors({
    required this.forestGreen,
    required this.forestDeep,
    required this.forestLight,
    required this.amber,
    required this.amberLight,
    required this.cream,
    required this.cardSurface,
    required this.cardBorder,
    required this.textHero,
    required this.tagBackground,
  });

  final Color forestGreen;
  final Color forestDeep;
  final Color forestLight;
  final Color amber;
  final Color amberLight;
  final Color cream;
  final Color cardSurface;
  final Color cardBorder;
  final Color textHero;
  final Color tagBackground;

  static const light = VerdantColors(
    forestGreen: Color(0xFF1B5E20),
    forestDeep: Color(0xFF0D3B0F),
    forestLight: Color(0xFFE8F5E9),
    amber: Color(0xFFE65100),
    amberLight: Color(0xFFFFF3E0),
    cream: Color(0xFFFAFAF5),
    cardSurface: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFE8E8E0),
    textHero: Color(0xFFFFFFFF),
    tagBackground: Color(0xFFF1F8E9),
  );

  @override
  VerdantColors copyWith({
    Color? forestGreen,
    Color? forestDeep,
    Color? forestLight,
    Color? amber,
    Color? amberLight,
    Color? cream,
    Color? cardSurface,
    Color? cardBorder,
    Color? textHero,
    Color? tagBackground,
  }) =>
      VerdantColors(
        forestGreen: forestGreen ?? this.forestGreen,
        forestDeep: forestDeep ?? this.forestDeep,
        forestLight: forestLight ?? this.forestLight,
        amber: amber ?? this.amber,
        amberLight: amberLight ?? this.amberLight,
        cream: cream ?? this.cream,
        cardSurface: cardSurface ?? this.cardSurface,
        cardBorder: cardBorder ?? this.cardBorder,
        textHero: textHero ?? this.textHero,
        tagBackground: tagBackground ?? this.tagBackground,
      );

  @override
  VerdantColors lerp(covariant VerdantColors? other, double t) {
    if (other == null) return this;
    return VerdantColors(
      forestGreen: Color.lerp(forestGreen, other.forestGreen, t)!,
      forestDeep: Color.lerp(forestDeep, other.forestDeep, t)!,
      forestLight: Color.lerp(forestLight, other.forestLight, t)!,
      amber: Color.lerp(amber, other.amber, t)!,
      amberLight: Color.lerp(amberLight, other.amberLight, t)!,
      cream: Color.lerp(cream, other.cream, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      textHero: Color.lerp(textHero, other.textHero, t)!,
      tagBackground: Color.lerp(tagBackground, other.tagBackground, t)!,
    );
  }
}
