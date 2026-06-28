import 'package:flutter/material.dart';

/// A completely minimal, monochromatic, award-winning palette.
/// Focuses on extreme contrast, vast whitespace, and absolute simplicity.
class AppColors {
  AppColors._();

  // ── Core Neutrals ────────────────────────────────────────────────────────
  static const Color black = Color(0xFF0D0D0D);
  static const Color white = Color(0xFFFFFFFF);
  
  static const Color grey50 = Color(0xFFF9F9F9);
  static const Color grey100 = Color(0xFFF4F4F4);
  static const Color grey200 = Color(0xFFEAEAEA);
  static const Color grey300 = Color(0xFFD4D4D4);
  static const Color grey400 = Color(0xFFA3A3A3);
  static const Color grey500 = Color(0xFF737373);
  static const Color grey800 = Color(0xFF262626);
  static const Color grey900 = Color(0xFF171717);

  // ── Semantic ─────────────────────────────────────────────────────────────
  // Even errors use a muted, elegant red rather than a stark vibrant one
  static const Color errorLight = Color(0xFFC94A4A);
  static const Color errorDark = Color(0xFFE27B7B);

  // ── Light Theme ──────────────────────────────────────────────────────────
  static const Color background = grey50;
  static const Color surface = white;
  static const Color surfaceVariant = grey100;
  static const Color onSurface = black;
  static const Color onSurfaceVariant = grey500;
  static const Color borderLight = grey200;

  // ── Dark Theme ───────────────────────────────────────────────────────────
  static const Color darkBackground = black;
  static const Color darkSurface = grey900;
  static const Color darkSurfaceVariant = grey800;
  static const Color darkOnSurface = white;
  static const Color darkOnSurfaceVariant = grey400;
  static const Color borderDark = grey800;
}
