import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/product_model.dart';

class CategoryCard extends StatefulWidget {
  final CategoryItem category;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final signatureColor = widget.category.color;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _isHovered ? -6 : 0, 0),
          decoration: BoxDecoration(
            color: isDark
                ? (_isHovered
                    ? const Color(0xFF1E293B)
                    : const Color(0xFF1E293B).withValues(alpha: 0.9))
                : (_isHovered
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.85)),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? (_isHovered
                      ? signatureColor.withValues(alpha: 0.8)
                      : signatureColor.withValues(alpha: 0.35))
                  : (_isHovered
                      ? signatureColor.withValues(alpha: 0.5)
                      : const Color(0xFFE4E4E7).withValues(alpha: 0.8)),
              width: _isHovered ? 2.0 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? (signatureColor.withValues(
                        alpha: _isHovered ? 0.35 : 0.15))
                    : (signatureColor.withValues(
                        alpha: _isHovered ? 0.15 : 0.02)),
                blurRadius: _isHovered ? 24 : 16,
                offset: _isHovered ? const Offset(0, 10) : const Offset(0, 4),
              ),
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: _isHovered ? 0.5 : 0.35)
                    : const Color(0xFF18181B)
                        .withValues(alpha: _isHovered ? 0.08 : 0.04),
                blurRadius: _isHovered ? 20 : 12,
                offset: _isHovered ? const Offset(0, 8) : const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Interactive ripple layer covering full card
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = constraints.maxWidth;
                    final cardHeight = constraints.maxHeight;
                    final useHorizontal = cardWidth > 260 && cardHeight > 100;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onTap,
                        borderRadius: BorderRadius.circular(24),
                        splashColor: signatureColor.withValues(alpha: 0.12),
                        highlightColor: signatureColor.withValues(alpha: 0.06),
                        child: Padding(
                          padding: useHorizontal
                              ? const EdgeInsets.only(
                                  left: 20,
                                  top: 16,
                                  bottom: 16,
                                  right: 36,
                                )
                              : const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                          child: useHorizontal
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Left: Icon Container with gradient and inner shadow glow
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        gradient: RadialGradient(
                                          colors: isDark
                                              ? [
                                                  signatureColor.withValues(
                                                      alpha: _isHovered
                                                          ? 0.45
                                                          : 0.35),
                                                  signatureColor.withValues(
                                                      alpha: _isHovered
                                                          ? 0.25
                                                          : 0.18),
                                                ]
                                              : [
                                                  signatureColor.withValues(
                                                      alpha: _isHovered
                                                          ? 0.26
                                                          : 0.16),
                                                  signatureColor.withValues(
                                                      alpha: _isHovered
                                                          ? 0.1
                                                          : 0.04),
                                                ],
                                          radius: 0.85,
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: signatureColor.withValues(
                                              alpha: isDark
                                                  ? (_isHovered ? 0.7 : 0.4)
                                                  : (_isHovered ? 0.45 : 0.15)),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: signatureColor.withValues(
                                                alpha: isDark
                                                    ? (_isHovered ? 0.5 : 0.25)
                                                    : (_isHovered
                                                        ? 0.35
                                                        : 0.1)),
                                            blurRadius: _isHovered ? 16 : 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        widget.category.icon,
                                        color: isDark
                                            ? Colors.white
                                            : signatureColor,
                                        size: 44,
                                      ),
                                    ),
                                    const SizedBox(width: 16),

                                    // Middle: Title & Description
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.category.title,
                                            style: GoogleFonts.outfit(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w700,
                                              color: isDark
                                                  ? Colors.white
                                                  : const Color(0xFF0F172A),
                                              height: 1.25,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (widget.category.description
                                              .isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              widget.category.description,
                                              style: GoogleFonts.outfit(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w400,
                                                color: isDark
                                                    ? Colors.white
                                                        .withValues(alpha: 0.75)
                                                    : const Color(0xFF71717A),
                                                height: 1.3,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Icon Container
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        gradient: RadialGradient(
                                          colors: isDark
                                              ? [
                                                  signatureColor.withValues(
                                                      alpha: _isHovered
                                                          ? 0.45
                                                          : 0.35),
                                                  signatureColor.withValues(
                                                      alpha: _isHovered
                                                          ? 0.25
                                                          : 0.18),
                                                ]
                                              : [
                                                  signatureColor.withValues(
                                                      alpha: _isHovered
                                                          ? 0.26
                                                          : 0.16),
                                                  signatureColor.withValues(
                                                      alpha: _isHovered
                                                          ? 0.1
                                                          : 0.04),
                                                ],
                                          radius: 0.85,
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: signatureColor.withValues(
                                              alpha: isDark
                                                  ? (_isHovered ? 0.7 : 0.4)
                                                  : (_isHovered ? 0.45 : 0.15)),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: signatureColor.withValues(
                                                alpha: isDark
                                                    ? (_isHovered ? 0.5 : 0.25)
                                                    : (_isHovered
                                                        ? 0.35
                                                        : 0.1)),
                                            blurRadius: _isHovered ? 16 : 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        widget.category.icon,
                                        color: isDark
                                            ? Colors.white
                                            : signatureColor,
                                        size: 44,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Category Title Text
                                    Text(
                                      widget.category.title,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.outfit(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                        height: 1.25,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
