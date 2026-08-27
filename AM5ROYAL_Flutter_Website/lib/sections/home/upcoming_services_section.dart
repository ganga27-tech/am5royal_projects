import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';

class UpcomingServicesSection extends StatelessWidget {
  const UpcomingServicesSection({
    super.key,
    this.onServiceSelected,
  });

  /// Called when an upcoming service card is selected.
  final VoidCallback? onServiceSelected;

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
      'Healthcare & Medical',
      AppAssets.healthcareMedical,
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
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      // -----------------------------------------------------------------------
      // AM5ROYAL WEBSITE BACKGROUND
      // -----------------------------------------------------------------------

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
        40,
      ),

      child: Column(
        children: [
          // -------------------------------------------------------------------
          // HEADING
          // -------------------------------------------------------------------

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

          const SizedBox(height: 25),

          // -------------------------------------------------------------------
          // CARDS
          // -------------------------------------------------------------------

          SizedBox(
            height: 145,
            child: LayoutBuilder(
              builder: (
                context,
                constraints,
              ) {
                final bool desktop = constraints.maxWidth >= 1100;

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: desktop
                      ? const NeverScrollableScrollPhysics()
                      : const BouncingScrollPhysics(),
                  itemCount: services.length,
                  separatorBuilder: (_, __) => const SizedBox(
                    width: 14,
                  ),
                  itemBuilder: (context, index) {
                    final double cardWidth =
                        desktop ? (constraints.maxWidth - 84) / 7 : 145;

                    return SizedBox(
                      width: cardWidth,
                      child: _UpcomingCard(
                        item: services[index],
                        onTap: onServiceSelected,
                      ),
                    );
                  },
                );
              },
            ),
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
    required this.onTap,
  });

  final _UpcomingItem item;
  final VoidCallback? onTap;

  @override
  State<_UpcomingCard> createState() => _UpcomingCardState();
}

class _UpcomingCardState extends State<_UpcomingCard> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool active = _hovered || _pressed;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovered = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
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
            onTap: () {
              setState(() {
                _pressed = true;
              });

              // Tell HomePage that a service was selected.
              widget.onTap?.call();

              Future.delayed(
                const Duration(
                  milliseconds: 180,
                ),
                () {
                  if (mounted) {
                    setState(() {
                      _pressed = false;
                    });
                  }
                },
              );
            },
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 10,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // -----------------------------------------------------------
                  // IMAGE
                  // -----------------------------------------------------------

                  SizedBox(
                    width: 68,
                    height: 68,
                    child: Image.asset(
                      widget.item.image,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return const Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFF0B4EA2),
                          size: 36,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // -----------------------------------------------------------
                  // TITLE
                  // -----------------------------------------------------------

                  SizedBox(
                    height: 34,
                    child: Center(
                      child: Text(
                        widget.item.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF102A43),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
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
