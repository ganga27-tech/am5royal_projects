import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';

enum NavbarSectionId {
  home,
  services,
  vendor,
  customer,
  freelancer,
  careers,
  contact,
  howItWorks,
  faqs,
  privacyPolicy,
  termsConditions,
}

class NavbarSection extends StatefulWidget {
  const NavbarSection({
    super.key,
    required this.currentSection,
    required this.onSectionSelected,
    this.onLoginPressed,
    this.onRegisterPressed,
    this.isAuthenticated = false,
    this.customerName,
    this.onLogout,
    this.onBookService,
  });

  final NavbarSectionId currentSection;
  final ValueChanged<NavbarSectionId> onSectionSelected;

  final VoidCallback? onLoginPressed;
  final VoidCallback? onRegisterPressed;
  final bool isAuthenticated;
  final String? customerName;
  final VoidCallback? onLogout;
  final VoidCallback? onBookService;

  @override
  State<NavbarSection> createState() => _NavbarSectionState();
}

class _NavbarSectionState extends State<NavbarSection> {
  bool _menuOpen = false;

  void _selectSection(NavbarSectionId section) {
    widget.onSectionSelected(section);

    if (_menuOpen) {
      setState(() {
        _menuOpen = false;
      });
    }
  }

  void _login() {
    widget.onLoginPressed?.call();
  }

  void _register() {
    widget.onRegisterPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;

    // Full desktop navigation only when there is enough space.
    final bool isDesktop = width >= 1200;

    final bool isHome = widget.currentSection == NavbarSectionId.home;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isHome ? Colors.white : AppColors.navy,
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 88,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 38 : 20,
                ),
                child: Row(
                  children: [
                    // =========================================================
                    // LOGO
                    // =========================================================

                    _BrandLogo(
                      isHome: isHome,
                      onTap: () {
                        _selectSection(
                          NavbarSectionId.home,
                        );
                      },
                    ),

                    const SizedBox(width: 35),

                    // =========================================================
                    // DESKTOP NAVIGATION
                    // =========================================================

                    if (isDesktop)
                      Expanded(
                        child: _DesktopNavigation(
                          currentSection: widget.currentSection,
                          isHome: isHome,
                          onSectionSelected: _selectSection,
                        ),
                      ),

                    // =========================================================
                    // DESKTOP AUTH
                    // =========================================================

                    if (isDesktop) ...[
                      const SizedBox(width: 30),
                      _DesktopAuthButtons(
                        isHome: isHome,
                        onLogin: _login,
                        onRegister: _register,
                        isAuthenticated: widget.isAuthenticated,
                        customerName: widget.customerName,
                        onLogout: widget.onLogout,
                        onBookService: widget.onBookService,
                      ),
                    ],

                    // =========================================================
                    // TABLET / MOBILE MENU
                    // =========================================================

                    if (!isDesktop) ...[
                      const Spacer(),
                      _MobileMenuButton(
                        isHome: isHome,
                        isOpen: _menuOpen,
                        onPressed: () {
                          setState(() {
                            _menuOpen = !_menuOpen;
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),

        // MOBILE / TABLET MENU
        if (!isDesktop && _menuOpen)
          _MobileNavigation(
            currentSection: widget.currentSection,
            isHome: isHome,
            onSectionSelected: _selectSection,
            onLogin: _login,
            onRegister: _register,
            isAuthenticated: widget.isAuthenticated,
            customerName: widget.customerName,
            onLogout: widget.onLogout,
            onBookService: widget.onBookService,
          ),
      ],
    );
  }
}

// =============================================================================
// BRAND LOGO
// =============================================================================

class _BrandLogo extends StatelessWidget {
  const _BrandLogo({
    required this.isHome,
    required this.onTap,
  });

  final bool isHome;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 175,
          height: 72,
          child: Image.asset(
            AppAssets.logo,
            fit: BoxFit.contain,
            errorBuilder: (
              context,
              error,
              stackTrace,
            ) {
              return Text(
                'AM5ROYAL',
                style: TextStyle(
                  color: isHome ? const Color(0xFF0B2D5C) : Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// DESKTOP NAVIGATION
// =============================================================================

class _DesktopNavigation extends StatelessWidget {
  const _DesktopNavigation({
    required this.currentSection,
    required this.isHome,
    required this.onSectionSelected,
  });

  final NavbarSectionId currentSection;
  final bool isHome;
  final ValueChanged<NavbarSectionId> onSectionSelected;

  static const List<_NavbarItemData> items = [
    _NavbarItemData(
      id: NavbarSectionId.home,
      label: 'Home',
    ),
    _NavbarItemData(
      id: NavbarSectionId.services,
      label: 'Services',
    ),
    // _NavbarItemData(
    // id: NavbarSectionId.vendor,
    //label: 'Partner with us',
    //),
    _NavbarItemData(
      id: NavbarSectionId.customer,
      label: 'Customer',
    ),
    _NavbarItemData(
      id: NavbarSectionId.freelancer,
      label: 'Freelancer',
    ),
    _NavbarItemData(
      id: NavbarSectionId.careers,
      label: 'Careers',
    ),
    _NavbarItemData(
      id: NavbarSectionId.contact,
      label: 'Contact Us',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in items)
              _DesktopNavigationItem(
                key: ValueKey(item.id),
                item: item,
                selected: currentSection == item.id,
                isHome: isHome,
                onTap: () {
                  onSectionSelected(item.id);
                },
              ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// DESKTOP NAVIGATION ITEM
// =============================================================================

class _DesktopNavigationItem extends StatefulWidget {
  const _DesktopNavigationItem({
    super.key,
    required this.item,
    required this.selected,
    required this.isHome,
    required this.onTap,
  });

  final _NavbarItemData item;
  final bool selected;
  final bool isHome;
  final VoidCallback onTap;

  @override
  State<_DesktopNavigationItem> createState() => _DesktopNavigationItemState();
}

class _DesktopNavigationItemState extends State<_DesktopNavigationItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool active = widget.selected || _hovered;

    final Color normalColor =
        widget.isHome ? const Color(0xFF102A43) : Colors.white;

    final Color activeColor =
        widget.isHome ? AppColors.royalBlue : AppColors.accentGold;

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
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,

          // IMPORTANT: proper spacing between nav items
          margin: const EdgeInsets.symmetric(
            horizontal: 5,
          ),

          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 11,
          ),

          decoration: BoxDecoration(
            color: active
                ? (widget.isHome
                    ? const Color(0x0D0B4EA2)
                    : const Color(0x18FFFFFF))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.item.label,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  color: active ? activeColor : normalColor,

                  // Professional readable size
                  fontSize: 15.5,

                  fontWeight:
                      widget.selected ? FontWeight.w700 : FontWeight.w600,

                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(
                  milliseconds: 180,
                ),
                width: widget.selected ? 32 : 0,
                height: 2.5,
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// DESKTOP LOGIN / REGISTER
// =============================================================================

class _DesktopAuthButtons extends StatelessWidget {
  const _DesktopAuthButtons({
    required this.isHome,
    required this.onLogin,
    required this.onRegister,
    this.isAuthenticated = false,
    this.customerName,
    this.onLogout,
    this.onBookService,
  });

  final bool isHome;
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final bool isAuthenticated;
  final String? customerName;
  final VoidCallback? onLogout;
  final VoidCallback? onBookService;

  @override
  Widget build(BuildContext context) {
    final Color blue = AppColors.royalBlue;

    if (isAuthenticated) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (customerName != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                customerName!,
                style: TextStyle(
                  color: isHome ? blue : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: onBookService,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGold,
                foregroundColor: const Color(0xFF10233D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Book a Service',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            tooltip: 'Logout',
            onPressed: onLogout,
            icon: Icon(
              Icons.logout_rounded,
              color: isHome ? blue : Colors.white,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ===============================================================
        // LOGIN
        // ===============================================================

        SizedBox(
          width: 155,
          height: 48,
          child: OutlinedButton(
            onPressed: onLogin,
            style: OutlinedButton.styleFrom(
              foregroundColor: isHome ? blue : Colors.white,
              backgroundColor: Colors.transparent,
              side: BorderSide(
                color: isHome ? blue : Colors.white,
                width: 1.5,
              ),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Login',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // ===============================================================
        // REGISTER
        // ===============================================================

        SizedBox(
          width: 155,
          height: 48,
          child: ElevatedButton(
            onPressed: onRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGold,
              foregroundColor: const Color(0xFF10233D),
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Register',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// MOBILE MENU BUTTON
// =============================================================================

class _MobileMenuButton extends StatelessWidget {
  const _MobileMenuButton({
    required this.isHome,
    required this.isOpen,
    required this.onPressed,
  });

  final bool isHome;
  final bool isOpen;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: isOpen ? 'Close menu' : 'Open menu',
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: Icon(
          isOpen ? Icons.close_rounded : Icons.menu_rounded,
          key: ValueKey(isOpen),
          color: isHome ? const Color(0xFF102A43) : Colors.white,
          size: 30,
        ),
      ),
    );
  }
}

// =============================================================================
// MOBILE NAVIGATION
// =============================================================================

class _MobileNavigation extends StatelessWidget {
  const _MobileNavigation({
    required this.currentSection,
    required this.isHome,
    required this.onSectionSelected,
    required this.onLogin,
    required this.onRegister,
    this.isAuthenticated = false,
    this.customerName,
    this.onLogout,
    this.onBookService,
  });

  final NavbarSectionId currentSection;
  final bool isHome;
  final ValueChanged<NavbarSectionId> onSectionSelected;
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final bool isAuthenticated;
  final String? customerName;
  final VoidCallback? onLogout;
  final VoidCallback? onBookService;

  static const List<_NavbarItemData> items = [
    _NavbarItemData(
      id: NavbarSectionId.home,
      label: 'Home',
      icon: Icons.home_outlined,
    ),
    _NavbarItemData(
      id: NavbarSectionId.services,
      label: 'Services',
      icon: Icons.home_repair_service_outlined,
    ),
    //_NavbarItemData(
    // id: NavbarSectionId.vendor,
    // label: 'Partner with us',
    // icon: Icons.handshake_outlined,
    //),
    _NavbarItemData(
      id: NavbarSectionId.customer,
      label: 'Customer',
      icon: Icons.person_outline_rounded,
    ),
    _NavbarItemData(
      id: NavbarSectionId.freelancer,
      label: 'Freelancer',
      icon: Icons.work_outline_rounded,
    ),
    _NavbarItemData(
      id: NavbarSectionId.careers,
      label: 'Careers',
      icon: Icons.business_center_outlined,
    ),
    _NavbarItemData(
      id: NavbarSectionId.contact,
      label: 'Contact Us',
      icon: Icons.mail_outline_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: isHome ? Colors.white : AppColors.navy,
      padding: const EdgeInsets.fromLTRB(
        18,
        10,
        18,
        20,
      ),
      child: Column(
        children: [
          for (final item in items)
            _MobileNavigationItem(
              key: ValueKey(item.id),
              item: item,
              selected: currentSection == item.id,
              isHome: isHome,
              onTap: () {
                onSectionSelected(
                  item.id,
                );
              },
            ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: isHome ? const Color(0xFFE3EAF2) : const Color(0x35FFFFFF),
          ),
          const SizedBox(height: 15),
          if (isAuthenticated) ...[
            if (customerName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Hi, $customerName',
                  style: TextStyle(
                    color: isHome ? AppColors.royalBlue : Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: onBookService,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGold,
                  foregroundColor: const Color(0xFF10233D),
                ),
                child: const Text(
                  'Book a Service',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: onLogout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: isHome ? AppColors.royalBlue : Colors.white,
                  side: BorderSide(
                    color: isHome ? AppColors.royalBlue : Colors.white,
                  ),
                ),
                child: const Text('Logout'),
              ),
            ),
          ] else
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    onPressed: onLogin,
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          isHome ? AppColors.royalBlue : Colors.white,
                      side: BorderSide(
                        color: isHome ? AppColors.royalBlue : Colors.white,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          9,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: onRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGold,
                      foregroundColor: const Color(
                        0xFF10233D,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          9,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 15,
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
    );
  }
}

// =============================================================================
// MOBILE NAVIGATION ITEM
// =============================================================================

class _MobileNavigationItem extends StatelessWidget {
  const _MobileNavigationItem({
    super.key,
    required this.item,
    required this.selected,
    required this.isHome,
    required this.onTap,
  });

  final _NavbarItemData item;
  final bool selected;
  final bool isHome;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color normalColor = isHome ? const Color(0xFF102A43) : Colors.white;

    final Color activeColor =
        isHome ? AppColors.royalBlue : AppColors.accentGold;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: selected
                ? (isHome ? const Color(0x0D0B4EA2) : const Color(0x18F5B301))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                color: selected ? activeColor : normalColor,
                size: 21,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? activeColor : normalColor,
                    fontSize: 15.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              if (selected)
                Icon(
                  Icons.arrow_forward_rounded,
                  color: activeColor,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// NAVBAR DATA
// =============================================================================

class _NavbarItemData {
  const _NavbarItemData({
    required this.id,
    required this.label,
    this.icon = Icons.circle_outlined,
  });

  final NavbarSectionId id;
  final String label;
  final IconData icon;
}
