import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'livora_colors.dart';

abstract final class LivoraTypography {
  static TextTheme textTheme({bool dark = false}) {
    final Color body = dark ? LivoraColors.darkOnSurface : LivoraColors.onSurface;
    final Color muted = dark ? const Color(0xFFA8B0AC) : LivoraColors.onSurfaceVariant;

    final display = GoogleFonts.fraunces(
      color: body,
      fontWeight: FontWeight.w600,
      height: 1.15,
      letterSpacing: -0.5,
    );
    final bodyFont = GoogleFonts.plusJakartaSans(
      color: body,
      height: 1.45,
    );

    return TextTheme(
      displayLarge: display.copyWith(fontSize: 40),
      displayMedium: display.copyWith(fontSize: 34),
      displaySmall: display.copyWith(fontSize: 28),
      headlineLarge: display.copyWith(fontSize: 26),
      headlineMedium: display.copyWith(fontSize: 22),
      headlineSmall: display.copyWith(fontSize: 20),
      titleLarge: bodyFont.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
      titleMedium: bodyFont.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: bodyFont.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      bodyLarge: bodyFont.copyWith(fontSize: 16),
      bodyMedium: bodyFont.copyWith(fontSize: 14),
      bodySmall: bodyFont.copyWith(fontSize: 12, color: muted),
      labelLarge: bodyFont.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      labelMedium: bodyFont.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
      labelSmall: bodyFont.copyWith(fontSize: 11, fontWeight: FontWeight.w500, color: muted),
    );
  }
}
