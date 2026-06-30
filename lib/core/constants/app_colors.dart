import 'package:flutter/material.dart';

/// A completely minimal, monochromatic, award-winning palette.
/// Focuses on extreme contrast, vast whitespace, and absolute simplicity.
class AppColors {
  AppColors._();

  // ── Core Neutrals ────────────────────────────────────────────────────────
  static const Color black = Color(0xFF0A0A0A);
  static const Color white = Color(0xFFFAFAFA);

  static const Color grey50  = Color(0xFFF9F9F9);
  static const Color grey100 = Color(0xFFF0F0F0);
  static const Color grey200 = Color(0xFFE4E4E7);
  static const Color grey300 = Color(0xFFD1D1D6);
  static const Color grey400 = Color(0xFF8E8E98);
  static const Color grey500 = Color(0xFF636370);
  static const Color grey600 = Color(0xFF3A3A3F);
  static const Color grey700 = Color(0xFF2C2C31);
  static const Color grey800 = Color(0xFF1E1E24);
  static const Color grey900 = Color(0xFF111116);

  // ── Accent ───────────────────────────────────────────────────────────────
  static const Color accentGold  = Color(0xFFC9A84C);
  static const Color accentGoldDim = Color(0xFF7A5E2A);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color errorLight = Color(0xFFC94A4A);
  static const Color errorDark  = Color(0xFFE07070);

  // ── Light Theme ──────────────────────────────────────────────────────────
  static const Color background      = grey50;
  static const Color surface         = white;
  static const Color surfaceVariant  = grey100;
  static const Color onSurface       = black;
  static const Color onSurfaceVariant = grey500;
  static const Color borderLight     = grey200;

  // ── Dark Theme ───────────────────────────────────────────────────────────
  static const Color darkBackground      = Color(0xFF0A0A0C);
  static const Color darkSurface         = Color(0xFF111116);
  static const Color darkSurfaceElevated = Color(0xFF18181F);
  static const Color darkSurfaceVariant  = Color(0xFF1E1E28);
  static const Color darkOnSurface       = Color(0xFFF0F0F2);
  static const Color darkOnSurfaceVariant = Color(0xFF888894);
  static const Color borderDark          = Color(0xFF252530);
}
