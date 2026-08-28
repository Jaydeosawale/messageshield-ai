import 'package:flutter/material.dart';

class AppColors {
  // ============================================================
  // MAIN BACKGROUND
  // ============================================================

  static const Color background = Color(0xFF071E26);

  // Slightly lighter navy used for navigation surfaces
  static const Color backgroundSoft = Color(0xFF0A2832);

  // ============================================================
  // BRAND COLORS
  // ============================================================

  static const Color teal = Color(0xFF37B8B9);

  static const Color tealSoft = Color(0xFF5CCFCB);

  static const Color green = Color(0xFF2EAE78);

  static const Color greenSoft = Color(0xFF55C98F);

  // ============================================================
  // LIGHT CARD SYSTEM
  // ============================================================

  static const Color surface = Color(0xFFF4F4F2);

  static const Color surfaceSoft = Color(0xFFEDEEEE);

  // Dark text used INSIDE light cards
  static const Color cardText = Color(0xFF17303A);

  static const Color cardTextSecondary = Color(0xFF66777E);

  // ============================================================
  // DARK MESSAGE INPUT
  // ============================================================

  static const Color inputBackground = Color(0xFF1A333D);

  static const Color inputBorder = Color(0xFF35515A);

  // ============================================================
  // TEXT ON DARK BACKGROUND
  // ============================================================

  static const Color textPrimary = Color(0xFFF3F6F6);

  static const Color textSecondary = Color(0xFFAEBCC1);

  // ============================================================
  // BORDERS
  // ============================================================

  static const Color border = Color(0xFFCBD4D5);

  static const Color darkBorder = Color(0xFF21434C);

  // ============================================================
  // STATUS COLORS
  // ============================================================

  static const Color danger = Color(0xFFE65B5B);

  static const Color warning = Color(0xFFF2B84B);

  static const Color success = Color(0xFF35B87C);
}

// ================================================================
// APPLICATION THEME
// ================================================================

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,

      brightness: Brightness.dark,

      scaffoldBackgroundColor: Colors.transparent,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.teal,
        secondary: AppColors.green,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      dividerColor: AppColors.darkBorder,

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
        ),

        headlineMedium: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),

        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),

        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),

        bodyLarge: TextStyle(
          color: AppColors.textPrimary,
        ),

        bodyMedium: TextStyle(
          color: AppColors.textSecondary,
        ),

        bodySmall: TextStyle(
          color: AppColors.textSecondary,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,

        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.inputBorder,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.inputBorder,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.teal,
            width: 1.5,
          ),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.inputBackground,
        contentTextStyle: const TextStyle(
          color: AppColors.textPrimary,
        ),

        behavior: SnackBarBehavior.floating,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}