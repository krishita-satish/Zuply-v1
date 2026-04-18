import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Zuply brand color palette — clean, modern, startup-grade.
///
/// Deep green + amber accents for a food sustainability identity;
/// generous whitespace and soft shadows throughout.
class ZuplyColors {
  // ── Primary palette ──
  static const Color primary = Color(0xFF1B5E20);        // Deep Green
  static const Color primaryLight = Color(0xFF4CAF50);    // Light Green
  static const Color accent = Color(0xFFFFC107);          // Amber

  // ── Surfaces ──
  static const Color background = Color(0xFFF9FBF9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceCard = Color(0xFFFFFFFF);

  // ── Text ──
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  // ── Utility ──
  static const Color divider = Color(0xFFE5E7EB);
  static const Color error = Color(0xFFDC2626);
  static const Color veg = Color(0xFF16A34A);
  static const Color nonVeg = Color(0xFFDC2626);
  static const Color emergency = Color(0xFFEA580C);

  // ── Chat ──
  static const Color chatUser = Color(0xFF1B5E20);
  static const Color chatBot = Color(0xFFF0F4F0);

  // ── Scores ──
  static const Color scoreHigh = Color(0xFF16A34A);
  static const Color scoreMed = Color(0xFFF59E0B);
  static const Color scoreLow = Color(0xFFDC2626);
}

/// Application-wide Material 3 theme.
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ZuplyColors.primary,
        primary: ZuplyColors.primary,
        secondary: ZuplyColors.primaryLight,
        tertiary: ZuplyColors.accent,
        surface: ZuplyColors.surface,
        error: ZuplyColors.error,
      ),
      scaffoldBackgroundColor: ZuplyColors.background,
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: ZuplyColors.textPrimary,
        displayColor: ZuplyColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: ZuplyColors.textPrimary,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ZuplyColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: ZuplyColors.surfaceCard,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ZuplyColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ZuplyColors.primary,
          side: const BorderSide(color: ZuplyColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ZuplyColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ZuplyColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ZuplyColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ZuplyColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: GoogleFonts.inter(color: ZuplyColors.textHint),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: ZuplyColors.primary,
        unselectedItemColor: ZuplyColors.textHint,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: ZuplyColors.primaryLight.withValues(alpha: 0.12),
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }
}
