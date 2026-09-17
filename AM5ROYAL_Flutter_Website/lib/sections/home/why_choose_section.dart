import 'package:flutter/material.dart';

class WhyChooseSection extends StatelessWidget {
  const WhyChooseSection({super.key});

  static const List<_WhyChooseItem> items = [
    _WhyChooseItem(
      icon: Icons.verified_user_rounded,
      title: 'Verified Professionals',
      description: 'All professionals are verified and trusted.',
      iconColor: Color(0xFF0878E5),
      backgroundColor: Color(0xFFEAF5FF),
      borderColor: Color(0xFFCFE7FF),
    ),
    _WhyChooseItem(
      icon: Icons.bolt_rounded,
      title: 'Fast & Reliable Service',
      description: 'Quick response and on-time service.',
      iconColor: Color(0xFFFFA900),
      backgroundColor: Color(0xFFFFF7E8),
      borderColor: Color(0xFFFFE4AE),
    ),
    _WhyChooseItem(
      icon: Icons.lock_rounded,
      title: 'Secure Payments',
      description: '100% secure online payments.',
      iconColor: Color(0xFF12A150),
      backgroundColor: Color(0xFFEAFBF2),
      borderColor: Color(0xFFCDEED9),
    ),
    _WhyChooseItem(
      icon: Icons.local_offer_rounded,
      title: 'Affordable Pricing',
      description: 'Best quality service at affordable price.',
      iconColor: Color(0xFFE91E63),
      backgroundColor: Color(0xFFFFF0F5),
      borderColor: Color(0xFFF6D3E1),
    ),
    _WhyChooseItem(
      icon: Icons.headset_mic_rounded,
      title: '24/7 Customer Support',
      description: 'We are here to help you anytime.',
      iconColor: Color(0xFF6D28D9),
      backgroundColor: Color(0xFFF5EFFF),
      borderColor: Color(0xFFE2D5FF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        24,
        28,
        24,
        34,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1450,
          ),
          child: Column(
            children: [
              // =========================================================
              // HEADING
              // =========================================================

              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Why Choose ',
                      style: TextStyle(
                        color: Color(0xFF123A70),
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    TextSpan(
                      text: 'AM5ROYAL?',
                      style: TextStyle(
                        color: Color(0xFF1976D2),
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 7),

              // =========================================================
              // SUBTITLE
              // =========================================================

              const Text(
                'Because your comfort, safety and satisfaction matter to us.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF637993),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.15,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 22),

              // =========================================================
              // CARDS
              // ALWAYS ONE ROW
              // =========================================================

              SizedBox(
                height: 112,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // ---------------------------------------------------
                    // DESKTOP
                    // 5 CARDS PERFECTLY FIT IN ONE ROW
                    // ---------------------------------------------------

                    if (constraints.maxWidth >= 1100) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: List.generate(
                          items.length,
                          (index) {
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: index == 0 ? 0 : 6,
                                  right: index == items.length - 1 ? 0 : 6,
                                ),
                                child: _WhyChooseCard(
                                  item: items[index],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }

                    // ---------------------------------------------------
                    // SMALL SCREEN
                    // STILL ONE ROW
                    // HORIZONTAL SCROLL
                    // ---------------------------------------------------

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: List.generate(
                          items.length,
                          (index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                left: index == 0 ? 0 : 6,
                                right: index == items.length - 1 ? 0 : 6,
                              ),
                              child: SizedBox(
                                width: 260,
                                child: _WhyChooseCard(
                                  item: items[index],
                                ),
                              ),
                            );
                          },
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

// =======================================================================
// CARD
// =======================================================================

class _WhyChooseCard extends StatefulWidget {
  const _WhyChooseCard({
    required this.item,
  });

  final _WhyChooseItem item;

  @override
  State<_WhyChooseCard> createState() => _WhyChooseCardState();
}

class _WhyChooseCardState extends State<_WhyChooseCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,

        // ===============================================================
        // PERFECT CARD HEIGHT
        // ===============================================================

        height: 112,

        transform: Matrix4.translationValues(
          0,
          _isHovered ? -3 : 0,
          0,
        ),

        decoration: BoxDecoration(
          color: item.backgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: item.borderColor,
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: item.iconColor.withOpacity(
                _isHovered ? 0.13 : 0.055,
              ),
              blurRadius: _isHovered ? 18 : 10,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // =========================================================
              // ICON OUTER CIRCLE
              // =========================================================

              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.82),
                  border: Border.all(
                    color: item.borderColor,
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: item.iconColor.withOpacity(0.13),
                    ),
                    child: Icon(
                      item.icon,
                      color: item.iconColor,
                      size: 28,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // =========================================================
              // CONTENT
              // =========================================================

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------------------------------------------------
                    // TITLE
                    // ---------------------------------------------------

                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF173653),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // ---------------------------------------------------
                    // DESCRIPTION
                    // ---------------------------------------------------

                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF657B91),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =======================================================================
// MODEL
// =======================================================================

class _WhyChooseItem {
  const _WhyChooseItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  final IconData icon;
  final String title;
  final String description;

  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
}
