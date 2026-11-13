import 'package:flutter/material.dart';

import 'design_tokens.dart';

abstract final class ClimateColors {
  static const canvas = DesignTokens.canvas;
  static const surfacePrimary = DesignTokens.surface;
  static const surfaceSecondary = DesignTokens.surfaceMuted;
  static const textPrimary = DesignTokens.ink;
  static const textSecondary = DesignTokens.inkMuted;
  static const cobalt = DesignTokens.blue;
  static const coral = DesignTokens.coral;
  static const sun = DesignTokens.sun;
  static const positiveSaved = DesignTokens.positive;
  static const emissions = DesignTokens.sun;
  static const warning = DesignTokens.warning;
  static const divider = DesignTokens.divider;
  static const dividerSubtle = DesignTokens.dividerSubtle;

  static const light = ClimateColorSet(
    canvas: canvas,
    surfacePrimary: surfacePrimary,
    surfaceSecondary: surfaceSecondary,
    textPrimary: textPrimary,
    textSecondary: textSecondary,
    cobalt: cobalt,
    coral: coral,
    sun: sun,
    positiveSaved: positiveSaved,
    emissions: emissions,
    warning: warning,
    divider: divider,
  );
}

@immutable
class ClimateColorSet {
  const ClimateColorSet({
    required this.canvas,
    required this.surfacePrimary,
    required this.surfaceSecondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.cobalt,
    required this.coral,
    required this.sun,
    required this.positiveSaved,
    required this.emissions,
    required this.warning,
    required this.divider,
  });

  final Color canvas;
  final Color surfacePrimary;
  final Color surfaceSecondary;
  final Color textPrimary;
  final Color textSecondary;
  final Color cobalt;
  final Color coral;
  final Color sun;
  final Color positiveSaved;
  final Color emissions;
  final Color warning;
  final Color divider;
}

abstract final class ClimateSpacing {
  static const double base = DesignTokens.space8;
  static const double space4 = DesignTokens.space4;
  static const double space8 = DesignTokens.space8;
  static const double space12 = DesignTokens.space12;
  static const double space16 = DesignTokens.space16;
  static const double space24 = DesignTokens.space24;
  static const double space32 = DesignTokens.space32;
  static const double space40 = DesignTokens.space40;
  static const double space48 = DesignTokens.space48;
  static const double space64 = DesignTokens.space64;
  static const values = <double>[
    space4,
    space8,
    space12,
    space16,
    space24,
    space32,
    space40,
    space48,
    space64,
  ];

  static const double radiusSmall = DesignTokens.radiusSmall;
  static const double radiusLarge = DesignTokens.radiusCard;
  static const double radiusControl = DesignTokens.radiusControl;
  static const double radiusPill = DesignTokens.radiusPill;
  static const double minimumTouchTarget = DesignTokens.minimumTouchTarget;
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
      primary: DesignTokens.blue,
      onPrimary: Colors.white,
      primaryContainer: DesignTokens.surfaceBlue,
      onPrimaryContainer: DesignTokens.blueInk,
      secondary: DesignTokens.coral,
      onSecondary: Colors.white,
      secondaryContainer: DesignTokens.surfaceCoral,
      onSecondaryContainer: DesignTokens.coralInk,
      tertiary: DesignTokens.sun,
      onTertiary: Colors.white,
      tertiaryContainer: DesignTokens.surfaceSun,
      onTertiaryContainer: DesignTokens.sunInk,
      error: DesignTokens.warning,
      onError: Colors.white,
      surface: DesignTokens.surface,
      onSurface: DesignTokens.ink,
      surfaceContainerLowest: DesignTokens.surface,
      surfaceContainerLow: DesignTokens.canvas,
      surfaceContainer: DesignTokens.surfaceMuted,
      surfaceContainerHigh: DesignTokens.surfaceRaised,
      surfaceContainerHighest: DesignTokens.surfaceStrong,
      onSurfaceVariant: DesignTokens.inkMuted,
      outline: DesignTokens.divider,
      outlineVariant: DesignTokens.dividerSubtle,
      inverseSurface: DesignTokens.ink,
      onInverseSurface: DesignTokens.surface,
      inversePrimary: Color(0xFFB6CBE0),
      surfaceTint: Colors.transparent,
    );
    final textTheme = const TextTheme(
      displayLarge: TextStyle(
        fontSize: 40,
        height: 1.08,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: TextStyle(
        fontSize: 34,
        height: 1.12,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: TextStyle(
        fontSize: 30,
        height: 1.2,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        height: 1.25,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.4,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.55,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        height: 1.45,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        height: 1.3,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        height: 1.3,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        height: 1.3,
        fontWeight: FontWeight.w500,
      ),
    ).apply(
      fontFamily: 'IBMPlexSans',
      bodyColor: DesignTokens.ink,
      displayColor: DesignTokens.ink,
    );
    final controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusControl),
    );
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusControl),
      borderSide: const BorderSide(color: DesignTokens.dividerSubtle),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
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
      scaffoldBackgroundColor: DesignTokens.canvas,
      canvasColor: DesignTokens.canvas,
      dividerColor: DesignTokens.dividerSubtle,
      shadowColor: const Color(0x1A182A38),
      appBarTheme: const AppBarTheme(
        backgroundColor: DesignTokens.canvas,
        foregroundColor: DesignTokens.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: 'IBMPlexSans',
          color: DesignTokens.ink,
          fontSize: 20,
          height: 1.3,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: DesignTokens.dividerSubtle,
        thickness: 1,
        space: DesignTokens.space24,
      ),
      cardTheme: CardThemeData(
        color: DesignTokens.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: DesignTokens.space4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusCard),
          side: const BorderSide(color: DesignTokens.dividerSubtle),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: DesignTokens.space16),
        minVerticalPadding: DesignTokens.space12,
        iconColor: DesignTokens.inkMuted,
        textColor: DesignTokens.ink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(DesignTokens.radiusControl),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: DesignTokens.blue,
          minimumSize: const Size.fromHeight(
            DesignTokens.minimumTouchTarget,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.space24,
            vertical: DesignTokens.space12,
          ),
          shape: controlShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DesignTokens.blue,
          minimumSize: const Size.fromHeight(
            DesignTokens.minimumTouchTarget,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.space24,
            vertical: DesignTokens.space12,
          ),
          side: const BorderSide(color: DesignTokens.blue, width: 1.4),
          shape: controlShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DesignTokens.blue,
          minimumSize: const Size.fromHeight(
            DesignTokens.minimumTouchTarget,
          ),
          shape: controlShape,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: DesignTokens.inkMuted,
          minimumSize: const Size(
            DesignTokens.minimumTouchTarget,
            DesignTokens.minimumTouchTarget,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DesignTokens.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.space16,
          vertical: DesignTokens.space12,
        ),
        labelStyle: const TextStyle(color: DesignTokens.inkMuted),
        hintStyle: const TextStyle(color: DesignTokens.inkMuted),
        enabledBorder: fieldBorder,
        focusedBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: DesignTokens.blue, width: 2),
        ),
        errorBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: DesignTokens.warning, width: 1.5),
        ),
        focusedErrorBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: DesignTokens.warning, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: DesignTokens.surfaceMuted,
        selectedColor: DesignTokens.surfaceBlue,
        labelStyle: const TextStyle(color: DesignTokens.ink),
        secondaryLabelStyle: const TextStyle(color: DesignTokens.blueInk),
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.space8,
          vertical: DesignTokens.space4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
          side: const BorderSide(color: DesignTokens.dividerSubtle),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: DesignTokens.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusCard),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: DesignTokens.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(DesignTokens.radiusLarge),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: DesignTokens.ink,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusControl),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: DesignTokens.blue,
        linearTrackColor: DesignTokens.surfaceBlue,
        circularTrackColor: DesignTokens.surfaceBlue,
      ),
    );
  }
}
