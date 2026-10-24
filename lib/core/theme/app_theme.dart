import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF0D5C75);
  static const Color primaryDark = Color(0xFF004357);
  static const Color secondary = Color(0xFF0F766E);
  static const Color tertiary = Color(0xFFB45309);

  // Surface & Neutral Colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDim = Color(0xFFD2D9F4);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderMedium = Color(0xFFCBD5E1);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

  // Functional Status Accents
  static const Color success = Color(0xFF15803D);
  static const Color successBg = Color(0xFFDCFCE7);
  
  static const Color warning = Color(0xFFB45309);
  static const Color warningBg = Color(0xFFFEF3C7);
  
  static const Color critical = Color(0xFFB91C1C);
  static const Color criticalBg = Color(0xFFFEE2E2);
  
  static const Color info = Color(0xFF0369A1);
  static const Color infoBg = Color(0xFFE0F2FE);

  static const Color amberHeaderBg = Color(0xFFFEF3C7);
  static const Color accentSecondary = Color(0xFFD97706);
  static const Color accentSecondaryBg = Color(0xFFFFFBEB);

  // Active Navigation Pill
  static const Color activePillBg = Color(0xFFF0FDFA);
  static const Color activePillBorder = Color(0xFF99EFE5);
}

abstract class AppTypography {
  static TextStyle titleMd = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 24 / 16,
    color: AppColors.textPrimary,
  );
  static TextStyle displayLg = GoogleFonts.inter(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 44 / 36,
    letterSpacing: -0.02 * 36,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineXl = GoogleFonts.inter(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 38 / 30,
    letterSpacing: -0.015 * 30,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineLg = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
    letterSpacing: -0.01 * 24,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineLgMobile = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    letterSpacing: -0.01 * 20,
    color: AppColors.textPrimary,
  );

  static TextStyle headlineMd = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 26 / 18,
    letterSpacing: -0.005 * 18,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyLg = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 24 / 16,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMd = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    color: AppColors.textPrimary,
  );

  static TextStyle bodySm = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 18 / 13,
    color: AppColors.textSecondary,
  );

  static TextStyle labelLg = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    letterSpacing: 0.01 * 14,
    color: AppColors.textPrimary,
  );

  static TextStyle labelMd = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    letterSpacing: 0.02 * 12,
    color: AppColors.textSecondary,
  );

  static TextStyle labelSm = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 14 / 11,
    letterSpacing: 0.04 * 11,
    color: AppColors.textSecondary,
  );

  static TextStyle codeData = GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 18 / 13,
    color: AppColors.textPrimary,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        error: AppColors.critical,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        outline: AppColors.borderMedium,
        outlineVariant: AppColors.borderLight,
      ),
      textTheme: baseTextTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.borderLight, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ),
    );
  }
}
