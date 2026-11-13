import 'package:flutter/material.dart';

abstract final class ClimateColors {
  static const surfacePrimary = Color(0xFFFBF8F0);
  static const surfaceSecondary = Color(0xFFEDF2E7);
  static const surfaceCard = Color(0xFFFFFEFA);
  static const textPrimary = Color(0xFF1F2D24);
  static const textSecondary = Color(0xFF536158);
  static const verdant = Color(0xFF2F6B4F);
  static const positiveSaved = Color(0xFF2F6B4F);
  static const emissions = Color(0xFF85510C);
  static const warning = Color(0xFFA8322C);
  static const divider = Color(0xFF8A978B);

  static const cobalt = verdant;

  static const light = ClimateColorSet(
    surfacePrimary: surfacePrimary,
    surfaceSecondary: surfaceSecondary,
    textPrimary: textPrimary,
    textSecondary: textSecondary,
    cobalt: verdant,
    positiveSaved: positiveSaved,
    emissions: emissions,
    warning: warning,
    divider: divider,
  );
}

@immutable
class ClimateColorSet {
  const ClimateColorSet({
    required this.surfacePrimary,
    required this.surfaceSecondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.cobalt,
    required this.positiveSaved,
    required this.emissions,
    required this.warning,
    required this.divider,
  });

  final Color surfacePrimary;
  final Color surfaceSecondary;
  final Color textPrimary;
  final Color textSecondary;
  final Color cobalt;
  final Color positiveSaved;
  final Color emissions;
  final Color warning;
  final Color divider;
}

abstract final class ClimateSpacing {
  static const double base = 8;
  static const double space8 = 8;
  static const double space16 = 16;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;
  static const values = <double>[
    space8,
    space16,
    space24,
    space32,
    space40,
    space48,
  ];

  static const double radiusSmall = 12;
  static const double radiusLarge = 20;
}

@immutable
class ClimateTypography extends ThemeExtension<ClimateTypography> {
  const ClimateTypography({
    required this.number,
    required this.unit,
    required this.tableFigure,
  });

  final TextStyle number;
  final TextStyle unit;
  final TextStyle tableFigure;

  @override
  ClimateTypography copyWith({
    TextStyle? number,
    TextStyle? unit,
    TextStyle? tableFigure,
  }) {
    return ClimateTypography(
      number: number ?? this.number,
      unit: unit ?? this.unit,
      tableFigure: tableFigure ?? this.tableFigure,
    );
  }

  @override
  ClimateTypography lerp(covariant ClimateTypography? other, double t) {
    if (other == null) return this;
    return ClimateTypography(
      number: TextStyle.lerp(number, other.number, t)!,
      unit: TextStyle.lerp(unit, other.unit, t)!,
      tableFigure: TextStyle.lerp(tableFigure, other.tableFigure, t)!,
    );
  }
}

abstract final class AppTheme {
  static final ThemeData light = _buildLightTheme();

  static ThemeData _buildLightTheme() {
    const colorScheme = ColorScheme.light(
      primary: ClimateColors.verdant,
      onPrimary: ClimateColors.surfaceCard,
      primaryContainer: ClimateColors.surfaceSecondary,
      onPrimaryContainer: ClimateColors.textPrimary,
      secondary: Color(0xFFB7CFAE),
      onSecondary: ClimateColors.textPrimary,
      secondaryContainer: ClimateColors.surfaceSecondary,
      onSecondaryContainer: ClimateColors.textPrimary,
      tertiary: Color(0xFF78975F),
      onTertiary: ClimateColors.surfaceCard,
      error: ClimateColors.warning,
      onError: ClimateColors.surfaceCard,
      surface: ClimateColors.surfacePrimary,
      onSurface: ClimateColors.textPrimary,
      surfaceContainerLowest: ClimateColors.surfaceCard,
      surfaceContainerLow: ClimateColors.surfacePrimary,
      surfaceContainer: ClimateColors.surfaceSecondary,
      surfaceContainerHigh: Color(0xFFE5EBDD),
      surfaceContainerHighest: Color(0xFFDCE5D6),
      onSurfaceVariant: ClimateColors.textSecondary,
      outline: ClimateColors.divider,
      outlineVariant: Color(0xFFC9D2C6),
      surfaceTint: Colors.transparent,
    );
    final textTheme = Typography.material2021().black.apply(
      fontFamily: 'IBMPlexSans',
      bodyColor: ClimateColors.textPrimary,
      displayColor: ClimateColors.textPrimary,
    );
    final controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ClimateSpacing.radiusSmall),
    );
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(ClimateSpacing.radiusSmall),
      borderSide: const BorderSide(color: Color(0xFFC9D2C6)),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      fontFamily: 'IBMPlexSans',
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(
          fontSize: 40,
          height: 1.12,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: textTheme.headlineLarge?.copyWith(
          fontSize: 32,
          height: 1.2,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontSize: 24,
          height: 1.25,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontSize: 20,
          height: 1.3,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontSize: 16,
          height: 1.4,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.5),
        bodyMedium: textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.45),
        bodySmall: textTheme.bodySmall?.copyWith(fontSize: 12, height: 1.4),
      ),
      extensions: [
        ClimateTypography(
          number: const TextStyle(
            fontFamily: 'IBMPlexMono',
            fontWeight: FontWeight.w400,
          ),
          unit: const TextStyle(
            fontFamily: 'IBMPlexMono',
            fontWeight: FontWeight.w500,
          ),
          tableFigure: const TextStyle(
            fontFamily: 'IBMPlexMono',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
      scaffoldBackgroundColor: ClimateColors.surfacePrimary,
      canvasColor: ClimateColors.surfacePrimary,
      dividerColor: const Color(0xFFE2E7DD),
      shadowColor: const Color(0x1A233D2B),
      appBarTheme: const AppBarTheme(
        backgroundColor: ClimateColors.surfacePrimary,
        foregroundColor: ClimateColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E7DD),
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: ClimateColors.surfaceCard,
        surfaceTintColor: Colors.transparent,
        shadowColor: const Color(0x14233D2B),
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ClimateSpacing.radiusLarge),
          side: const BorderSide(color: Color(0xFFE2E7DD)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: ClimateColors.surfaceCard,
        selectedTileColor: ClimateColors.surfaceSecondary,
        iconColor: ClimateColors.verdant,
        textColor: ClimateColors.textPrimary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ClimateSpacing.space16,
        ),
        minVerticalPadding: ClimateSpacing.space8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ClimateSpacing.radiusSmall),
          side: const BorderSide(color: Color(0xFFE2E7DD)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ClimateColors.surfaceCard,
        indicatorColor: const Color(0xFFDDEBDD),
        elevation: 4,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: 'IBMPlexSans',
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: ClimateColors.surfaceCard,
          backgroundColor: ClimateColors.verdant,
          minimumSize: const Size.fromHeight(48),
          shape: controlShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ClimateColors.verdant,
          side: const BorderSide(color: ClimateColors.verdant),
          minimumSize: const Size.fromHeight(48),
          shape: controlShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ClimateColors.verdant,
          shape: controlShape,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ClimateColors.surfaceCard,
        hintMaxLines: 2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ClimateSpacing.space16,
          vertical: ClimateSpacing.space16,
        ),
        enabledBorder: fieldBorder,
        focusedBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: ClimateColors.verdant, width: 2),
        ),
        errorBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: ClimateColors.warning),
        ),
        focusedErrorBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: ClimateColors.warning, width: 2),
        ),
      ),
    );
  }
}
