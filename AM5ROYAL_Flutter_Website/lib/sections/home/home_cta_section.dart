import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeCtaSection extends StatefulWidget {
  const HomeCtaSection({
    super.key,
    this.highlightCta = false,
  });

  final bool highlightCta;

  static const Color backgroundStart = Color(0xFFF9EBD1);
  static const Color backgroundEnd = Color(0xFFFCEFDD);
  static const Color navy = Color(0xFF082B5C);
  static const Color royalBlue = Color(0xFF0B4EA2);
  static const Color gold = Color(0xFFFFC928);

  @override
  State<HomeCtaSection> createState() => _HomeCtaSectionState();
}

class _HomeCtaSectionState extends State<HomeCtaSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _phoneAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _phoneAnimation = Tween<double>(
      begin: -5,
      end: 5,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // OPEN GOOGLE PLAY STORE
  // ===========================================================================

  Future<void> _openPlayStore() async {
    final Uri uri = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.am5royal.am5royal',
    );

    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );

      if (!launched) {
        await launchUrl(
          uri,
          webOnlyWindowName: '_blank',
        );
      }
    } catch (_) {
      // Keep website stable if Play Store cannot be opened.
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
            HomeCtaSection.backgroundStart,
            HomeCtaSection.backgroundEnd,
          ],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;

          if (width < 700) {
            return _buildMobile(width);
          }

          if (width < 1050) {
            return _buildTablet(width);
          }

          return _buildDesktop(width);
        },
      ),
    );
  }

  // ===========================================================================
  // MOBILE
  // ===========================================================================

  Widget _buildMobile(double width) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        14,
        28,
        14,
        36,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(
          18,
          24,
          18,
          24,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              HomeCtaSection.navy,
              HomeCtaSection.royalBlue,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: widget.highlightCta
                  ? const Color(0x550B4EA2)
                  : const Color(0x30000000),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _AppLabel(),
            const SizedBox(height: 14),
            const Text(
              'Get AM5ROYAL on Your Phone',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Book trusted services, connect with verified '
              'professionals and manage your service needs '
              'easily from your mobile.',
              style: TextStyle(
                color: Color(0xDDFFFFFF),
                fontSize: 13,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 18),
            _GooglePlayButton(
              onPressed: _openPlayStore,
            ),
            const SizedBox(height: 24),
            Center(
              child: _AnimatedPhone(
                animation: _phoneAnimation,
                width: 178,
                height: 360,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // TABLET
  // ===========================================================================

  Widget _buildTablet(double width) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        32,
        20,
        42,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              HomeCtaSection.navy,
              HomeCtaSection.royalBlue,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: widget.highlightCta
                  ? const Color(0x550B4EA2)
                  : const Color(0x30000000),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 6,
              child: _CtaText(
                compact: true,
                onPlayStore: _openPlayStore,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 4,
              child: Center(
                child: _AnimatedPhone(
                  animation: _phoneAnimation,
                  width: 165,
                  height: 340,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // DESKTOP
  // ===========================================================================

  Widget _buildDesktop(double width) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        32,
        48,
        32,
        58,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1180,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 48,
              vertical: 42,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  HomeCtaSection.navy,
                  HomeCtaSection.royalBlue,
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: const Color(0x25FFFFFF),
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.highlightCta
                      ? const Color(0x550B4EA2)
                      : const Color(0x30000000),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 6,
                  child: _CtaText(
                    onPlayStore: _openPlayStore,
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: _AnimatedPhone(
                      animation: _phoneAnimation,
                      width: 175,
                      height: 355,
                    ),
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

// =============================================================================
// CTA TEXT
// =============================================================================

class _CtaText extends StatelessWidget {
  const _CtaText({
    required this.onPlayStore,
    this.compact = false,
  });

  final VoidCallback onPlayStore;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _AppLabel(),
        const SizedBox(height: 15),
        Text(
          'Get AM5ROYAL on Your Phone',
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 25 : 31,
            fontWeight: FontWeight.w900,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Book trusted services, connect with verified '
          'professionals and manage your service needs '
          'easily from your mobile.',
          style: TextStyle(
            color: Color(0xDDFFFFFF),
            fontSize: 14,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 20),
        _GooglePlayButton(
          onPressed: onPlayStore,
        ),
      ],
    );
  }
}

// =============================================================================
// APP LABEL
// =============================================================================

class _AppLabel extends StatelessWidget {
  const _AppLabel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 7,
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
          color: HomeCtaSection.gold,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

// =============================================================================
// GOOGLE PLAY BUTTON
// =============================================================================

class _GooglePlayButton extends StatelessWidget {
  const _GooglePlayButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1768BE),
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
            side: const BorderSide(
              color: Color(0x55FFFFFF),
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // =================================================================
            // GOOGLE PLAY STORE ICON
            // =================================================================

            const SizedBox(
              width: 31,
              height: 31,
              child: CustomPaint(
                painter: _GooglePlayIconPainter(),
              ),
            ),

            const SizedBox(width: 9),

            // =================================================================
            // GOOGLE PLAY TEXT
            // =================================================================

            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GET IT ON',
                  style: TextStyle(
                    color: Color(0xDDFFFFFF),
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Play Store',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// GOOGLE PLAY STORE ICON
//
// Draws the Google Play triangular logo directly in Flutter.
// This avoids any dependency on google_play_icon.png.
// =============================================================================

class _GooglePlayIconPainter extends CustomPainter {
  const _GooglePlayIconPainter();

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final double w = size.width;
    final double h = size.height;

    // ========================================================================
    // BLUE MAIN PLAY SHAPE
    // ========================================================================

    final Path bluePath = Path()
      ..moveTo(w * 0.10, h * 0.07)
      ..quadraticBezierTo(
        w * 0.05,
        h * 0.10,
        w * 0.05,
        h * 0.18,
      )
      ..lineTo(w * 0.05, h * 0.82)
      ..quadraticBezierTo(
        w * 0.05,
        h * 0.90,
        w * 0.10,
        h * 0.93,
      )
      ..lineTo(w * 0.57, h * 0.50)
      ..close();

    final Paint bluePaint = Paint()
      ..color = const Color(0xFF00A4EF)
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      bluePath,
      bluePaint,
    );

    // ========================================================================
    // GREEN SECTION
    // ========================================================================

    final Path greenPath = Path()
      ..moveTo(w * 0.10, h * 0.07)
      ..lineTo(w * 0.72, h * 0.40)
      ..lineTo(w * 0.57, h * 0.50)
      ..close();

    final Paint greenPaint = Paint()
      ..color = const Color(0xFF00D084)
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      greenPath,
      greenPaint,
    );

    // ========================================================================
    // YELLOW SECTION
    // ========================================================================

    final Path yellowPath = Path()
      ..moveTo(w * 0.57, h * 0.50)
      ..lineTo(w * 0.72, h * 0.60)
      ..lineTo(w * 0.10, h * 0.93)
      ..close();

    final Paint yellowPaint = Paint()
      ..color = const Color(0xFFFFD500)
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      yellowPath,
      yellowPaint,
    );

    // ========================================================================
    // RED SECTION
    // ========================================================================

    final Path redPath = Path()
      ..moveTo(w * 0.72, h * 0.40)
      ..lineTo(w * 0.88, h * 0.48)
      ..quadraticBezierTo(
        w * 0.96,
        h * 0.50,
        w * 0.88,
        h * 0.55,
      )
      ..lineTo(w * 0.72, h * 0.60)
      ..lineTo(w * 0.57, h * 0.50)
      ..close();

    final Paint redPaint = Paint()
      ..color = const Color(0xFFFF3B30)
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      redPath,
      redPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}

// =============================================================================
// ANIMATED PHONE
// =============================================================================

class _AnimatedPhone extends StatelessWidget {
  const _AnimatedPhone({
    required this.animation,
    required this.width,
    required this.height,
  });

  final Animation<double> animation;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            animation.value,
          ),
          child: child,
        );
      },
      child: _Phone(
        width: width,
        height: height,
      ),
    );
  }
}

// =============================================================================
// PHONE
// =============================================================================

class _Phone extends StatelessWidget {
  const _Phone({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0x66909090),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x45000000),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // PHONE TOP
          Container(
            width: double.infinity,
            height: 28,
            color: HomeCtaSection.navy,
            alignment: Alignment.center,
            child: const Text(
              'AM5ROYAL',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),

          // PHONE SCREEN
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(0xFFF9EBD1),
              child: const Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topCenter,
                  child: _PhoneContent(),
                ),
              ),
            ),
          ),

          // PHONE BOTTOM NAV
          const _PhoneBottomNav(),
        ],
      ),
    );
  }
}

// =============================================================================
// PHONE CONTENT
// =============================================================================

class _PhoneContent extends StatelessWidget {
  const _PhoneContent();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          const SizedBox(
            height: 22,
            child: Row(
              children: [
                Icon(
                  Icons.home_work_rounded,
                  color: HomeCtaSection.navy,
                  size: 16,
                ),
                SizedBox(width: 5),
                Text(
                  'AM5ROYAL',
                  style: TextStyle(
                    color: HomeCtaSection.navy,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.notifications_none_rounded,
                  color: HomeCtaSection.navy,
                  size: 17,
                ),
              ],
            ),
          ),

          const SizedBox(height: 5),

          // HELLO
          const Text(
            'Hello 👋',
            style: TextStyle(
              color: HomeCtaSection.navy,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 6),

          // SEARCH
          Container(
            width: double.infinity,
            height: 28,
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: Color(0xFF858A91),
                  size: 13,
                ),
                SizedBox(width: 5),
                Text(
                  'Search services',
                  style: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 7,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // POPULAR
          const Text(
            'Popular Services',
            style: TextStyle(
              color: HomeCtaSection.navy,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 5),

          const Row(
            children: [
              Expanded(
                child: _ServiceCard(
                  icon: Icons.electrical_services_rounded,
                  title: 'Electrical',
                ),
              ),
              SizedBox(width: 4),
              Expanded(
                child: _ServiceCard(
                  icon: Icons.plumbing_rounded,
                  title: 'Plumbing',
                ),
              ),
              SizedBox(width: 4),
              Expanded(
                child: _ServiceCard(
                  icon: Icons.cleaning_services_rounded,
                  title: 'Cleaning',
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // TRUSTED PROFESSIONALS
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  HomeCtaSection.navy,
                  HomeCtaSection.royalBlue,
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trusted Professionals',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Verified experts at your doorstep',
                  style: TextStyle(
                    color: Color(0xDDFFFFFF),
                    fontSize: 6,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '✓ Verified & Reliable',
                  style: TextStyle(
                    color: HomeCtaSection.gold,
                    fontSize: 5.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // BOOKING TITLE
          const Text(
            'Your Booking',
            style: TextStyle(
              color: HomeCtaSection.navy,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 4),

          // BOOKING
          Container(
            width: double.infinity,
            height: 30,
            padding: const EdgeInsets.symmetric(
              horizontal: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF19A463),
                  size: 13,
                ),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Service booked successfully',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF27313D),
                      fontSize: 6.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // QUICK SERVICES
          const Text(
            'Quick Services',
            style: TextStyle(
              color: HomeCtaSection.navy,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 4),

          Container(
            width: double.infinity,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  Icons.ac_unit_rounded,
                  color: HomeCtaSection.royalBlue,
                  size: 12,
                ),
                Icon(
                  Icons.format_paint_rounded,
                  color: HomeCtaSection.royalBlue,
                  size: 12,
                ),
                Icon(
                  Icons.carpenter_rounded,
                  color: HomeCtaSection.royalBlue,
                  size: 12,
                ),
                Icon(
                  Icons.local_shipping_rounded,
                  color: HomeCtaSection.royalBlue,
                  size: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SERVICE CARD
// =============================================================================

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
      height: 51,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 15,
            color: HomeCtaSection.royalBlue,
          ),
          const SizedBox(height: 3),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF27313D),
              fontSize: 5.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PHONE BOTTOM NAV
// =============================================================================

class _PhoneBottomNav extends StatelessWidget {
  const _PhoneBottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 42,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE2E5E9),
          ),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _PhoneNavItem(
            icon: Icons.home_rounded,
            active: true,
          ),
          _PhoneNavItem(
            icon: Icons.calendar_month_rounded,
          ),
          _PhoneNavItem(
            icon: Icons.miscellaneous_services_rounded,
          ),
          _PhoneNavItem(
            icon: Icons.person_rounded,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PHONE NAV ITEM
// =============================================================================

class _PhoneNavItem extends StatelessWidget {
  const _PhoneNavItem({
    required this.icon,
    this.active = false,
  });

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: 15,
      color: active ? HomeCtaSection.royalBlue : const Color(0xFF858A91),
    );
  }
}
