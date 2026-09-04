import 'package:flutter/material.dart';

import 'am5_colors.dart';
import 'am5_spacing.dart';

abstract final class Am5Decorations {
  static BoxDecoration card(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: color ?? (isDark ? Am5Colors.darkCard : Am5Colors.surface),
      borderRadius: BorderRadius.circular(Am5Spacing.radiusLg),
      boxShadow: isDark
          ? null
          : [
              BoxShadow(
                color: Am5Colors.shadow,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
    );
  }

  static BoxDecoration softRedGradient() => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Am5Colors.lightRed,
            Am5Colors.background,
          ],
        ),
        borderRadius: BorderRadius.circular(Am5Spacing.radiusLg),
      );

  static BoxDecoration brandGradient() => BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Am5Colors.brandRed, Am5Colors.deepRed],
        ),
        borderRadius: BorderRadius.circular(Am5Spacing.radiusLg),
      );
}
