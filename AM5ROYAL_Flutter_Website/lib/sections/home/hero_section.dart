import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_assets.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    this.highlightCta = false,
    this.onBookServicePressed,
    this.onPartnerPressed,
  });

  final bool highlightCta;
  final VoidCallback? onBookServicePressed;
  final VoidCallback? onPartnerPressed;

  static const String _partnerPlayStoreUrl =
      'https://play.google.com/store/apps/details?id=com.am5royal.am5royal';

  Future<void> _openPartnerApp() async {
    if (onPartnerPressed != null) {
      onPartnerPressed!();
      return;
    }
    final Uri uri = Uri.parse(_partnerPlayStoreUrl);

    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      // Prevent the website from crashing if the external link cannot open.
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final bool isDesktop = width >= 900;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF082B5C),
            Color(0xFF0B4EA2),
          ],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1450,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              isDesktop ? 42 : 22,
              isDesktop ? 28 : 32,
              isDesktop ? 42 : 22,
              0,
            ),
            child: isDesktop
                ? _DesktopHero(
                    onPartnerPressed: _openPartnerApp,
                    onBookServicePressed: onBookServicePressed,
                    highlightCta: highlightCta,
                  )
                : _MobileHero(
                    onPartnerPressed: _openPartnerApp,
                    onBookServicePressed: onBookServicePressed,
                    highlightCta: highlightCta,
                  ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// DESKTOP HERO
// =============================================================================

class _DesktopHero extends StatelessWidget {
  const _DesktopHero({
    required this.onPartnerPressed,
    required this.onBookServicePressed,
    required this.highlightCta,
  });

  final VoidCallback onPartnerPressed;
  final VoidCallback? onBookServicePressed;
  final bool highlightCta;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Slightly increased hero height
      height: 425,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ===================================================================
          // LEFT CONTENT
          // ===================================================================

          Expanded(
            flex: 53,
            child: Padding(
              padding: const EdgeInsets.only(
                right: 35,
                bottom: 30,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'India’s Trusted',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      height: 1.04,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const Text(
                    'Home & Business',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      height: 1.04,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const Text(
                    'Service Platform',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      height: 1.04,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Find verified professionals for all your\n'
                    'home and business needs.',
                    style: TextStyle(
                      color: Color(0xE6FFFFFF),
                      fontSize: 15.5,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 23),
                  Row(
                    children: [
                      // =======================================================
                      // BECOME A PARTNER
                      // =======================================================

                      _CtaHighlight(
                        enabled: highlightCta,
                        child: ElevatedButton.icon(
                          onPressed: onPartnerPressed,
                          icon: const Icon(
                            Icons.person_outline_rounded,
                            size: 19,
                          ),
                          label: const Text(
                            'Become a Partner',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF5B301),
                            foregroundColor: const Color(0xFF10233D),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      // =======================================================
                      // BOOK A SERVICE
                      // =======================================================

                      _CtaHighlight(
                        enabled: highlightCta,
                        child: OutlinedButton.icon(
                          onPressed: onBookServicePressed ?? onPartnerPressed,
                          icon: const Icon(
                            Icons.calendar_month_outlined,
                            size: 19,
                          ),
                          label: const Text(
                            'Book a Service',
                          ),
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              Colors.transparent,
                            ),
                            foregroundColor: WidgetStateProperty.all(
                              Colors.white,
                            ),
                            overlayColor: WidgetStateProperty.all(
                              const Color(0x18FFFFFF),
                            ),
                            side: WidgetStateProperty.all(
                              const BorderSide(
                                color: Colors.white,
                                width: 1.2,
                              ),
                            ),
                            padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                            ),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9),
                              ),
                            ),
                            textStyle: WidgetStateProperty.all(
                              const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ===================================================================
          // RIGHT HERO IMAGE
          // ===================================================================

          Expanded(
            flex: 47,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 425,
                width: double.infinity,
                child: Image.asset(
                  AppAssets.heroBoy,
                  height: 425,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                  errorBuilder: (
                    BuildContext context,
                    Object error,
                    StackTrace? stackTrace,
                  ) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// MOBILE HERO
// =============================================================================

class _MobileHero extends StatelessWidget {
  const _MobileHero({
    required this.onPartnerPressed,
    required this.onBookServicePressed,
    required this.highlightCta,
  });

  final VoidCallback onPartnerPressed;
  final VoidCallback? onBookServicePressed;
  final bool highlightCta;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'India’s Trusted',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 31,
            fontWeight: FontWeight.w900,
            height: 1.08,
          ),
        ),
        const Text(
          'Home & Business',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 31,
            fontWeight: FontWeight.w900,
            height: 1.08,
          ),
        ),
        const Text(
          'Service Platform',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 31,
            fontWeight: FontWeight.w900,
            height: 1.08,
          ),
        ),

        const SizedBox(height: 13),

        const Text(
          'Find verified professionals for all your\n'
          'home and business needs.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xE6FFFFFF),
            fontSize: 14,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 20),

        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            _CtaHighlight(
              enabled: highlightCta,
              child: ElevatedButton.icon(
                onPressed: onPartnerPressed,
                icon: const Icon(
                  Icons.person_outline_rounded,
                  size: 17,
                ),
                label: const Text(
                  'Become a Partner',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5B301),
                  foregroundColor: const Color(0xFF10233D),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            _CtaHighlight(
              enabled: highlightCta,
              child: OutlinedButton.icon(
                onPressed: onBookServicePressed ?? onPartnerPressed,
                icon: const Icon(
                  Icons.calendar_month_outlined,
                  size: 17,
                ),
                label: const Text(
                  'Book a Service',
                ),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    Colors.transparent,
                  ),
                  foregroundColor: WidgetStateProperty.all(
                    Colors.white,
                  ),
                  side: WidgetStateProperty.all(
                    const BorderSide(
                      color: Colors.white,
                      width: 1.2,
                    ),
                  ),
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        // =====================================================================
        // MOBILE IMAGE
        // =====================================================================

        SizedBox(
          height: 330,
          width: double.infinity,
          child: Image.asset(
            AppAssets.heroBoy,
            fit: BoxFit.contain,
            alignment: Alignment.bottomCenter,
            errorBuilder: (
              BuildContext context,
              Object error,
              StackTrace? stackTrace,
            ) {
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// CTA HIGHLIGHT / BLINK
// =============================================================================

class _CtaHighlight extends StatefulWidget {
  const _CtaHighlight({
    required this.enabled,
    required this.child,
  });

  final bool enabled;
  final Widget child;

  @override
  State<_CtaHighlight> createState() => _CtaHighlightState();
}

class _CtaHighlightState extends State<_CtaHighlight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(
    covariant _CtaHighlight oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (widget.enabled && !oldWidget.enabled) {
      _controller.repeat(reverse: true);
    } else if (!widget.enabled && oldWidget.enabled) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double scale =
            widget.enabled ? 1.0 + (_controller.value * 0.04) : 1.0;

        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
