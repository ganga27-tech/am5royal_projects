import 'package:flutter/material.dart';

/// AM5 Royal brand color palette - based on the provided blue watercolor design
abstract class AppColors {
  static const Color primaryf = Color(0xFF0C3D98); // deep royal blue
  static const Color primaryLightf = Color(0xFF2E8BF0); // bright sky blue
  static const Color backgroundf = Colors.white;

  static const Color textPrimaryf = Color(0xFF16315D);
  static const Color textSecondaryf = Color(0xFF6C84A5);

  static const Color borderf = Color(0xFFD8E6F5);

  // --- Brand Colors ---
  static const Color primary = Color(0xFF0C3D98); // royal blue
  static const Color primaryLight = Color(0xFF2E8BF0);
  static const Color primaryDark = Color(0xFF082C6A);
  static const Color primaryContainer = Color(0xFFE0F1FF);

  // Gold accent from the crown
  static const Color accent = Color(0xFFD4A33A);
  static const Color accentLight = Color(0xFFF2D06B);
  static const Color accentDark = Color(0xFFA87412);
  static const Color accentContainer = Color(0xFFFFF5DA);

  // --- Neutral ---
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF7FBFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEEF6FD);

  // --- Text ---
  static const Color textPrimary = Color(0xFF16315D);
  static const Color textSecondary = Color(0xFF6C84A5);
  static const Color textHint = Color(0xFF94A8C5);
  static const Color textDisabled = Color(0xFFD5E1F0);

  // --- Border ---
  static const Color border = Color(0xFFD8E6F5);
  static const Color borderFocus = Color(0xFF2B7DE1);

  // --- Semantic ---
  static const Color success = Color(0xFF10B981);
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoContainer = Color(0xFFDBEAFE);

  // --- Dark Theme ---
  static const Color darkBackground = Color(0xFF0B1220);
  static const Color darkSurface = Color(0xFF111B2F);
  static const Color darkSurfaceVariant = Color(0xFF1A2640);
  static const Color darkTextPrimary = Color(0xFFF5F9FF);
  static const Color darkTextSecondary = Color(0xFFA9B8D3);
  static const Color darkBorder = Color(0xFF2B3B5A);

  // --- Booking Status Colors ---
  static const Color statusPending = Color(0xFFD4A33A);
  static const Color statusPendingBg = Color(0xFFFFF6DB);
  static const Color statusConfirmed = Color(0xFF2B7DE1);
  static const Color statusConfirmedBg = Color(0xFFEAF4FF);
  static const Color statusInProgress = Color(0xFF6A8FE8);
  static const Color statusInProgressBg = Color(0xFFE8EEFF);
  static const Color statusCompleted = Color(0xFF10B981);
  static const Color statusCompletedBg = Color(0xFFD1FAE5);
  static const Color statusCancelled = Color(0xFFEF4444);
  static const Color statusCancelledBg = Color(0xFFFEE2E2);

  // --- Premium Gradients ---
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentLight, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [darkSurface, darkBackground],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}