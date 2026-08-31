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
          // ===================================================================
          // SECTION TITLE
          // ===================================================================

          const Text(
            'Upcoming Services',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF0B2D5C),
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),

          const SizedBox(height: 7),

          Container(
            width: 38,
            height: 3,
            decoration: BoxDecoration(
              color: const Color(0xFFF5B301),
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          const SizedBox(height: 9),

          const Text(
            'New services coming soon to AM5ROYAL',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF687B91),
              fontSize: 12.5,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 28),

          // ===================================================================
          // RESPONSIVE SERVICES
          // ===================================================================

          LayoutBuilder(
            builder: (
              BuildContext context,
              BoxConstraints constraints,
            ) {
              final double width = constraints.maxWidth;

              // ===============================================================
              // DESKTOP
              // 8 CARDS IN ONE ROW
              // ===============================================================

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
                            height: 150,
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

              // ===============================================================
              // TABLET
              // HORIZONTAL SCROLL
              // ===============================================================

              if (width >= 650) {
                return SizedBox(
                  height: 150,
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

              // ===============================================================
              // MOBILE
              // HORIZONTAL SCROLL
              // ===============================================================

              return SizedBox(
                height: 145,
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
  // CARD CLICK
  //
  // IMPORTANT:
  // Upcoming services are NOT bookable yet.
  //
  // Clicking the card:
  //   1. Does NOT navigate
  //   2. Does NOT open booking
  //   3. Does NOT call onServiceSelected
  //   4. Only shows "Launching Soon"
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
          milliseconds: 180,
        ),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(
          0,
          active ? -3 : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? const Color(0xFF0B4EA2) : const Color(0xFFDCE5EF),
            width: active ? 1.3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x12102A43),
              blurRadius: active ? 15 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _handleCardTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                8,
                10,
                8,
                8,
              ),

              // =================================================================
              // IMPORTANT:
              //
              // NO Stack
              // NO Positioned
              //
              // Everything is arranged vertically.
              // Therefore "Launching Soon" can never cover the service name.
              // =================================================================

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // =============================================================
                  // SERVICE IMAGE
                  // =============================================================

                  SizedBox(
                    width: 72,
                    height: 72,
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
                        return const Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFF0B4EA2),
                          size: 36,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 6),

                  // =============================================================
                  // SERVICE NAME
                  //
                  // Expanded gives the service name its own area.
                  // The badge below is completely separate.
                  // =============================================================

                  Expanded(
                    child: Center(
                      child: Text(
                        widget.item.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF102A43),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),

                  // =============================================================
                  // LAUNCHING SOON
                  //
                  // This is BELOW the service name.
                  // It is NOT positioned over the name.
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
                                  color: const Color(0xFF0B4EA2),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x250B4EA2),
                                      blurRadius: 7,
                                      offset: Offset(0, 3),
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
                                      const SizedBox(width: 5),
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
