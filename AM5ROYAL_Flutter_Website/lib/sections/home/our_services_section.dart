import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';

import '../../core/utils/vendor_navigation.dart';

class OurServicesSection extends StatelessWidget {
  const OurServicesSection({
    super.key,
    this.onServiceSelected,
    this.onBookService,
  });

  /// Called whenever the user selects a service.
  final VoidCallback? onServiceSelected;
  final VoidCallback? onBookService;

  static const List<_ServiceItem> services = [
    _ServiceItem('Pet Care', AppAssets.petCare),
    _ServiceItem('AC Repair', AppAssets.acRepair),
    _ServiceItem('Plumbing', AppAssets.plumbing),
    _ServiceItem('Cooking', AppAssets.cooking),
    _ServiceItem('Cleaning', AppAssets.cleaning),
    _ServiceItem('Driver', AppAssets.driver),
    _ServiceItem('Immediate Service', AppAssets.immediate),
    _ServiceItem('Pest Control', AppAssets.pestControl),
    _ServiceItem('Lab Test', AppAssets.labTest),
    _ServiceItem('Painting', AppAssets.painting),
    _ServiceItem('Physiotherapy', AppAssets.physiotherapy),
    _ServiceItem('Waterproofing', AppAssets.waterproofing),
    _ServiceItem('Beauty & Wellness', AppAssets.beautyWellness),
    _ServiceItem(
      'Home & Online Classes',
      AppAssets.homeOnlineClasses,
    ),
    _ServiceItem('Caretaker', AppAssets.caretaker),
    _ServiceItem(
      '2 & 4 Wheeler Services',
      AppAssets.twoFourWheeler,
    ),
    _ServiceItem(
      'Modular Works & Interior',
      AppAssets.modularInterior,
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
        24,
        42,
        24,
        48,
      ),

      child: Column(
        children: [
          const _SectionHeading(),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: VendorNavigation.openVendorLogin,
                icon: const Icon(Icons.person_outline_rounded, size: 18),
                label: const Text('Become a Partner'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0B4EA2),
                  side: const BorderSide(color: Color(0xFF0B4EA2)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: onBookService,
                icon: const Icon(Icons.calendar_month_outlined, size: 18),
                label: const Text('Book a Service'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B4EA2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;

              if (width >= 1100) {
                return _DesktopServices(
                  services: services,
                  onServiceSelected: onServiceSelected,
                );
              }

              if (width >= 650) {
                return _TabletServices(
                  services: services,
                  onServiceSelected: onServiceSelected,
                );
              }

              return _MobileServices(
                services: services,
                onServiceSelected: onServiceSelected,
              );
            },
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// DESKTOP
// =============================================================================

class _DesktopServices extends StatelessWidget {
  const _DesktopServices({
    required this.services,
    required this.onServiceSelected,
  });

  final List<_ServiceItem> services;
  final VoidCallback? onServiceSelected;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 1500,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: services.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 9,
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
          mainAxisExtent: 142,
        ),
        itemBuilder: (context, index) {
          return _ServiceCard(
            item: services[index],
            onTap: onServiceSelected,
          );
        },
      ),
    );
  }
}

// =============================================================================
// TABLET
// =============================================================================

class _TabletServices extends StatelessWidget {
  const _TabletServices({
    required this.services,
    required this.onServiceSelected,
  });

  final List<_ServiceItem> services;
  final VoidCallback? onServiceSelected;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 900,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: services.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          mainAxisExtent: 140,
        ),
        itemBuilder: (context, index) {
          return _ServiceCard(
            item: services[index],
            onTap: onServiceSelected,
          );
        },
      ),
    );
  }
}

// =============================================================================
// MOBILE
// =============================================================================

class _MobileServices extends StatelessWidget {
  const _MobileServices({
    required this.services,
    required this.onServiceSelected,
  });

  final List<_ServiceItem> services;
  final VoidCallback? onServiceSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 132,
      ),
      itemBuilder: (context, index) {
        return _ServiceCard(
          item: services[index],
          onTap: onServiceSelected,
        );
      },
    );
  }
}

// =============================================================================
// SERVICE CARD
// =============================================================================

class _ServiceCard extends StatefulWidget {
  const _ServiceCard({
    required this.item,
    required this.onTap,
  });

  final _ServiceItem item;
  final VoidCallback? onTap;

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool highlighted = _hovered || _pressed;

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
          highlighted ? -3 : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                highlighted ? const Color(0xFF0B4EA2) : const Color(0xFFDCE5EF),
            width: highlighted ? 1.3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x12102A43),
              blurRadius: highlighted ? 15 : 8,
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
                horizontal: 7,
                vertical: 10,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // -----------------------------------------------------------
                  // IMAGE
                  // -----------------------------------------------------------

                  SizedBox(
                    width: 64,
                    height: 64,
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
                          Icons.home_repair_service_rounded,
                          color: Color(0xFF0B4EA2),
                          size: 36,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // -----------------------------------------------------------
                  // SERVICE NAME
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
                          height: 1.22,
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
// SECTION HEADING
// =============================================================================

class _SectionHeading extends StatelessWidget {
  const _SectionHeading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Our Services',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF0B2D5C),
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.15,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: 7),
        SizedBox(
          width: 38,
          height: 3,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFF5B301),
            ),
          ),
        ),
        SizedBox(height: 9),
        Text(
          'Professional services for your home and business needs',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF687B91),
            fontSize: 12.5,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// MODEL
// =============================================================================

class _ServiceItem {
  const _ServiceItem(
    this.name,
    this.image,
  );

  final String name;
  final String image;
}
