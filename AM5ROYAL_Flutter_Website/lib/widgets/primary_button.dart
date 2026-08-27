import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expand = false,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _isHovering = false;

  bool get _enabled => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final button = MouseRegion(
      cursor: _enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) {
        if (_enabled) {
          setState(() => _isHovering = true);
        }
      },
      onExit: (_) {
        if (_enabled) {
          setState(() => _isHovering = false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: _enabled && _isHovering
              ? [
            BoxShadow(
              color: AppColors.accentGold.withValues(
                alpha: 0.28,
              ),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isHovering
                ? const Color(0xFFFFCA3A)
                : AppColors.accentGold,
            foregroundColor: AppColors.heading,
            disabledBackgroundColor:
            AppColors.accentGold.withValues(alpha: 0.45),
            disabledForegroundColor:
            AppColors.heading.withValues(alpha: 0.55),
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (widget.icon != null) ...[
                const SizedBox(width: 9),
                Icon(
                  widget.icon,
                  size: 18,
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (widget.expand) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}