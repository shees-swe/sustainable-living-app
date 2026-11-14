import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart' show ClimateTypography;

/// Colour tokens for the "Living" visual system: deep forest ink, a single
/// lime accent, and soft white cards on a cool off-white ground.
abstract final class LivingColors {
  static const ink = Color(0xFF10231C);
  static const lime = Color(0xFFC6F432);
  static const ground = Color(0xFFF4F6F3);
  static const card = Color(0xFFFFFFFF);
  static const muted = Color(0xFF55655E);
  static const track = Color(0xFFE3E9E4);
  static const inkRaised = Color(0xFF2B4A3F);
  static const onInkMuted = Color(0xFFB9C7C0);
  static const emissions = Color(0xFFC2410C);
  static const error = Color(0xFFB42318);
  static const outline = Color(0xFF7B8C84);
}

abstract final class LivingShape {
  static const double card = 24;
  static const double hero = 28;
  static const double field = 16;
  static const double navBar = 34;
}

/// Typeface switch. The mock-ups use Plus Jakarta Sans. The app currently
/// bundles IBM Plex Sans, so that is the safe default. To switch: add
/// PlusJakartaSans-Regular/Medium/SemiBold/Bold.ttf to assets/fonts/ and set
/// [useJakarta] to true in main() before the first frame.
abstract final class LivingTypeface {
  static bool useJakarta = false;

  static TextStyle apply(TextStyle style) => useJakarta
      ? GoogleFonts.plusJakartaSans(textStyle: style)
      : GoogleFonts.ibmPlexSans(textStyle: style);
}

abstract final class LivingTheme {
  static final ThemeData light = _build();

  static TextTheme _textTheme() {
    TextStyle t(double size, FontWeight weight, double height) =>
        LivingTypeface.apply(
          TextStyle(
            fontSize: size,
            fontWeight: weight,
            height: height,
            color: LivingColors.ink,
          ),
        );
    return TextTheme(
      displaySmall: t(48, FontWeight.w700, 1.05),
      headlineMedium: t(30, FontWeight.w700, 1.2),
      headlineSmall: t(24, FontWeight.w700, 1.25),
      titleLarge: t(22, FontWeight.w700, 1.2),
      titleMedium: t(16, FontWeight.w700, 1.4),
      titleSmall: t(14, FontWeight.w700, 1.4),
      bodyLarge: t(16, FontWeight.w400, 1.5),
      bodyMedium: t(14, FontWeight.w400, 1.45),
      bodySmall: t(12, FontWeight.w500, 1.4),
      labelLarge: t(14, FontWeight.w700, 1.2),
      labelMedium: t(13, FontWeight.w600, 1.3),
    );
  }

  static ThemeData _build() {
    const scheme = ColorScheme.light(
      primary: LivingColors.ink,
      onPrimary: LivingColors.card,
      primaryContainer: LivingColors.lime,
      onPrimaryContainer: LivingColors.ink,
      secondary: LivingColors.lime,
      onSecondary: LivingColors.ink,
      secondaryContainer: LivingColors.lime,
      onSecondaryContainer: LivingColors.ink,
      tertiary: LivingColors.inkRaised,
      onTertiary: LivingColors.card,
      error: LivingColors.error,
      onError: LivingColors.card,
      surface: LivingColors.card,
      onSurface: LivingColors.ink,
      surfaceContainerLowest: LivingColors.card,
      surfaceContainerLow: LivingColors.ground,
      surfaceContainer: LivingColors.ground,
      surfaceContainerHigh: LivingColors.track,
      surfaceContainerHighest: LivingColors.track,
      onSurfaceVariant: LivingColors.muted,
      outline: LivingColors.outline,
      outlineVariant: LivingColors.track,
      surfaceTint: Colors.transparent,
    );
    final textTheme = _textTheme();
    const stadium = StadiumBorder();
    const minSize = Size(48, 48);
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(LivingShape.field),
      borderSide: width == 0
          ? BorderSide.none
          : BorderSide(color: color, width: width),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      // Existing feature screens read numbers and units from this extension
      // via Theme.of(context).extension<ClimateTypography>()!, so every app
      // theme must register it.
      extensions: <ThemeExtension<dynamic>>[
        ClimateTypography(
          number: GoogleFonts.ibmPlexMono(fontWeight: FontWeight.w400),
          unit: GoogleFonts.ibmPlexMono(fontWeight: FontWeight.w500),
          tableFigure: GoogleFonts.ibmPlexMono(fontWeight: FontWeight.w600),
        ),
      ],
      scaffoldBackgroundColor: LivingColors.ground,
      canvasColor: LivingColors.ground,
      dividerColor: LivingColors.track,
      shadowColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: LivingColors.ground,
        foregroundColor: LivingColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      dividerTheme: const DividerThemeData(
        color: LivingColors.track,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: LivingColors.card,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LivingShape.card),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: LivingColors.ink,
        textColor: LivingColors.ink,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: LivingColors.lime,
          foregroundColor: LivingColors.ink,
          disabledBackgroundColor: LivingColors.track,
          disabledForegroundColor: LivingColors.muted,
          minimumSize: minSize,
          shape: stadium,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: LivingColors.ink,
          side: const BorderSide(color: LivingColors.ink, width: 2),
          minimumSize: minSize,
          shape: stadium,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: LivingColors.ink,
          minimumSize: minSize,
          shape: stadium,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LivingColors.card,
        border: border(LivingColors.card, 0),
        enabledBorder: border(LivingColors.card, 0),
        focusedBorder: border(LivingColors.ink, 2),
        errorBorder: border(LivingColors.error, 2),
        focusedErrorBorder: border(LivingColors.error, 2),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: LivingColors.card,
        shape: StadiumBorder(),
        side: BorderSide.none,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: LivingColors.ink,
        linearTrackColor: LivingColors.track,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: LivingColors.ink,
        contentTextStyle: TextStyle(color: LivingColors.card),
      ),
    );
  }
}
