import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class ClimateColors {
  static const surfacePrimary = Color(0xFFFFFFFF);
  static const surfaceSecondary = Color(0xFFF3F4F6);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF4B5563);
  static const cobalt = Color(0xFF0057D9);
  static const positiveSaved = Color(0xFF007A52);
  static const emissions = Color(0xFF8A4B08);
  static const warning = Color(0xFFB42318);
  static const divider = Color(0xFF7B8492);

  static const light = ClimateColorSet(
    surfacePrimary: surfacePrimary,
    surfaceSecondary: surfaceSecondary,
    textPrimary: textPrimary,
    textSecondary: textSecondary,
    cobalt: cobalt,
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

  static const double radiusSmall = 4;
  static const double radiusLarge = 8;
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
  ClimateTypography lerp(
    covariant ClimateTypography? other,
    double t,
  ) {
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
      primary: ClimateColors.cobalt,
      onPrimary: ClimateColors.surfacePrimary,
      primaryContainer: ClimateColors.cobalt,
      onPrimaryContainer: ClimateColors.surfacePrimary,
      secondary: ClimateColors.cobalt,
      onSecondary: ClimateColors.surfacePrimary,
      secondaryContainer: ClimateColors.cobalt,
      onSecondaryContainer: ClimateColors.surfacePrimary,
      tertiary: ClimateColors.cobalt,
      onTertiary: ClimateColors.surfacePrimary,
      error: ClimateColors.warning,
      onError: ClimateColors.surfacePrimary,
      surface: ClimateColors.surfacePrimary,
      onSurface: ClimateColors.textPrimary,
      surfaceContainerLowest: ClimateColors.surfacePrimary,
      surfaceContainerLow: ClimateColors.surfaceSecondary,
      surfaceContainer: ClimateColors.surfaceSecondary,
      surfaceContainerHigh: ClimateColors.surfaceSecondary,
      surfaceContainerHighest: ClimateColors.surfaceSecondary,
      onSurfaceVariant: ClimateColors.textSecondary,
      outline: ClimateColors.divider,
      outlineVariant: ClimateColors.divider,
      surfaceTint: Colors.transparent,
    );
    final baseTextTheme = const TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        height: 1.12,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.45,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        height: 1.4,
        fontWeight: FontWeight.w400,
      ),
    );
    final textTheme = _withIbmPlexSans(baseTextTheme).apply(
      bodyColor: ClimateColors.textPrimary,
      displayColor: ClimateColors.textPrimary,
    );
    final controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ClimateSpacing.radiusSmall),
    );
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(ClimateSpacing.radiusSmall),
      borderSide: const BorderSide(color: ClimateColors.divider),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: textTheme,
      primaryTextTheme: _withIbmPlexSans(baseTextTheme),
      extensions: [
        ClimateTypography(
          number: GoogleFonts.ibmPlexMono(fontWeight: FontWeight.w400),
          unit: GoogleFonts.ibmPlexMono(fontWeight: FontWeight.w500),
          tableFigure: GoogleFonts.ibmPlexMono(fontWeight: FontWeight.w600),
        ),
      ],
      scaffoldBackgroundColor: ClimateColors.surfacePrimary,
      canvasColor: ClimateColors.surfacePrimary,
      dividerColor: ClimateColors.divider,
      shadowColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: ClimateColors.surfacePrimary,
        foregroundColor: ClimateColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(
        color: ClimateColors.divider,
        thickness: 1,
      ),
      cardTheme: CardThemeData(
        color: ClimateColors.surfaceSecondary,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ClimateSpacing.radiusSmall),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: ClimateColors.surfacePrimary,
          backgroundColor: ClimateColors.cobalt,
          shape: controlShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ClimateColors.cobalt,
          side: const BorderSide(color: ClimateColors.cobalt),
          shape: controlShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ClimateColors.cobalt,
          shape: controlShape,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: fieldBorder,
        focusedBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: ClimateColors.cobalt),
        ),
        errorBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: ClimateColors.warning),
        ),
        focusedErrorBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: ClimateColors.warning),
        ),
      ),
    );
  }

  static TextTheme _withIbmPlexSans(TextTheme textTheme) {
    return TextTheme(
      displayLarge: GoogleFonts.ibmPlexSans(
        textStyle: textTheme.displayLarge,
      ),
      titleMedium: GoogleFonts.ibmPlexSans(
        textStyle: textTheme.titleMedium,
      ),
      bodyLarge: GoogleFonts.ibmPlexSans(textStyle: textTheme.bodyLarge),
      bodyMedium: GoogleFonts.ibmPlexSans(textStyle: textTheme.bodyMedium),
      bodySmall: GoogleFonts.ibmPlexSans(textStyle: textTheme.bodySmall),
    );
  }
}
