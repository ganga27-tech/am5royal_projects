import 'package:flutter/material.dart';

enum LivoraButtonVariant { primary, secondary, ghost }

class LivoraButton extends StatelessWidget {
  const LivoraButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.variant = LivoraButtonVariant.primary,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final LivoraButtonVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    switch (variant) {
      case LivoraButtonVariant.primary:
        return FilledButton(onPressed: loading ? null : onPressed, child: child);
      case LivoraButtonVariant.secondary:
        return OutlinedButton(onPressed: loading ? null : onPressed, child: child);
      case LivoraButtonVariant.ghost:
        return TextButton(onPressed: loading ? null : onPressed, child: child);
    }
  }
}
