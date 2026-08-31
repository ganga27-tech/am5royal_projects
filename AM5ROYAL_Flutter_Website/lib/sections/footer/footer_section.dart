import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // ==========================================================================
  // OFFICIAL AM5ROYAL LINKS
  // ==========================================================================

  static const String facebookUrl = 'https://www.facebook.com/am5royalindia';

  static const String instagramUrl =
      'https://www.instagram.com/am5royal/?hl=en';

  static const String whatsappUrl = 'https://wa.me/919959069035';

  static const String xUrl = 'https://x.com/am5royal';

  static const String linkedinUrl =
      'https://www.linkedin.com/in/am5royalindia/';

  static const String youtubeUrl = 'https://www.youtube.com/@AM5ROYAL';

  static const String supportEmail = 'support@am5royal.com';

  static const String supportPhone = '+919959069035';

  // ==========================================================================
  // OPEN EXTERNAL URL
  // ==========================================================================

  static Future<void> openExternalUrl(String url) async {
    final Uri uri = Uri.parse(url);

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
      // Keep the website stable if the external destination
      // is unavailable.
    }
  }

  // ==========================================================================
  // SUPPORT EMAIL
  // ==========================================================================

  static Future<void> openSupportEmail() async {
    // ------------------------------------------------------------------------
    // FLUTTER WEB
    // ------------------------------------------------------------------------

    if (kIsWeb) {
      final Uri gmailComposeUri = Uri.https(
        'mail.google.com',
        '/mail/',
        <String, String>{
          'view': 'cm',
          'fs': '1',
          'to': supportEmail,
          'su': 'AM5ROYAL Support Request',
          'body': 'Hello AM5ROYAL Support Team,\n\n',
        },
      );

      try {
        final bool gmailOpened = await launchUrl(
          gmailComposeUri,
          mode: LaunchMode.externalApplication,
          webOnlyWindowName: '_blank',
        );

        if (gmailOpened) {
          return;
        }
      } catch (_) {
        // Continue to mailto fallback.
      }
    }

    // ------------------------------------------------------------------------
    // MAILTO FALLBACK
    // ------------------------------------------------------------------------

    final Uri mailUri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: const <String, String>{
        'subject': 'AM5ROYAL Support Request',
      },
    );

    try {
      await launchUrl(
        mailUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      // No configured mail application.
    }
  }

  // ==========================================================================
  // PHONE
  // ==========================================================================

  static Future<void> openPhone() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: supportPhone,
    );

    try {
      await launchUrl(
        phoneUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      // Keep website stable if phone handler is unavailable.
    }
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

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
              builder: (
                BuildContext context,
                BoxConstraints constraints,
              ) {
                final double width = constraints.maxWidth;

                // ============================================================
                // LARGE DESKTOP
                // ============================================================

                if (width >= 1200) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        flex: 2,
                        child: _BrandColumn(),
                      ),
                      const SizedBox(width: 38),
                      Expanded(
                        child: _QuickLinksColumn(
                          onSectionSelected: onSectionSelected,
                        ),
                      ),
                      const SizedBox(width: 28),
                      Expanded(
                        child: _SupportColumn(
                          onSectionSelected: onSectionSelected,
                        ),
                      ),
                      const SizedBox(width: 28),
                      const Expanded(
                        child: _ProfessionalColumn(),
                      ),
                      const SizedBox(width: 28),
                      const Expanded(
                        child: _ContactColumn(),
                      ),
                    ],
                  );
                }

                // ============================================================
                // TABLET / SMALL DESKTOP
                // ============================================================

                if (width >= 800) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(
                            flex: 2,
                            child: _BrandColumn(),
                          ),
                          const SizedBox(width: 30),
                          Expanded(
                            child: _QuickLinksColumn(
                              onSectionSelected: onSectionSelected,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _SupportColumn(
                              onSectionSelected: onSectionSelected,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _ProfessionalColumn(),
                          ),
                          SizedBox(width: 30),
                          Expanded(
                            child: _ContactColumn(),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                // ============================================================
                // MOBILE
                // ============================================================

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _BrandColumn(),
                    const SizedBox(height: 30),
                    _QuickLinksColumn(
                      onSectionSelected: onSectionSelected,
                    ),
                    const SizedBox(height: 28),
                    _SupportColumn(
                      onSectionSelected: onSectionSelected,
                    ),
                    const SizedBox(height: 28),
                    const _ProfessionalColumn(),
                    const SizedBox(height: 28),
                    const _ContactColumn(),
                  ],
                );
              },
            ),
          ),

          // ==================================================================
          // COPYRIGHT
          // ==================================================================

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
              '© 2026 MSKGRC. All Rights Reserved.',
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
// BRAND COLUMN
// ============================================================================

class _BrandColumn extends StatelessWidget {
  const _BrandColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          height: 58,
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
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const SizedBox(
          width: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trusted services. Royal experience.',
                style: TextStyle(
                  color: Color(0xD6FFFFFF),
                  fontSize: 13,
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
                  fontSize: 13,
                  height: 1.55,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const SizedBox(
          width: 300,
          child: _SocialMediaRow(),
        ),
      ],
    );
  }
}

// ============================================================================
// SOCIAL MEDIA ROW
// ============================================================================

class _SocialMediaRow extends StatelessWidget {
  const _SocialMediaRow();

  static const List<_SocialIconData> _icons = [
    _SocialIconData(
      assetPath: 'assets/images/facebook.png',
      label: 'Facebook',
      url: FooterSection.facebookUrl,
      fallbackIcon: Icons.facebook_rounded,
    ),
    _SocialIconData(
      assetPath: 'assets/images/whatsapp.png',
      label: 'WhatsApp',
      url: FooterSection.whatsappUrl,
      fallbackIcon: Icons.chat_rounded,
    ),
    _SocialIconData(
      assetPath: 'assets/images/instagram.png',
      label: 'Instagram',
      url: FooterSection.instagramUrl,
      fallbackIcon: Icons.camera_alt_rounded,
    ),
    _SocialIconData(
      assetPath: 'assets/images/x.png',
      label: 'X',
      url: FooterSection.xUrl,
      fallbackIcon: Icons.close_rounded,
    ),
    _SocialIconData(
      assetPath: 'assets/images/linkedin.png',
      label: 'LinkedIn',
      url: FooterSection.linkedinUrl,
      fallbackIcon: Icons.business_center_rounded,
    ),
    _SocialIconData(
      assetPath: 'assets/images/youtube.png',
      label: 'YouTube',
      url: FooterSection.youtubeUrl,
      fallbackIcon: Icons.play_arrow_rounded,
    ),
  ];

  static const double _spacing = 8;
  static const double _maxIconSize = 58;
  static const double _minIconSize = 34;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
        BuildContext context,
        BoxConstraints constraints,
      ) {
        final int count = _icons.length;

        final double availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : (_maxIconSize * count) + (_spacing * (count - 1));

        double iconSize = (availableWidth - (_spacing * (count - 1))) / count;

        iconSize = iconSize.clamp(
          _minIconSize,
          _maxIconSize,
        );

        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (int i = 0; i < _icons.length; i++) ...[
              if (i > 0)
                const SizedBox(
                  width: _spacing,
                ),
              _SocialIcon(
                data: _icons[i],
                size: iconSize,
              ),
            ],
          ],
        );
      },
    );
  }
}

// ============================================================================
// SOCIAL ICON DATA
// ============================================================================

class _SocialIconData {
  const _SocialIconData({
    required this.assetPath,
    required this.label,
    required this.url,
    required this.fallbackIcon,
  });

  final String assetPath;
  final String label;
  final String url;
  final IconData fallbackIcon;
}

// ============================================================================
// SOCIAL ICON
// ============================================================================

class _SocialIcon extends StatefulWidget {
  const _SocialIcon({
    required this.data,
    required this.size,
  });

  final _SocialIconData data;
  final double size;

  @override
  State<_SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<_SocialIcon> {
  bool _hovered = false;
  bool _pressed = false;

  // --------------------------------------------------------------------------
  // Visual scale
  //
  // Each PNG asset has a different amount of internal transparent
  // padding (WhatsApp and LinkedIn are near-edge-to-edge glyphs,
  // while Facebook, Instagram, X and YouTube have a lot of empty
  // canvas around a small centered mark). Because of that, the same
  // Image width does NOT produce the same visible icon size.
  //
  // These values were derived by measuring the actual rendered glyph
  // size (as a fraction of the box) for each icon and scaling every
  // icon up to match WhatsApp/LinkedIn's visual footprint, so all six
  // icons now look the same size. The outer tappable container stays
  // exactly the same size for every icon (`widget.size`) — only the
  // glyph inside it is scaled.
  // --------------------------------------------------------------------------

  double _getVisualScale(String label) {
    switch (label) {
      case 'Facebook':
        return 2.9;

      case 'Instagram':
        return 3.0;

      case 'X':
        return 2.3;

      case 'YouTube':
        return 3.15;

      case 'WhatsApp':
        return 1.0;

      case 'LinkedIn':
        return 1.0;

      default:
        return 1.0;
    }
  }

  Future<void> _openSocial() async {
    await FooterSection.openExternalUrl(
      widget.data.url,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool active = _hovered || _pressed;

    const double glyphRatio = 38 / 58;

    final double glyphSize = widget.size * glyphRatio;

    final double visualScale = _getVisualScale(widget.data.label);

    return Semantics(
      button: true,
      label: 'Open ${widget.data.label}',
      child: Tooltip(
        message: widget.data.label,
        waitDuration: const Duration(
          milliseconds: 250,
        ),
        child: MouseRegion(
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
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) {
              setState(() {
                _pressed = true;
              });
            },
            onTapCancel: () {
              setState(() {
                _pressed = false;
              });
            },
            onTapUp: (_) {
              setState(() {
                _pressed = false;
              });
            },
            onTap: _openSocial,
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: 180,
              ),
              curve: Curves.easeOut,

              // ==============================================================
              // OUTER CONTAINER — UNCHANGED
              // ==============================================================

              width: widget.size,
              height: widget.size,

              transform: Matrix4.translationValues(
                0,
                active ? -3 : 0,
                0,
              ),

              decoration: BoxDecoration(
                color:
                    active ? const Color(0x38FFFFFF) : const Color(0x20FFFFFF),
                borderRadius: BorderRadius.circular(
                  widget.size * 0.22,
                ),
                border: Border.all(
                  color: active
                      ? const Color(0x85FFFFFF)
                      : const Color(0x45FFFFFF),
                  width: 1.2,
                ),
                boxShadow: active
                    ? const [
                        BoxShadow(
                          color: Color(0x38000000),
                          blurRadius: 12,
                          offset: Offset(0, 5),
                        ),
                      ]
                    : const [
                        BoxShadow(
                          color: Color(0x18000000),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
              ),

              // ==============================================================
              // ONLY THE VISIBLE ICON IS SCALED
              // ==============================================================

              child: Center(
                child: Transform.scale(
                  scale: visualScale,
                  child: Image.asset(
                    widget.data.assetPath,
                    width: glyphSize,
                    height: glyphSize,
                    fit: BoxFit.contain,
                    errorBuilder: (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) {
                      return Icon(
                        widget.data.fallbackIcon,
                        color: Colors.white,
                        size: glyphSize * 0.9,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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
            onSectionSelected(
              NavbarSectionId.home,
            );
          },
        ),
        _FooterLink(
          text: 'Services',
          onTap: () {
            onSectionSelected(
              NavbarSectionId.services,
            );
          },
        ),
        _FooterLink(
          text: 'Customer',
          onTap: () {
            onSectionSelected(
              NavbarSectionId.customer,
            );
          },
        ),
        _FooterLink(
          text: 'Freelancer',
          onTap: () {
            onSectionSelected(
              NavbarSectionId.freelancer,
            );
          },
        ),
        _FooterLink(
          text: 'Careers',
          onTap: () {
            onSectionSelected(
              NavbarSectionId.careers,
            );
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
            onSectionSelected(
              NavbarSectionId.howItWorks,
            );
          },
        ),
        _FooterLink(
          text: 'FAQs',
          onTap: () {
            onSectionSelected(
              NavbarSectionId.faqs,
            );
          },
        ),
        _FooterLink(
          text: 'Privacy Policy',
          onTap: () {
            onSectionSelected(
              NavbarSectionId.privacyPolicy,
            );
          },
        ),
        _FooterLink(
          text: 'Terms & Conditions',
          onTap: () {
            onSectionSelected(
              NavbarSectionId.termsConditions,
            );
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
          onTap: FooterSection.openPhone,
        ),
        _ContactItem(
          icon: Icons.email_outlined,
          text: FooterSection.supportEmail,
          onTap: FooterSection.openSupportEmail,
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
        const SizedBox(height: 11),
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
    final bool clickable = widget.onTap != null;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
      child: MouseRegion(
        cursor: clickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) {
          if (!clickable) {
            return;
          }

          setState(() {
            _hovered = true;
          });
        },
        onExit: (_) {
          if (!clickable) {
            return;
          }

          setState(() {
            _hovered = false;
          });
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: Text(
            widget.text,
            style: TextStyle(
              color: _hovered ? AppColors.accentGold : const Color(0xD6FFFFFF),
              fontSize: 13,
              fontWeight: _hovered ? FontWeight.w600 : FontWeight.w400,
              decoration: _hovered ? TextDecoration.underline : null,
              decorationColor: AppColors.accentGold,
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

class _ContactItem extends StatefulWidget {
  const _ContactItem({
    required this.icon,
    required this.text,
    this.onTap,
  });

  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  @override
  State<_ContactItem> createState() => _ContactItemState();
}

class _ContactItemState extends State<_ContactItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool clickable = widget.onTap != null;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: MouseRegion(
        cursor: clickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) {
          if (!clickable) {
            return;
          }

          setState(() {
            _hovered = true;
          });
        },
        onExit: (_) {
          if (!clickable) {
            return;
          }

          setState(() {
            _hovered = false;
          });
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                widget.icon,
                color: AppColors.accentGold,
                size: 19,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: _hovered
                        ? AppColors.accentGold
                        : const Color(0xD6FFFFFF),
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: _hovered ? FontWeight.w600 : FontWeight.w400,
                    decoration: _hovered
                        ? TextDecoration.underline
                        : TextDecoration.none,
                    decorationColor: AppColors.accentGold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
