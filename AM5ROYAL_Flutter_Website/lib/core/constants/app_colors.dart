import 'package:flutter/material.dart';

/// AM5ROYAL Premium Brand Color System.
///
/// Design direction:
/// Premium • Corporate • Trustworthy • Modern • Royal
///
/// Color hierarchy:
/// Navy → Trust
/// Royal Blue → Technology & Service
/// Gold → Premium Brand Accent
/// Pearl White → Clean UI
abstract final class AppColors {
  AppColors._();

  // ===========================================================================
  // BRAND
  // ===========================================================================

  /// Primary navigation / premium dark surfaces.
  static const Color navy = Color(0xFF071F49);

  /// Main royal blue.
  static const Color royalBlue = Color(0xFF0B4EA2);

  /// Bright interactive blue.
  static const Color brightBlue = Color(0xFF1769D1);

  /// Premium AM5ROYAL gold.
  static const Color accentGold = Color(0xFFF5B301);

  /// Soft champagne gold.
  static const Color softGold = Color(0xFFFFF6D8);

  // ===========================================================================
  // WEBSITE BACKGROUNDS
  // ===========================================================================

  /// Main page background.
  static const Color background = Color(0xFFF8FAFC);

  /// Pure card background.
  static const Color white = Color(0xFFFFFFFF);

  /// Alternate blue section.
  static const Color iceBlue = Color(0xFFEEF5FF);

  /// Soft blue surface.
  static const Color softBlueBackground = Color(0xFFF3F7FD);

  /// Light gold section.
  static const Color goldBackground = Color(0xFFFFFBF0);

  /// Footer background.
  static const Color footer = Color(0xFF04142D);

  // ===========================================================================
  // TEXT
  // ===========================================================================

  /// Main headings.
  static const Color heading = Color(0xFF081B36);

  /// Normal body content.
  static const Color bodyText = Color(0xFF53657D);

  /// Secondary text.
  ///
  /// NOTE: contrast on [background] is ~3.4:1, below WCAG AA's 4.5:1 minimum
  /// for normal text. Safe to use at 18px+ (large text only needs 3:1), but
  /// avoid pairing with bodySmall/labelSmall (11–12px) in the theme's
  /// TextTheme if this needs to pass an accessibility audit — those sizes
  /// currently use this color.
  static const Color mutedText = Color(0xFF7A899C);

  /// White text for dark backgrounds.
  static const Color whiteText = Color(0xFFFFFFFF);

  /// Gold text for premium highlights.
  static const Color goldText = Color(0xFFF5B301);

  // ===========================================================================
  // BORDERS
  // ===========================================================================

  static const Color border = Color(0xFFE1E8F0);

  static const Color divider = Color(0xFFE8EEF5);

  // ===========================================================================
  // STATUS
  // ===========================================================================

  static const Color success = Color(0xFF16805A);

  static const Color error = Color(0xFFD92D20);

  static const Color warning = Color(0xFFE39B00);

  // ===========================================================================
  // SHADOW
  // ===========================================================================

  static const Color shadow = Color(0x18071F49);
}