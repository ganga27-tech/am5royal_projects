import 'package:flutter/material.dart';

class HomeCtaSection extends StatefulWidget {
  const HomeCtaSection({
    super.key,
    this.highlightCta = false,
  });

  final bool highlightCta;

  @override
  State<HomeCtaSection> createState() => _HomeCtaSectionState();
}

class _HomeCtaSectionState extends State<HomeCtaSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _phoneMove;

  static const Color navy = Color(0xFF082B5C);
  static const Color blue = Color(0xFF0B4EA2);
  static const Color cream = Color(0xFFF9EBD1);
  static const Color creamLight = Color(0xFFFCEFDD);
  static const Color gold = Color(0xFFFFC928);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _phoneMove = Tween<double>(
      begin: -3,
      end: 3,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;

    if (width < 700) {
      return _mobileLayout();
    }

    if (width < 1050) {
      return _tabletLayout();
    }

    return _desktopLayout();
  }

  Widget _desktopLayout() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 28,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cream,
            creamLight,
          ],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1180,
          ),
          child: SizedBox(
            height: 350,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // BLUE CTA
                Positioned(
                  left: 0,
                  right: 0,
                  top: 52,
                  height: 238,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          navy,
                          blue,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: widget.highlightCta
                              ? const Color(0x550B4EA2)
                              : const Color(0x25000000),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(
                        left: 48,
                        right: 300,
                      ),
                      child: Center(
                        child: _CtaText(),
                      ),
                    ),
                  ),
                ),

                // ANIMATED PHONE
                Positioned(
                  right: 72,
                  top: 0,
                  child: AnimatedBuilder(
                    animation: _phoneMove,
                    builder: (
                      BuildContext context,
                      Widget? child,
                    ) {
                      return Transform.translate(
                        offset: Offset(
                          _phoneMove.value,
                          0,
                        ),
                        child: child,
                      );
                    },
                    child: const _Phone(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabletLayout() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 25,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cream,
            creamLight,
          ],
        ),
      ),
      child: SizedBox(
        height: 350,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 50,
              height: 235,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      navy,
                      blue,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(
                    left: 28,
                    right: 220,
                  ),
                  child: Center(
                    child: _CtaText(
                      compact: true,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 28,
              top: 5,
              child: AnimatedBuilder(
                animation: _phoneMove,
                builder: (
                  BuildContext context,
                  Widget? child,
                ) {
                  return Transform.translate(
                    offset: Offset(
                      _phoneMove.value,
                      0,
                    ),
                    child: child,
                  );
                },
                child: const _Phone(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mobileLayout() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cream,
            creamLight,
          ],
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              navy,
              blue,
            ],
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            const _CtaText(
              compact: true,
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _phoneMove,
              builder: (
                BuildContext context,
                Widget? child,
              ) {
                return Transform.translate(
                  offset: Offset(
                    _phoneMove.value,
                    0,
                  ),
                  child: child,
                );
              },
              child: const _Phone(),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// CTA TEXT
// ============================================================================

class _CtaText extends StatelessWidget {
  const _CtaText({
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0x18FFFFFF),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0x45FFFFFF),
            ),
          ),
          child: const Text(
            'AM5ROYAL APP',
            style: TextStyle(
              color: _HomeCtaSectionState.gold,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Get AM5ROYAL on Your Phone',
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 22 : 28,
            fontWeight: FontWeight.w900,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 8),
        const SizedBox(
          width: 520,
          child: Text(
            'Book trusted services, connect with verified '
            'professionals and manage your service needs '
            'easily from your mobile.',
            style: TextStyle(
              color: Color(0xDDFFFFFF),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          height: 43,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1768BE),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0x55FFFFFF),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 22,
              ),
              SizedBox(width: 7),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GET IT ON',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                    ),
                  ),
                  Text(
                    'Google Play',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// PHONE FRAME  (this is the missing piece — built to safely host _PhoneScreen
// and _PhoneNav without overflow)
// ============================================================================

class _Phone extends StatelessWidget {
  const _Phone();

  static const double _frameWidth = 170;
  static const double _frameHeight = 340;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _frameWidth,
      height: _frameHeight,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B0B),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          color: _HomeCtaSectionState.creamLight,
          child: Column(
            children: [
              // Notch
              Container(
                height: 20,
                alignment: Alignment.center,
                color: _HomeCtaSectionState.navy,
                child: Container(
                  width: 46,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // Screen — Expanded so it takes exactly the remaining bounded
              // space between notch and bottom nav. This is what fixes the
              // 21px overflow: FittedBox(scaleDown) inside _PhoneScreen now
              // has a real height ceiling to shrink into instead of an
              // unbounded/undersized one.
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _PhoneScreen(),
                ),
              ),

              // Bottom nav bar
              Container(
                height: 34,
                color: Colors.white,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _PhoneNav(
                      icon: Icons.home_rounded,
                      active: true,
                    ),
                    _PhoneNav(icon: Icons.calendar_today_rounded),
                    _PhoneNav(icon: Icons.settings_rounded),
                    _PhoneNav(icon: Icons.person_rounded),
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

// ============================================================================
// PHONE SCREEN CONTENT
// ============================================================================

class _PhoneScreen extends StatelessWidget {
  const _PhoneScreen();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: ClipRect(
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ----------------------------------------------------------
                // HEADER
                // ----------------------------------------------------------

                const SizedBox(
                  width: 134,
                  height: 18,
                  child: Row(
                    children: [
                      Icon(
                        Icons.home_work_rounded,
                        color: _HomeCtaSectionState.navy,
                        size: 16,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'AM5ROYAL',
                        style: TextStyle(
                          color: _HomeCtaSectionState.navy,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.notifications_none_rounded,
                        color: _HomeCtaSectionState.navy,
                        size: 16,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 3),

                // ----------------------------------------------------------
                // HELLO
                // ----------------------------------------------------------

                const Text(
                  'Hello 👋',
                  style: TextStyle(
                    color: _HomeCtaSectionState.navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 3),

                // ----------------------------------------------------------
                // SEARCH
                // ----------------------------------------------------------

                Container(
                  width: 134,
                  height: 22,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: Color(0xFF777777),
                        size: 10,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Search services',
                        style: TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // ----------------------------------------------------------
                // POPULAR SERVICES
                // ----------------------------------------------------------

                const Text(
                  'Popular Services',
                  style: TextStyle(
                    color: _HomeCtaSectionState.navy,
                    fontSize: 7,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 3),

                const Row(
                  children: [
                    _ServiceCard(
                      icon: Icons.electrical_services_rounded,
                      title: 'Electrical',
                    ),
                    SizedBox(width: 3),
                    _ServiceCard(
                      icon: Icons.plumbing_rounded,
                      title: 'Plumbing',
                    ),
                    SizedBox(width: 3),
                    _ServiceCard(
                      icon: Icons.cleaning_services_rounded,
                      title: 'Cleaning',
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // ----------------------------------------------------------
                // TRUSTED PROFESSIONALS
                // ----------------------------------------------------------

                Container(
                  width: 134,
                  height: 38,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        _HomeCtaSectionState.navy,
                        _HomeCtaSectionState.blue,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Trusted Professionals',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 6,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        'Verified experts at your doorstep',
                        style: TextStyle(
                          color: Color(0xDDFFFFFF),
                          fontSize: 4,
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        '✓ Verified & Reliable',
                        style: TextStyle(
                          color: _HomeCtaSectionState.gold,
                          fontSize: 4,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // ----------------------------------------------------------
                // YOUR BOOKING
                // ----------------------------------------------------------

                const Text(
                  'Your Booking',
                  style: TextStyle(
                    color: _HomeCtaSectionState.navy,
                    fontSize: 7,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 2),

                Container(
                  width: 134,
                  height: 23,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF19A463),
                        size: 10,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Service booked successfully',
                        style: TextStyle(
                          color: Color(0xFF27313D),
                          fontSize: 4.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // ----------------------------------------------------------
                // QUICK SERVICES
                // ----------------------------------------------------------

                const Text(
                  'Quick Services',
                  style: TextStyle(
                    color: _HomeCtaSectionState.navy,
                    fontSize: 7,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 2),

                Container(
                  width: 134,
                  height: 21,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.ac_unit_rounded,
                        color: _HomeCtaSectionState.blue,
                        size: 9,
                      ),
                      Icon(
                        Icons.format_paint_rounded,
                        color: _HomeCtaSectionState.blue,
                        size: 9,
                      ),
                      Icon(
                        Icons.carpenter_rounded,
                        color: _HomeCtaSectionState.blue,
                        size: 9,
                      ),
                      Icon(
                        Icons.local_shipping_rounded,
                        color: _HomeCtaSectionState.blue,
                        size: 9,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SERVICE CARD (used inside Popular Services row — was referenced but
// missing from the original file too)
// ============================================================================

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: _HomeCtaSectionState.blue,
            size: 12,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: _HomeCtaSectionState.navy,
              fontSize: 4,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PHONE NAV
// ============================================================================

class _PhoneNav extends StatelessWidget {
  const _PhoneNav({
    required this.icon,
    this.active = false,
  });

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: 12,
      color: active ? _HomeCtaSectionState.blue : const Color(0xFF858A91),
    );
  }
}
