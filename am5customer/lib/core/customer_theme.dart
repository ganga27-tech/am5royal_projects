import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:am5_ui/am5_ui.dart';

import 'design_system/am5_colors.dart';
import 'design_system/am5_spacing.dart';

/// Premium AM5 Royal customer theme — Material 3 with red brand identity.
abstract final class CustomerTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.light(
      primary: Am5Colors.brandRed,
      onPrimary: Colors.white,
      primaryContainer: Am5Colors.lightRed,
      onPrimaryContainer: Am5Colors.deepRed,
      secondary: Am5Colors.warning,
      onSecondary: Am5Colors.textPrimary,
      surface: Am5Colors.surface,
      onSurface: Am5Colors.textPrimary,
      onSurfaceVariant: Am5Colors.textSecondary,
      outline: Am5Colors.outline,
      error: Am5Colors.brandRed,
    );

    return _base(
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffold: Am5Colors.background,
      card: Am5Colors.surface,
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.dark(
      primary: const Color(0xFFF87171),
      onPrimary: Am5Colors.darkSurface,
      primaryContainer: Am5Colors.deepRed,
      onPrimaryContainer: Colors.white,
      secondary: Am5Colors.warning,
      surface: Am5Colors.darkSurface,
      onSurface: Am5Colors.darkTextPrimary,
      onSurfaceVariant: Am5Colors.darkTextSecondary,
      outline: const Color(0xFF374151),
      surfaceContainer: Am5Colors.darkCard,
    );

    return _base(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffold: Am5Colors.darkSurface,
      card: Am5Colors.darkCard,
    );
  }

  static ThemeData _base({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color scaffold,
    required Color card,
  }) {
    final baseText = LivoraTypography.textTheme(dark: brightness == Brightness.dark);
    final textTheme = baseText.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ).copyWith(
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
        height: 1.2,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
    );

    final radius = BorderRadius.circular(Am5Spacing.radiusMd);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffold,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: radius),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.light ? Am5Colors.lightRed.withValues(alpha: 0.35) : card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        hintStyle: textTheme.bodyMedium,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Am5Spacing.radiusMd),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.4)),
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Am5Spacing.radiusMd),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Am5Colors.lightRed,
        selectedColor: colorScheme.primary,
        labelStyle: textTheme.labelLarge!,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Am5Spacing.radiusFull),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      ),
      dividerTheme: DividerThemeData(color: colorScheme.outline.withValues(alpha: 0.5)),
    );
  }
}
