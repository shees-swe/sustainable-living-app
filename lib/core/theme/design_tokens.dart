import 'package:flutter/material.dart';

abstract final class DesignTokens {
  static const canvas = Color(0xFFF7F2E8);
  static const surface = Color(0xFFFFFEFA);
  static const surfaceMuted = Color(0xFFEDE8DD);
  static const surfaceRaised = Color(0xFFE4DED1);
  static const surfaceStrong = Color(0xFFDCD5C7);
  static const surfaceBlue = Color(0xFFDEEAF3);
  static const surfaceCoral = Color(0xFFF2DFD7);
  static const surfaceSun = Color(0xFFF3E4BE);

  static const ink = Color(0xFF182A38);
  static const inkMuted = Color(0xFF4F6069);
  static const blue = Color(0xFF315D86);
  static const blueInk = Color(0xFF17344C);
  static const coral = Color(0xFF954A30);
  static const coralInk = Color(0xFF4D281C);
  static const sun = Color(0xFFA05218);
  static const sunInk = Color(0xFF392B08);
  static const positive = Color(0xFF28624C);
  static const warning = Color(0xFFA83035);
  static const divider = Color(0xFF8A938F);
  static const dividerSubtle = Color(0xFFD7D1C4);

  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;
  static const double space64 = 64;

  static const double radiusSmall = 8;
  static const double radiusControl = 14;
  static const double radiusCard = 22;
  static const double radiusLarge = 28;
  static const double radiusPill = 999;

  static const double iconSmall = 18;
  static const double iconMedium = 24;
  static const double iconLarge = 32;
  static const double minimumTouchTarget = 48;

  static const durationQuick = Duration(milliseconds: 120);
  static const durationStandard = Duration(milliseconds: 200);
}
