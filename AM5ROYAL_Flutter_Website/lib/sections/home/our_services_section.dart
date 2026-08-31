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
      items.sort((a, b) => a.name.compareTo(b.name));
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
                icon: const Icon(
                  Icons.person_outline_rounded,
                  size: 18,
                ),
                label: const Text(
                  'Become a Partner',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0B4EA2),
                  side: const BorderSide(
                    color: Color(0xFF0B4EA2),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: widget.onBookService,
                icon: const Icon(
                  Icons.calendar_month_outlined,
                  size: 18,
                ),
                label: const Text(
                  'Book a Service',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B4EA2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: CircularProgressIndicator(
                color: Color(0xFF0B4EA2),
              ),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Text(
                    'Could not load services.',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _loadSubcategories,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else if (_subcategories.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No services available right now.',
                style: TextStyle(color: Color(0xFF687B91)),
              ),
            )
          else
            LayoutBuilder(
              builder: (
                BuildContext context,
                BoxConstraints constraints,
              ) {
                final double width = constraints.maxWidth;

                if (width >= 1100) {
                  return _DesktopServices(
                    subcategories: _subcategories,
                    onSubcategorySelected: widget.onSubcategorySelected,
                  );
                }

                if (width >= 650) {
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
        maxWidth: 1500,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: subcategories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 9,
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
          mainAxisExtent: 142,
        ),
        itemBuilder: (BuildContext context, int index) {
          return _ServiceCard(
            subcategory: subcategories[index],
            onTap: onSubcategorySelected,
          );
        },
      ),
    );
  }
}

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
        maxWidth: 900,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: subcategories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          mainAxisExtent: 140,
        ),
        itemBuilder: (BuildContext context, int index) {
          return _ServiceCard(
            subcategory: subcategories[index],
            onTap: onSubcategorySelected,
          );
        },
      ),
    );
  }
}

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
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 132,
      ),
      itemBuilder: (BuildContext context, int index) {
        return _ServiceCard(
          subcategory: subcategories[index],
          onTap: onSubcategorySelected,
        );
      },
    );
  }
}

class _ServiceCard extends StatefulWidget {
  const _ServiceCard({
    required this.subcategory,
    required this.onTap,
  });

  final ServiceSubcategory subcategory;
  final ValueChanged<ServiceSubcategory>? onTap;

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
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
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
              setState(() => _pressed = true);
              widget.onTap?.call(widget.subcategory);
              Future<void>.delayed(
                const Duration(milliseconds: 180),
                () {
                  if (mounted) setState(() => _pressed = false);
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
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: ServiceImage(
                      imageUrl: widget.subcategory.iconUrl,
                      name: widget.subcategory.name,
                      iconSize: 36,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 34,
                    child: Center(
                      child: Text(
                        widget.subcategory.name,
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
