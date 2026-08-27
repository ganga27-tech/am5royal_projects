import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class ScrollIndicator extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isUp;

  const ScrollIndicator({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isUp = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
        child: GestureDetector(
            onTap: onTap,
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: Offset(0, isUp ? -4 : 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: (isDark ? const Color(0xFF1E1E1E) : Colors.white)
                            .withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.white.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isUp)
                            Icon(icon, color: AppColors.primary, size: 18),
                          if (isUp) const SizedBox(width: 8),
                          Text(
                            label,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (!isUp) const SizedBox(width: 8),
                          if (!isUp)
                            Icon(icon, color: AppColors.primary, size: 18),
                        ],
                      ),
                    ),
                  ),
                ))));
  }
}
