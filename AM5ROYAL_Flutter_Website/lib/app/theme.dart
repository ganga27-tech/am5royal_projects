import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';

/// Global AM5ROYAL website theme.
///
/// Design system:
/// Premium • Corporate • Modern • Trustworthy
///
/// Typography:
/// Inter
///
/// Colors:
/// Royal Blue • Navy • Gold • Pearl White
///
/// PRODUCTION NOTE: google_fonts fetches font files over the network at
/// runtime by default. For a production launch, consider bundling the
/// Inter .ttf files locally via pubspec.yaml and setting
/// GoogleFonts.config.allowRuntimeFetching = false, so the site doesn't
/// depend on an external CDN and avoids a flash-of-fallback-font on load.
abstract final class AM5RoyalTheme {
  AM5RoyalTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // =========================================================================
      // GLOBAL
      // =========================================================================

      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,

      colorScheme: const ColorScheme.light(
        primary: AppColors.royalBlue,
        onPrimary: AppColors.white,
        secondary: AppColors.accentGold,
        onSecondary: AppColors.navy,
        surface: AppColors.white,
        onSurface: AppColors.heading,
        error: AppColors.error,
        onError: AppColors.white,
      ),

      fontFamily: GoogleFonts.inter().fontFamily,

      // =========================================================================
      // TYPOGRAPHY
      // =========================================================================

      // Built directly instead of GoogleFonts.interTextTheme().copyWith(...) —
      // every field below was being overridden anyway, so the intermediate
      // text theme was wasted work.
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          color: AppColors.heading,
          fontSize: 52,
          fontWeight: FontWeight.w800,
          height: 1.08,
          letterSpacing: -1.2,
        ),

        displayMedium: GoogleFonts.inter(
          color: AppColors.heading,
          fontSize: 44,
          fontWeight: FontWeight.w800,
          height: 1.1,
          letterSpacing: -0.8,
        ),

        displaySmall: GoogleFonts.inter(
          color: AppColors.heading,
          fontSize: 38,
          fontWeight: FontWeight.w800,
          height: 1.15,
        ),

        headlineLarge: GoogleFonts.inter(
          color: AppColors.heading,
          fontSize: 34,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),

        headlineMedium: GoogleFonts.inter(
          color: AppColors.heading,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.25,
        ),

        headlineSmall: GoogleFonts.inter(
          color: AppColors.heading,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),

        titleLarge: GoogleFonts.inter(
          color: AppColors.heading,
          fontSize: 21,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),

        titleMedium: GoogleFonts.inter(
          color: AppColors.heading,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),

        titleSmall: GoogleFonts.inter(
          color: AppColors.heading,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),

        bodyLarge: GoogleFonts.inter(
          color: AppColors.bodyText,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.65,
        ),

        bodyMedium: GoogleFonts.inter(
          color: AppColors.bodyText,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.55,
        ),

        // NOTE: mutedText on AppColors.background is ~3.4:1 contrast,
        // below WCAG AA's 4.5:1 minimum for normal text at this size.
        bodySmall: GoogleFonts.inter(
          color: AppColors.mutedText,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),

        labelLarge: GoogleFonts.inter(
          color: AppColors.heading,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),

        labelMedium: GoogleFonts.inter(
          color: AppColors.heading,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),

        // NOTE: same contrast concern as bodySmall above.
        labelSmall: GoogleFonts.inter(
          color: AppColors.mutedText,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),

      // =========================================================================
      // APP BAR
      // =========================================================================

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.royalBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),

      // =========================================================================
      // ELEVATED BUTTON
      // =========================================================================

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentGold,
          foregroundColor: AppColors.navy,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.mutedText,
          elevation: 0,
          minimumSize: const Size(150, 50),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 15,
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      // =========================================================================
      // OUTLINED BUTTON
      // =========================================================================

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.royalBlue,
          backgroundColor: AppColors.white,
          minimumSize: const Size(150, 50),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 15,
          ),
          side: const BorderSide(
            color: AppColors.royalBlue,
            width: 1.3,
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      // =========================================================================
      // TEXT BUTTON
      // =========================================================================

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.royalBlue,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // =========================================================================
      // CARD
      // =========================================================================

      cardTheme: CardThemeData(
        color: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),

      // =========================================================================
      // INPUT FIELDS
      // =========================================================================

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),

        hintStyle: GoogleFonts.inter(
          color: AppColors.mutedText,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),

        labelStyle: GoogleFonts.inter(
          color: AppColors.bodyText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.royalBlue,
            width: 1.5,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.error,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
      ),

      // =========================================================================
      // DIVIDER
      // =========================================================================

      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // =========================================================================
      // ICONS
      // =========================================================================

      iconTheme: const IconThemeData(
        color: AppColors.royalBlue,
        size: 22,
      ),

      // =========================================================================
      // INTERACTION
      // =========================================================================

      hoverColor: const Color(0x0D0B4EA2),
      splashColor: const Color(0x140B4EA2),
      highlightColor: const Color(0x0A0B4EA2),

      // =========================================================================
      // VISUAL DENSITY
      // =========================================================================

      visualDensity: VisualDensity.standard,
    );
  }
}