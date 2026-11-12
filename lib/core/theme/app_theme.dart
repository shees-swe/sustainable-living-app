import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'design_tokens.dart';

abstract final class ClimateColors {
  static const surfacePrimary = Color(0xFFFAFAF5);
  static const surfaceSecondary = Color(0xFFF2F2EC);
  static const textPrimary = Color(0xFF1A1C1E);
  static const textSecondary = Color(0xFF5C5F63);
  static const cobalt = Color(0xFF1B5E20);
  static const positiveSaved = Color(0xFF2E7D32);
  static const emissions = Color(0xFFB74700);
  static const warning = Color(0xFFC62828);
  static const divider = Color(0xFFDCD8CC);

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
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;
  static const values = <double>[
    space4,
    space8,
    space12,
    space16,
    space24,
    space32,
    space40,
    space48,
  ];

  static const double radiusSmall = 8;
  static const double radiusLarge = 16;
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
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFE8F5E9),
      onPrimaryContainer: Color(0xFF0D3B0F),
      secondary: Color(0xFFE65100),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFFFF3E0),
      onSecondaryContainer: Color(0xFF4E2600),
      tertiary: Color(0xFF00695C),
      onTertiary: Color(0xFFFFFFFF),
      error: ClimateColors.warning,
      onError: Color(0xFFFFFFFF),
      surface: ClimateColors.surfacePrimary,
      onSurface: ClimateColors.textPrimary,
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: ClimateColors.surfaceSecondary,
      surfaceContainer: ClimateColors.surfaceSecondary,
      surfaceContainerHigh: Color(0xFFECECE4),
      surfaceContainerHighest: Color(0xFFE6E6DE),
      onSurfaceVariant: ClimateColors.textSecondary,
      outline: ClimateColors.divider,
      outlineVariant: Color(0xFFE8E8E0),
      surfaceTint: Colors.transparent,
    );
    final baseTextTheme = const TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        height: 1.12,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        height: 1.16,
        fontWeight: FontWeight.w600,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        height: 1.22,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        height: 1.25,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        height: 1.29,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        height: 1.33,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        height: 1.27,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        height: 1.43,
        fontWeight: FontWeight.w600,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        height: 1.43,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        height: 1.33,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        height: 1.45,
        fontWeight: FontWeight.w600,
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
        VerdantColors.light,
      ],
      scaffoldBackgroundColor: ClimateColors.surfacePrimary,
      canvasColor: ClimateColors.surfacePrimary,
      dividerColor: ClimateColors.divider,
      shadowColor: const Color(0x1A000000),
      appBarTheme: AppBarTheme(
        backgroundColor: ClimateColors.surfacePrimary,
        foregroundColor: ClimateColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.ibmPlexSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ClimateColors.textPrimary,
          height: 1.33,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ClimateColors.divider,
        thickness: 1,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFFFFFFF),
        surfaceTintColor: Colors.transparent,
        shadowColor: const Color(0x1A000000),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ClimateSpacing.radiusLarge),
          side: const BorderSide(color: Color(0xFFE8E8E0), width: 1),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: const Color(0xFFFFFFFF),
          backgroundColor: ClimateColors.cobalt,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ClimateSpacing.radiusSmall),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.ibmPlexSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ClimateColors.cobalt,
          side: const BorderSide(color: ClimateColors.cobalt),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ClimateSpacing.radiusSmall),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.ibmPlexSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ClimateColors.cobalt,
          shape: controlShape,
          textStyle: GoogleFonts.ibmPlexSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        enabledBorder: fieldBorder,
        focusedBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: ClimateColors.cobalt, width: 2),
        ),
        errorBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: ClimateColors.warning),
        ),
        focusedErrorBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: ClimateColors.warning, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ClimateSpacing.radiusSmall),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        linearTrackColor: Color(0xFFE8F5E9),
        color: ClimateColors.cobalt,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ClimateColors.cobalt;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        surfaceTintColor: Colors.transparent,
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(),
      ),
    );
  }

  static TextTheme _withIbmPlexSans(TextTheme textTheme) {
    return TextTheme(
      displayLarge: GoogleFonts.ibmPlexSans(textStyle: textTheme.displayLarge),
      displayMedium: GoogleFonts.ibmPlexSans(textStyle: textTheme.displayMedium),
      displaySmall: GoogleFonts.ibmPlexSans(textStyle: textTheme.displaySmall),
      headlineLarge: GoogleFonts.ibmPlexSans(textStyle: textTheme.headlineLarge),
      headlineMedium: GoogleFonts.ibmPlexSans(textStyle: textTheme.headlineMedium),
      headlineSmall: GoogleFonts.ibmPlexSans(textStyle: textTheme.headlineSmall),
      titleLarge: GoogleFonts.ibmPlexSans(textStyle: textTheme.titleLarge),
      titleMedium: GoogleFonts.ibmPlexSans(textStyle: textTheme.titleMedium),
      titleSmall: GoogleFonts.ibmPlexSans(textStyle: textTheme.titleSmall),
      labelLarge: GoogleFonts.ibmPlexSans(textStyle: textTheme.labelLarge),
      labelMedium: GoogleFonts.ibmPlexSans(textStyle: textTheme.labelMedium),
      labelSmall: GoogleFonts.ibmPlexSans(textStyle: textTheme.labelSmall),
      bodyLarge: GoogleFonts.ibmPlexSans(textStyle: textTheme.bodyLarge),
      bodyMedium: GoogleFonts.ibmPlexSans(textStyle: textTheme.bodyMedium),
      bodySmall: GoogleFonts.ibmPlexSans(textStyle: textTheme.bodySmall),
    );
  }
}
