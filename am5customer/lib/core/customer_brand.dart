import 'package:flutter/material.dart';

import 'design_system/am5_colors.dart';
import 'design_system/am5_spacing.dart';

/// Customer app brand helpers — always use theme red, not Livora teal tokens.
abstract final class CustomerBrand {
  static Color primary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  static Color onPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onPrimary;

  static Color pageBackground(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  static BoxDecoration heroCard(BuildContext context) {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Am5Colors.brandRed, Am5Colors.deepRed],
      ),
      borderRadius: BorderRadius.circular(Am5Spacing.radiusXl),
      boxShadow: [
        BoxShadow(
          color: Am5Colors.brandRed.withValues(alpha: 0.22),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  static Color iconTileBg(BuildContext context) =>
      primary(context).withValues(alpha: 0.1);

  static Color badgeBg(BuildContext context) =>
      Am5Colors.lightRed;

  static Color badgeFg(BuildContext context) => Am5Colors.deepRed;
}
