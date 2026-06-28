import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  /// Primary monospaced font for headlines and quotes
  static TextStyle playfair({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
    double? height,
    double? letterSpacing,
    FontStyle fontStyle = FontStyle.normal,
  }) =>
      GoogleFonts.spaceMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        fontStyle: fontStyle,
      );

  /// Secondary monospaced font for UI elements
  static TextStyle dmSans({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.spaceMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextTheme get textTheme {
    return TextTheme(
      displayLarge: playfair(fontSize: 57, fontWeight: FontWeight.w700),
      displayMedium: playfair(fontSize: 45, fontWeight: FontWeight.w700),
      displaySmall: playfair(fontSize: 36, fontWeight: FontWeight.w700),
      headlineLarge: playfair(fontSize: 32, fontWeight: FontWeight.w700),
      headlineMedium: playfair(fontSize: 28, fontWeight: FontWeight.w700),
      headlineSmall: playfair(fontSize: 24, fontWeight: FontWeight.w700),
      titleLarge: dmSans(fontSize: 22, fontWeight: FontWeight.w700),
      titleMedium: dmSans(fontSize: 16, fontWeight: FontWeight.w700),
      titleSmall: dmSans(fontSize: 14, fontWeight: FontWeight.w700),
      bodyLarge: dmSans(fontSize: 16, fontWeight: FontWeight.w400, height: 1.6),
      bodyMedium: dmSans(fontSize: 14, fontWeight: FontWeight.w400, height: 1.6),
      bodySmall: dmSans(fontSize: 12, fontWeight: FontWeight.w400, height: 1.5),
      labelLarge: dmSans(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      labelMedium: dmSans(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      labelSmall: dmSans(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5),
    );
  }
}
