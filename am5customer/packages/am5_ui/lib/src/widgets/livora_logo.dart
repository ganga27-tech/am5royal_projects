import 'package:flutter/material.dart';

import '../theme/livora_colors.dart';
import '../theme/livora_spacing.dart';

class LivoraLogo extends StatelessWidget {
  const LivoraLogo({
    super.key,
    this.size = 40,
    this.showWordmark = true,
  });

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final markColor = isDark ? LivoraColors.darkPrimary : LivoraColors.primary;
    final textColor = isDark ? LivoraColors.darkOnSurface : LivoraColors.onSurface;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: markColor,
            borderRadius: BorderRadius.circular(LivoraSpacing.radii.md),
          ),
          alignment: Alignment.center,
          child: Text(
            'L',
            style: TextStyle(
              color: isDark ? LivoraColors.darkSurface : LivoraColors.onPrimary,
              fontWeight: FontWeight.w700,
              fontSize: size * 0.48,
              height: 1,
            ),
          ),
        ),
        if (showWordmark) ...[
          SizedBox(width: size * 0.28),
          Text(
            'LIVORA',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: textColor,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ],
    );
  }
}
