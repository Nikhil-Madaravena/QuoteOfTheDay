import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  // Ultra-minimalist sharp or very subtle curves.
  static final _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  );
  
  static final _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
  );
  
  static final _inputBorderDark = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
  );

  // ── Light Theme ──────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    const cs = ColorScheme.light(
      primary: AppColors.black,
      onPrimary: AppColors.white,
      secondary: AppColors.grey800,
      onSecondary: AppColors.white,
      error: AppColors.errorLight,
      onError: AppColors.white,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceContainerHighest: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.borderLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: AppTypography.textTheme,
      scaffoldBackgroundColor: AppColors.background,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: _shape,
        color: AppColors.surface,
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.onSurface,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTypography.playfair(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: _shape,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          textStyle: AppTypography.dmSans(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1.0),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.onSurface,
          textStyle: AppTypography.dmSans(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: _inputBorder,
        enabledBorder: _inputBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: const BorderSide(color: AppColors.black, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: const BorderSide(color: AppColors.errorLight, width: 1),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        labelStyle: AppTypography.dmSans(color: AppColors.onSurfaceVariant, fontSize: 14),
        hintStyle: AppTypography.dmSans(color: AppColors.onSurfaceVariant, fontSize: 14),
        prefixIconColor: AppColors.onSurfaceVariant,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: _shape,
        backgroundColor: AppColors.black,
        contentTextStyle: AppTypography.dmSans(color: AppColors.white, fontSize: 14),
      ),
    );
  }

  // ── Dark Theme ───────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    const cs = ColorScheme.dark(
      primary: AppColors.accentGold,
      onPrimary: AppColors.black,
      secondary: AppColors.darkOnSurfaceVariant,
      onSecondary: AppColors.black,
      error: AppColors.errorDark,
      onError: AppColors.black,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkOnSurface,
      surfaceContainerHighest: AppColors.darkSurfaceVariant,
      onSurfaceVariant: AppColors.darkOnSurfaceVariant,
      outline: AppColors.borderDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColors.darkOnSurface,
        displayColor: AppColors.darkOnSurface,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: _shape,
        color: AppColors.darkSurface,
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkOnSurface,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTypography.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 3.0,
          color: AppColors.darkOnSurface,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accentGold,
          foregroundColor: AppColors.black,
          shape: _shape,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          textStyle: AppTypography.dmSans(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentGold,
          textStyle: AppTypography.dmSans(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: _inputBorderDark,
        enabledBorder: _inputBorderDark,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentGold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorDark, width: 1),
        ),
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        labelStyle: AppTypography.dmSans(color: AppColors.darkOnSurfaceVariant, fontSize: 13),
        hintStyle: AppTypography.dmSans(color: AppColors.darkOnSurfaceVariant, fontSize: 13),
        prefixIconColor: AppColors.darkOnSurfaceVariant,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: _shape,
        backgroundColor: AppColors.darkSurfaceVariant,
        contentTextStyle: AppTypography.dmSans(color: AppColors.darkOnSurface, fontSize: 13),
      ),
    );
  }
}
