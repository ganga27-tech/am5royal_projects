import 'package:flutter/material.dart';

/// LIVORA color tokens — white-first, deep teal primary, soft gold accent.
abstract final class LivoraColors {
  static const Color primary = Color(0xFF0B3D3A);
  static const Color primaryContainer = Color(0xFF1A5C57);
  static const Color onPrimary = Color(0xFFFBFBFA);
  static const Color accent = Color(0xFFC4A35A);
  static const Color accentMuted = Color(0xFFE8D9B5);
  static const Color surface = Color(0xFFFBFBFA);
  static const Color surfaceDim = Color(0xFFF3F2EE);
  static const Color surfaceContainer = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1A1C1B);
  static const Color onSurfaceVariant = Color(0xFF5C635F);
  static const Color outline = Color(0xFFD7DBD8);
  static const Color outlineVariant = Color(0xFFE8EBE9);
  static const Color error = Color(0xFFB42318);
  static const Color success = Color(0xFF1B7A4E);
  static const Color warning = Color(0xFFB54708);

  // Dark
  static const Color darkSurface = Color(0xFF121514);
  static const Color darkSurfaceContainer = Color(0xFF1C211F);
  static const Color darkMuted = Color(0xFF161A19);
  static const Color darkOnSurface = Color(0xFFF2F4F3);
  static const Color darkPrimary = Color(0xFF7BC4BE);
  static const Color darkAccent = Color(0xFFD4B978);

  /// Soft page wash behind cards (beige in light, charcoal in dark).
  static Color canvasOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : surfaceDim;
  }

  /// Elevated cards / panels.
  static Color cardOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurfaceContainer
        : surfaceContainer;
  }

  /// Inset fills (meta boxes, inputs) on top of cards.
  static Color mutedOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkMuted
        : surfaceDim;
  }
}
