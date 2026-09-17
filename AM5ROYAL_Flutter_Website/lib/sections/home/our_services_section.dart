import 'package:flutter/material.dart';

import '../../core/config/booking_config.dart';
import '../../core/utils/vendor_navigation.dart';
import '../../features/booking/data/catalog_api.dart';
import '../../features/booking/models/booking_models.dart';
import '../../widgets/service_image.dart';

class OurServicesSection extends StatefulWidget {
  const OurServicesSection({
    super.key,
    this.onSubcategorySelected,
    this.onBookService,
  });

  final ValueChanged<ServiceSubcategory>? onSubcategorySelected;
  final VoidCallback? onBookService;

  @override
  State<OurServicesSection> createState() => _OurServicesSectionState();
}

class _OurServicesSectionState extends State<OurServicesSection> {
  final CatalogApi _catalogApi = CatalogApi();

  List<ServiceSubcategory> _subcategories = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSubcategories();
  }

  Future<void> _loadSubcategories() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final items = await _catalogApi.getSubcategories(
        categoryId: BookingConfig.homeServicesCategoryId,
      );

      items.sort(
        (a, b) => a.name.compareTo(b.name),
      );

      if (!mounted) return;

      setState(() {
        _subcategories = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF9EBD1),
            Color(0xFFFCEFDD),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        24,
        58,
        24,
        65,
      ),
      child: Column(
        children: [
          const _SectionHeading(),

          const SizedBox(height: 26),

          // ===============================================================
          // ACTION BUTTONS
          // ===============================================================

          Wrap(
            alignment: WrapAlignment.center,
            spacing: 14,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: VendorNavigation.openVendorLogin,
                icon: const Icon(
                  Icons.person_outline_rounded,
                  size: 19,
                ),
                label: const Text(
                  'Become a Partner',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0B4EA2),
                  backgroundColor: Colors.white.withOpacity(0.72),
                  side: const BorderSide(
                    color: Color(0xFF0B4EA2),
                    width: 1.2,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 21,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: widget.onBookService,
                icon: const Icon(
                  Icons.calendar_month_outlined,
                  size: 19,
                ),
                label: const Text(
                  'Book a Service',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B4EA2),
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shadowColor: const Color(0x450B4EA2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 23,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 38),

          // ===============================================================
          // LOADING
          // ===============================================================

          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: CircularProgressIndicator(
                color: Color(0xFF0B4EA2),
                strokeWidth: 3,
              ),
            )

          // ===============================================================
          // ERROR
          // ===============================================================

          else if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      color: Colors.red.shade600,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Could not load services.',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton(
                    onPressed: _loadSubcategories,
                    child: const Text(
                      'Retry',
                    ),
                  ),
                ],
              ),
            )

          // ===============================================================
          // EMPTY
          // ===============================================================

          else if (_subcategories.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Text(
                'No services available right now.',
                style: TextStyle(
                  color: Color(0xFF687B91),
                  fontSize: 14,
                ),
              ),
            )

          // ===============================================================
          // SERVICES
          // ===============================================================

          else
            LayoutBuilder(
              builder: (
                BuildContext context,
                BoxConstraints constraints,
              ) {
                final double width = constraints.maxWidth;

                if (width >= 1200) {
                  return _DesktopServices(
                    subcategories: _subcategories,
                    onSubcategorySelected: widget.onSubcategorySelected,
                  );
                }

                if (width >= 700) {
                  return _TabletServices(
                    subcategories: _subcategories,
                    onSubcategorySelected: widget.onSubcategorySelected,
                  );
                }

                return _MobileServices(
                  subcategories: _subcategories,
                  onSubcategorySelected: widget.onSubcategorySelected,
                );
              },
            ),
        ],
      ),
    );
  }
}

// ===========================================================================
// DESKTOP SERVICES
// ===========================================================================

class _DesktopServices extends StatelessWidget {
  const _DesktopServices({
    required this.subcategories,
    required this.onSubcategorySelected,
  });

  final List<ServiceSubcategory> subcategories;
  final ValueChanged<ServiceSubcategory>? onSubcategorySelected;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 1750,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: subcategories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          // =============================================================
          // 8 CARDS PER ROW
          // =============================================================

          crossAxisCount: 8,

          crossAxisSpacing: 18,
          mainAxisSpacing: 18,

          // Compact card height
          mainAxisExtent: 225,
        ),
        itemBuilder: (
          BuildContext context,
          int index,
        ) {
          return _ServiceCard(
            subcategory: subcategories[index],
            index: index,
            onTap: onSubcategorySelected,
          );
        },
      ),
    );
  }
}

// ===========================================================================
// TABLET SERVICES
// ===========================================================================

class _TabletServices extends StatelessWidget {
  const _TabletServices({
    required this.subcategories,
    required this.onSubcategorySelected,
  });

  final List<ServiceSubcategory> subcategories;
  final ValueChanged<ServiceSubcategory>? onSubcategorySelected;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 1000,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: subcategories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          mainAxisExtent: 210,
        ),
        itemBuilder: (
          BuildContext context,
          int index,
        ) {
          return _ServiceCard(
            subcategory: subcategories[index],
            index: index,
            onTap: onSubcategorySelected,
          );
        },
      ),
    );
  }
}

// ===========================================================================
// MOBILE SERVICES
// ===========================================================================

class _MobileServices extends StatelessWidget {
  const _MobileServices({
    required this.subcategories,
    required this.onSubcategorySelected,
  });

  final List<ServiceSubcategory> subcategories;
  final ValueChanged<ServiceSubcategory>? onSubcategorySelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: subcategories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 13,
        mainAxisSpacing: 13,
        mainAxisExtent: 185,
      ),
      itemBuilder: (
        BuildContext context,
        int index,
      ) {
        return _ServiceCard(
          subcategory: subcategories[index],
          index: index,
          onTap: onSubcategorySelected,
        );
      },
    );
  }
}

// ===========================================================================
// PREMIUM SERVICE CARD
// ===========================================================================

class _ServiceCard extends StatefulWidget {
  const _ServiceCard({
    required this.subcategory,
    required this.index,
    required this.onTap,
  });

  final ServiceSubcategory subcategory;
  final int index;
  final ValueChanged<ServiceSubcategory>? onTap;

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _hovered = false;
  bool _pressed = false;

  // =========================================================================
  // CARD BACKGROUND COLORS
  // =========================================================================

  static const List<Color> _backgrounds = [
    Color(0xFFFFF1EE),
    Color(0xFFEAF4FF),
    Color(0xFFF5EEFF),
    Color(0xFFEAFBF4),
    Color(0xFFFFF8E5),
    Color(0xFFEDF5FF),
    Color(0xFFF4EEFF),
    Color(0xFFEAFBF5),
    Color(0xFFFFEFF5),
    Color(0xFFFFF3E8),
    Color(0xFFEDF7FF),
    Color(0xFFF3F0FF),
  ];

  // =========================================================================
  // ACCENT COLORS
  // =========================================================================

  static const List<Color> _accents = [
    Color(0xFFFF7564),
    Color(0xFF2688E8),
    Color(0xFF9658D9),
    Color(0xFF16AE7C),
    Color(0xFFD99B00),
    Color(0xFF357DD1),
    Color(0xFF7850D1),
    Color(0xFF13A473),
    Color(0xFFE25D88),
    Color(0xFFE08A36),
    Color(0xFF3180C9),
    Color(0xFF8060D9),
  ];

  Color get _backgroundColor {
    return _backgrounds[widget.index % _backgrounds.length];
  }

  Color get _accentColor {
    return _accents[widget.index % _accents.length];
  }

  @override
  Widget build(BuildContext context) {
    final bool active = _hovered || _pressed;

    return MouseRegion(
      cursor: SystemMouseCursors.click,

      // ===============================================================
      // HOVER ENTER
      // ===============================================================

      onEnter: (_) {
        setState(() {
          _hovered = true;
        });
      },

      // ===============================================================
      // HOVER EXIT
      // ===============================================================

      onExit: (_) {
        setState(() {
          _hovered = false;
        });
      },

      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 240,
        ),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(
          0,
          active ? -7 : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,

          // =============================================================
          // COMPACT ROUNDED CORNERS
          // =============================================================

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
              blurRadius: active ? 28 : 15,
              spreadRadius: active ? 1 : 0,
              offset: Offset(
                0,
                active ? 13 : 7,
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

            // ===========================================================
            // CARD CLICK
            // ===========================================================

            onTap: () {
              setState(() {
                _pressed = true;
              });

              // Existing booking callback
              widget.onTap?.call(
                widget.subcategory,
              );

              Future<void>.delayed(
                const Duration(
                  milliseconds: 180,
                ),
                () {
                  if (!mounted) return;

                  setState(() {
                    _pressed = false;
                  });
                },
              );
            },

            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  // =====================================================
                  // IMAGE CONTAINER
                  // =====================================================

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
                            _backgroundColor.withOpacity(0.62),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Stack(
                        children: [
                          // =================================================
                          // DECORATIVE GLOW
                          // =================================================

                          Positioned(
                            top: -18,
                            right: -18,
                            child: AnimatedContainer(
                              duration: const Duration(
                                milliseconds: 240,
                              ),
                              width: active ? 70 : 60,
                              height: active ? 70 : 60,
                              decoration: BoxDecoration(
                                color: _accentColor.withOpacity(
                                  active ? 0.13 : 0.08,
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),

                          // =================================================
                          // ACCENT DOT
                          // =================================================

                          Positioned(
                            top: 11,
                            right: 11,
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

                          // =================================================
                          // SERVICE IMAGE
                          // =================================================

                          Center(
                            child: AnimatedScale(
                              scale: active ? 1.07 : 1.0,
                              duration: const Duration(
                                milliseconds: 240,
                              ),
                              curve: Curves.easeOutCubic,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: ServiceImage(
                                  imageUrl: widget.subcategory.iconUrl,
                                  name: widget.subcategory.name,

                                  // Smaller image
                                  iconSize: 62,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // =====================================================
                  // SERVICE NAME + ARROW
                  // =====================================================

                  SizedBox(
                    height: 42,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // =================================================
                        // SERVICE NAME
                        // =================================================

                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 2,
                              right: 4,
                            ),
                            child: Text(
                              widget.subcategory.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                color: Color(0xFF102A43),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                height: 1.18,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 6),

                        // =================================================
                        // ARROW BUTTON
                        // =================================================

                        AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 220,
                          ),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: active
                                ? _accentColor
                                : _accentColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                            boxShadow: active
                                ? [
                                    BoxShadow(
                                      color: _accentColor.withOpacity(0.25),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// SECTION HEADING
// ===========================================================================

class _SectionHeading extends StatelessWidget {
  const _SectionHeading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ===============================================================
        // BADGE
        // ===============================================================

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFF0B4EA2).withOpacity(0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0x120B4EA2),
                blurRadius: 12,
                offset: const Offset(
                  0,
                  4,
                ),
              ),
            ],
          ),
          child: const Text(
            'ALL SERVICES  •  ONE PLATFORM',
            style: TextStyle(
              color: Color(0xFF0B4EA2),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ),

        const SizedBox(height: 15),

        // ===============================================================
        // TITLE
        // ===============================================================

        const Text(
          'Our Services',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF0B2D5C),
            fontSize: 36,
            fontWeight: FontWeight.w900,
            height: 1.08,
            letterSpacing: -0.8,
          ),
        ),

        const SizedBox(height: 10),

        // ===============================================================
        // GOLD ACCENT
        // ===============================================================

        Container(
          width: 58,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFF5B301),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0x55F5B301),
                blurRadius: 9,
                offset: const Offset(
                  0,
                  3,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ===============================================================
        // DESCRIPTION
        // ===============================================================

        const Text(
          'Professional services for your home and business needs',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF687B91),
            fontSize: 13.5,
            height: 1.45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
