import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';

class UpcomingServicesSection extends StatelessWidget {
  const UpcomingServicesSection({
    super.key,
    this.onServiceSelected,
  });

  final VoidCallback? onServiceSelected;

  // ===========================================================================
  // UPCOMING SERVICES - EXACTLY 8
  // ===========================================================================
  //
  // BACKEND / DATA UNCHANGED
  //
  // ===========================================================================

  static const List<_UpcomingItem> services = [
    _UpcomingItem(
      'Packers & Movers',
      AppAssets.packersMovers,
    ),
    _UpcomingItem(
      'Event Management',
      AppAssets.eventManagement,
    ),
    _UpcomingItem(
      'Wholesale Distribution',
      AppAssets.wholesaleDistribution,
    ),
    _UpcomingItem(
      'Travel & Tourism',
      AppAssets.travelTourism,
    ),
    _UpcomingItem(
      'Food & Beverage',
      AppAssets.foodBeverage,
    ),
    _UpcomingItem(
      'Healthcare & Hospital',
      AppAssets.healthcareHospital,
    ),
    _UpcomingItem(
      'Training & Education',
      AppAssets.trainingEducation,
    ),
    _UpcomingItem(
      'Food, Agriculture & Farming',
      AppAssets.foodAgricultureFarming,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      // =========================================================================
      // SECTION BACKGROUND
      // =========================================================================

      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF9EBD1),
            Color(0xFFFCEFDD),
          ],
        ),
      ),

      padding: const EdgeInsets.fromLTRB(
        20,
        34,
        20,
        42,
      ),

      child: Column(
        children: [
          // =====================================================================
          // SECTION TITLE
          // =====================================================================

          const Text(
            'Upcoming Services',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF0B2D5C),
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 7),

          // =====================================================================
          // GOLD LINE
          // =====================================================================

          Container(
            width: 38,
            height: 3,
            decoration: BoxDecoration(
              color: const Color(0xFFF5B301),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x45F5B301),
                  blurRadius: 7,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),

          const SizedBox(height: 9),

          // =====================================================================
          // SUBTITLE
          // =====================================================================

          const Text(
            'New services coming soon to AM5ROYAL',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF687B91),
              fontSize: 12.5,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 28),

          // =====================================================================
          // RESPONSIVE SERVICES
          // =====================================================================

          LayoutBuilder(
            builder: (
              BuildContext context,
              BoxConstraints constraints,
            ) {
              final double width = constraints.maxWidth;

              // =================================================================
              // DESKTOP
              // 8 CARDS IN ONE ROW
              // =================================================================

              if (width >= 1100) {
                return ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1550,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int index = 0; index < services.length; index++) ...[
                        if (index > 0) const SizedBox(width: 14),
                        Expanded(
                          child: SizedBox(
                            height: 225,
                            child: _UpcomingCard(
                              item: services[index],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }

              // =================================================================
              // TABLET
              // HORIZONTAL SCROLL
              // =================================================================

              if (width >= 650) {
                return SizedBox(
                  height: 210,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: services.length,
                    separatorBuilder: (
                      BuildContext context,
                      int index,
                    ) {
                      return const SizedBox(width: 14);
                    },
                    itemBuilder: (
                      BuildContext context,
                      int index,
                    ) {
                      return SizedBox(
                        width: 180,
                        child: _UpcomingCard(
                          item: services[index],
                        ),
                      );
                    },
                  ),
                );
              }

              // =================================================================
              // MOBILE
              // HORIZONTAL SCROLL
              // =================================================================

              return SizedBox(
                height: 195,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: services.length,
                  separatorBuilder: (
                    BuildContext context,
                    int index,
                  ) {
                    return const SizedBox(width: 14);
                  },
                  itemBuilder: (
                    BuildContext context,
                    int index,
                  ) {
                    return SizedBox(
                      width: 155,
                      child: _UpcomingCard(
                        item: services[index],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// UPCOMING SERVICE CARD
// =============================================================================

class _UpcomingCard extends StatefulWidget {
  const _UpcomingCard({
    required this.item,
  });

  final _UpcomingItem item;

  @override
  State<_UpcomingCard> createState() => _UpcomingCardState();
}

class _UpcomingCardState extends State<_UpcomingCard> {
  bool _hovered = false;
  bool _launchingSoon = false;

  // ===========================================================================
  // PASTEL BACKGROUNDS
  // ===========================================================================

  static const List<Color> _backgrounds = [
    Color(0xFFFFF1EE),
    Color(0xFFF5EEFF),
    Color(0xFFEAF4FF),
    Color(0xFFEAFBF4),
    Color(0xFFFFF8E5),
    Color(0xFFEDF5FF),
    Color(0xFFF4EEFF),
    Color(0xFFEAFBF5),
  ];

  // ===========================================================================
  // ACCENT COLORS
  // ===========================================================================

  static const List<Color> _accents = [
    Color(0xFFFF7564),
    Color(0xFF9658D9),
    Color(0xFF2688E8),
    Color(0xFF16AE7C),
    Color(0xFFD99B00),
    Color(0xFF357DD1),
    Color(0xFF7850D1),
    Color(0xFF13A473),
  ];

  Color get _backgroundColor {
    final int index = _getServiceIndex();

    return _backgrounds[index % _backgrounds.length];
  }

  Color get _accentColor {
    final int index = _getServiceIndex();

    return _accents[index % _accents.length];
  }

  int _getServiceIndex() {
    final String name = widget.item.name;

    if (name == 'Packers & Movers') {
      return 0;
    }

    if (name == 'Event Management') {
      return 1;
    }

    if (name == 'Wholesale Distribution') {
      return 2;
    }

    if (name == 'Travel & Tourism') {
      return 3;
    }

    if (name == 'Food & Beverage') {
      return 4;
    }

    if (name == 'Healthcare & Hospital') {
      return 5;
    }

    if (name == 'Training & Education') {
      return 6;
    }

    return 7;
  }

  // ===========================================================================
  // CARD CLICK
  //
  // Upcoming services are NOT bookable yet.
  //
  // Backend/navigation untouched.
  // Only Launching Soon is shown.
  // ===========================================================================

  void _handleCardTap() {
    if (!mounted) {
      return;
    }

    setState(() {
      _launchingSoon = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool active = _hovered || _launchingSoon;

    return MouseRegion(
      cursor: SystemMouseCursors.click,

      // =======================================================================
      // HOVER ON
      // =======================================================================

      onEnter: (_) {
        if (!mounted) {
          return;
        }

        setState(() {
          _hovered = true;
        });
      },

      // =======================================================================
      // HOVER OFF
      // =======================================================================

      onExit: (_) {
        if (!mounted) {
          return;
        }

        setState(() {
          _hovered = false;
        });
      },

      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 240,
        ),

        curve: Curves.easeOutCubic,

        // =====================================================================
        // HOVER LIFT
        // =====================================================================

        transform: Matrix4.translationValues(
          0,
          active ? -6 : 0,
          0,
        ),

        // =====================================================================
        // CARD DECORATION
        // =====================================================================

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active
                ? _accentColor.withOpacity(0.48)
                : const Color(0xFFF1F3F6),
            width: active ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: active
                  ? _accentColor.withOpacity(0.20)
                  : const Color(0x180B1F3A),
              blurRadius: active ? 26 : 15,
              spreadRadius: active ? 1 : 0,
              offset: Offset(
                0,
                active ? 12 : 7,
              ),
            ),
          ],
        ),

        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),

            splashColor: _accentColor.withOpacity(0.08),

            highlightColor: _accentColor.withOpacity(0.04),

            // =================================================================
            // CARD TAP
            // =================================================================

            onTap: _handleCardTap,

            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  // =============================================================
                  // IMAGE CONTAINER
                  // =============================================================

                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 240,
                      ),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _backgroundColor,
                            _backgroundColor.withOpacity(
                              0.62,
                            ),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          17,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // ===================================================
                          // DECORATIVE CIRCLE
                          // ===================================================

                          Positioned(
                            top: -18,
                            right: -18,
                            child: AnimatedContainer(
                              duration: const Duration(
                                milliseconds: 240,
                              ),
                              width: active ? 72 : 62,
                              height: active ? 72 : 62,
                              decoration: BoxDecoration(
                                color: _accentColor.withOpacity(
                                  active ? 0.13 : 0.08,
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),

                          // ===================================================
                          // ACCENT DOT
                          // ===================================================

                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _accentColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _accentColor.withOpacity(
                                      0.35,
                                    ),
                                    blurRadius: 7,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ===================================================
                          // SERVICE IMAGE
                          // ===================================================

                          Center(
                            child: AnimatedScale(
                              scale: active ? 1.07 : 1.0,
                              duration: const Duration(
                                milliseconds: 240,
                              ),
                              curve: Curves.easeOutCubic,
                              child: Padding(
                                padding: const EdgeInsets.all(
                                  10,
                                ),
                                child: Image.asset(
                                  widget.item.image,
                                  fit: BoxFit.contain,
                                  alignment: Alignment.center,
                                  filterQuality: FilterQuality.high,
                                  errorBuilder: (
                                    BuildContext context,
                                    Object error,
                                    StackTrace? stackTrace,
                                  ) {
                                    return Icon(
                                      Icons.auto_awesome_rounded,
                                      color: _accentColor,
                                      size: 52,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // =============================================================
                  // SERVICE NAME + ARROW
                  // =============================================================

                  SizedBox(
                    height: 42,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // =======================================================
                        // SERVICE NAME
                        // =======================================================

                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 2,
                              right: 4,
                            ),
                            child: Text(
                              widget.item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                color: Color(
                                  0xFF102A43,
                                ),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                height: 1.18,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 6,
                        ),

                        // =======================================================
                        // ARROW BUTTON
                        // =======================================================

                        AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 220,
                          ),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: active
                                ? _accentColor
                                : _accentColor.withOpacity(
                                    0.12,
                                  ),
                            shape: BoxShape.circle,
                            boxShadow: active
                                ? [
                                    BoxShadow(
                                      color: _accentColor.withOpacity(
                                        0.25,
                                      ),
                                      blurRadius: 9,
                                      offset: const Offset(
                                        0,
                                        4,
                                      ),
                                    ),
                                  ]
                                : null,
                          ),
                          child: AnimatedRotation(
                            turns: active ? 0.04 : 0,
                            duration: const Duration(
                              milliseconds: 220,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: active ? Colors.white : _accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // =============================================================
                  // LAUNCHING SOON
                  //
                  // It appears BELOW the card content area.
                  // It never overlays the service name.
                  // =============================================================

                  AnimatedSwitcher(
                    duration: const Duration(
                      milliseconds: 220,
                    ),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                    ) {
                      return FadeTransition(
                        opacity: animation,
                        child: SizeTransition(
                          sizeFactor: animation,
                          axisAlignment: -1,
                          child: child,
                        ),
                      );
                    },
                    child: _launchingSoon
                        ? Padding(
                            key: const ValueKey<String>(
                              'launching-soon',
                            ),
                            padding: const EdgeInsets.only(
                              top: 5,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: _accentColor,
                                  borderRadius: BorderRadius.circular(
                                    20,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _accentColor.withOpacity(
                                        0.22,
                                      ),
                                      blurRadius: 7,
                                      offset: const Offset(
                                        0,
                                        3,
                                      ),
                                    ),
                                  ],
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.schedule_rounded,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      const Text(
                                        'Launching Soon',
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(
                            key: ValueKey<String>(
                              'no-launching-soon',
                            ),
                            height: 0,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// MODEL
// =============================================================================

class _UpcomingItem {
  const _UpcomingItem(
    this.name,
    this.image,
  );

  final String name;
  final String image;
}
