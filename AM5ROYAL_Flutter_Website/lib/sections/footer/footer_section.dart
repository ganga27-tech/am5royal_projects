import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/vendor_navigation.dart';
import '../navbar/navbar_section.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({
    super.key,
    required this.onSectionSelected,
  });

  final ValueChanged<NavbarSectionId> onSectionSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.navy,
            AppColors.royalBlue,
          ],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              36,
              32,
              36,
              28,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool desktop = constraints.maxWidth >= 900;

                if (desktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        flex: 2,
                        child: _BrandColumn(),
                      ),
                      const SizedBox(width: 35),
                      Expanded(
                        child: _QuickLinksColumn(
                          onSectionSelected: onSectionSelected,
                        ),
                      ),
                      const SizedBox(width: 25),
                      Expanded(
                        child: _SupportColumn(
                          onSectionSelected: onSectionSelected,
                        ),
                      ),
                      const SizedBox(width: 25),
                      const Expanded(
                        child: _ProfessionalColumn(),
                      ),
                      const SizedBox(width: 25),
                      const Expanded(
                        child: _ContactColumn(),
                      ),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _BrandColumn(),
                    const SizedBox(height: 28),
                    _QuickLinksColumn(
                      onSectionSelected: onSectionSelected,
                    ),
                    const SizedBox(height: 26),
                    _SupportColumn(
                      onSectionSelected: onSectionSelected,
                    ),
                    const SizedBox(height: 26),
                    const _ProfessionalColumn(),
                    const SizedBox(height: 26),
                    const _ContactColumn(),
                  ],
                );
              },
            ),
          ),

          // ================================================================
          // COPYRIGHT
          // ================================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Color(0x30FFFFFF),
                  width: 1,
                ),
              ),
            ),
            child: const Text(
              '© 2026 AM5ROYAL. All Rights Reserved.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xCFFFFFFF),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// BRAND
// ============================================================================

class _BrandColumn extends StatelessWidget {
  const _BrandColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          height: 50,
          child: Image.asset(
            AppAssets.logo,
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
            errorBuilder: (
              BuildContext context,
              Object error,
              StackTrace? stackTrace,
            ) {
              return const Text(
                'AM5ROYAL',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'About AM5ROYAL',
          style: TextStyle(
            color: AppColors.accentGold,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        const SizedBox(
          width: 280,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trusted services. Royal experience.',
                style: TextStyle(
                  color: Color(0xD6FFFFFF),
                  fontSize: 12.5,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'AM5ROYAL is India’s trusted platform connecting customers '
                'with verified professionals across multiple service categories.',
                style: TextStyle(
                  color: Color(0xD6FFFFFF),
                  fontSize: 12.5,
                  height: 1.55,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// QUICK LINKS
// ============================================================================

class _QuickLinksColumn extends StatelessWidget {
  const _QuickLinksColumn({
    required this.onSectionSelected,
  });

  final ValueChanged<NavbarSectionId> onSectionSelected;

  @override
  Widget build(BuildContext context) {
    return _FooterColumn(
      title: 'Quick Links',
      children: [
        _FooterLink(
          text: 'Home',
          onTap: () {
            onSectionSelected(NavbarSectionId.home);
          },
        ),
        _FooterLink(
          text: 'Services',
          onTap: () {
            onSectionSelected(NavbarSectionId.services);
          },
        ),
        _FooterLink(
          text: 'Customer',
          onTap: () {
            onSectionSelected(NavbarSectionId.customer);
          },
        ),
        _FooterLink(
          text: 'Freelancer',
          onTap: () {
            onSectionSelected(NavbarSectionId.freelancer);
          },
        ),
        _FooterLink(
          text: 'Careers',
          onTap: () {
            onSectionSelected(NavbarSectionId.careers);
          },
        ),
      ],
    );
  }
}

// ============================================================================
// SUPPORT
// ============================================================================

class _SupportColumn extends StatelessWidget {
  const _SupportColumn({
    required this.onSectionSelected,
  });

  final ValueChanged<NavbarSectionId> onSectionSelected;

  @override
  Widget build(BuildContext context) {
    return _FooterColumn(
      title: 'Support',
      children: [
        _FooterLink(
          text: 'How It Works',
          onTap: () {
            onSectionSelected(NavbarSectionId.howItWorks);
          },
        ),
        _FooterLink(
          text: 'FAQs',
          onTap: () {
            onSectionSelected(NavbarSectionId.faqs);
          },
        ),
        _FooterLink(
          text: 'Privacy Policy',
          onTap: () {
            onSectionSelected(NavbarSectionId.privacyPolicy);
          },
        ),
        _FooterLink(
          text: 'Terms & Conditions',
          onTap: () {
            onSectionSelected(NavbarSectionId.termsConditions);
          },
        ),
      ],
    );
  }
}

// ============================================================================
// FOR PROFESSIONALS
// ============================================================================

class _ProfessionalColumn extends StatelessWidget {
  const _ProfessionalColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'For professionals',
          style: TextStyle(
            color: AppColors.accentGold,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: VendorNavigation.openVendorLogin,
            borderRadius: BorderRadius.circular(8),
            hoverColor: const Color(0x12FFFFFF),
            child: const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 5,
                horizontal: 2,
              ),
              child: Text(
                'Register as a professional',
                style: TextStyle(
                  color: Color(0xD6FFFFFF),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// CONTACT
// ============================================================================

class _ContactColumn extends StatelessWidget {
  const _ContactColumn();

  @override
  Widget build(BuildContext context) {
    return const _FooterColumn(
      title: 'Contact Us',
      children: [
        _ContactItem(
          icon: Icons.phone_outlined,
          text: '+91 9959069035',
        ),
        _ContactItem(
          icon: Icons.email_outlined,
          text: 'support@am5royal.com',
        ),
        _ContactItem(
          icon: Icons.location_on_outlined,
          text: 'Hyderabad, Telangana, India',
        ),
      ],
    );
  }
}

// ============================================================================
// FOOTER COLUMN
// ============================================================================

class _FooterColumn extends StatelessWidget {
  const _FooterColumn({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.accentGold,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }
}

// ============================================================================
// FOOTER LINK
// ============================================================================

class _FooterLink extends StatefulWidget {
  const _FooterLink({
    required this.text,
    this.onTap,
  });

  final String text;
  final VoidCallback? onTap;

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: MouseRegion(
        cursor: widget.onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
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
          child: Text(
            widget.text,
            style: TextStyle(
              color: _hovered ? AppColors.accentGold : const Color(0xD6FFFFFF),
              fontSize: 12.5,
              fontWeight: _hovered ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CONTACT ITEM
// ============================================================================

class _ContactItem extends StatelessWidget {
  const _ContactItem({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.accentGold,
            size: 17,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xD6FFFFFF),
                fontSize: 12.5,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
