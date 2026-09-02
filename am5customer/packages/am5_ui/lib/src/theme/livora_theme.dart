import 'package:flutter/material.dart';

import 'livora_colors.dart';
import 'livora_spacing.dart';
import 'livora_typography.dart';

abstract final class LivoraTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.light(
      primary: LivoraColors.primary,
      onPrimary: LivoraColors.onPrimary,
      primaryContainer: LivoraColors.primaryContainer,
      secondary: LivoraColors.accent,
      onSecondary: LivoraColors.onSurface,
      surface: LivoraColors.surface,
      onSurface: LivoraColors.onSurface,
      onSurfaceVariant: LivoraColors.onSurfaceVariant,
      error: LivoraColors.error,
      outline: LivoraColors.outline,
      outlineVariant: LivoraColors.outlineVariant,
    );

    return _base(
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffold: LivoraColors.surface,
      card: LivoraColors.surfaceContainer,
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.dark(
      primary: LivoraColors.darkPrimary,
      onPrimary: LivoraColors.darkSurface,
      primaryContainer: LivoraColors.primaryContainer,
      secondary: LivoraColors.darkAccent,
      onSecondary: LivoraColors.darkSurface,
      surface: LivoraColors.darkSurface,
      onSurface: LivoraColors.darkOnSurface,
      onSurfaceVariant: const Color(0xFFA8B0AC),
      error: LivoraColors.error,
      outline: const Color(0xFF3A4240),
      outlineVariant: const Color(0xFF2E3533),
      surfaceContainer: LivoraColors.darkSurfaceContainer,
      surfaceContainerHigh: LivoraColors.darkSurfaceContainer,
      surfaceContainerHighest: const Color(0xFF252A28),
      surfaceContainerLow: LivoraColors.darkMuted,
      surfaceContainerLowest: LivoraColors.darkSurface,
    );

    return _base(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffold: LivoraColors.darkSurface,
      card: LivoraColors.darkSurfaceContainer,
    );
  }

  static ThemeData _base({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color scaffold,
    required Color card,
  }) {
    final textTheme = LivoraTypography.textTheme(dark: brightness == Brightness.dark);
    final radius = BorderRadius.circular(LivoraSpacing.radii.lg);

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
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LivoraSpacing.radii.md),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LivoraSpacing.radii.md),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LivoraSpacing.radii.md),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LivoraSpacing.radii.md),
          borderSide: BorderSide(color: colorScheme.error),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LivoraSpacing.radii.md),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LivoraSpacing.radii.md),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LivoraSpacing.radii.md),
        ),
      ),
      dividerTheme: DividerThemeData(color: colorScheme.outlineVariant, space: 1),
    );
  }
}
