import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/responsive/responsive.dart';

/// Reusable section heading used throughout the AM5ROYAL website.
///
/// Provides a consistent:
/// - eyebrow label
/// - section title
/// - description
/// - responsive typography
/// - premium AM5ROYAL visual styling
class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.eyebrow,
    this.description,
    this.textAlign = TextAlign.center,
    this.maxWidth = 720,
  });

  final String title;
  final String? eyebrow;
  final String? description;
  final TextAlign textAlign;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    final double titleSize = isMobile ? 28 : 36;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (eyebrow != null && eyebrow!.trim().isNotEmpty) ...[
              Text(
                eyebrow!.trim().toUpperCase(),
                textAlign: textAlign,
                style: const TextStyle(
                  color: AppColors.royalBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
            ],

            Text(
              title,
              textAlign: textAlign,
              style: TextStyle(
                color: AppColors.heading,
                fontSize: titleSize,
                fontWeight: FontWeight.w800,
                height: 1.2,
                letterSpacing: -0.4,
              ),
            ),

            const SizedBox(height: 12),

            // Premium gold accent line.
            Container(
              width: 52,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.accentGold,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            if (description != null &&
                description!.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                description!.trim(),
                textAlign: textAlign,
                style: TextStyle(
                  color: AppColors.bodyText,
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


