import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactDetailsPage extends StatelessWidget {
  const ContactDetailsPage({
    super.key,
  });

  // ===========================================================================
  // COLORS
  // ===========================================================================

  static const Color backgroundStart = Color(0xFFF9EBD1);
  static const Color backgroundEnd = Color(0xFFFCEFDD);

  static const Color navy = Color(0xFF0B2D5C);
  static const Color royalBlue = Color(0xFF0B4EA2);
  static const Color gold = Color(0xFFF5B301);

  static const Color mutedText = Color(0xFF536985);
  static const Color borderColor = Color(0xFFDCE5EF);

  static const String phoneDisplay = '+91 9959069035';
  static const String phoneDial = '+919959069035';
  static const String supportEmail = 'support@am5royal.com';

  // ===========================================================================
  // PHONE
  // ===========================================================================

  Future<void> _callSupport(BuildContext context) async {
    final Uri uri = Uri(
      scheme: 'tel',
      path: phoneDial,
    );

    try {
      final bool opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && context.mounted) {
        _showMessage(
          context,
          'Unable to open the phone application.',
        );
      }
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      _showMessage(
        context,
        'Unable to open the phone application.',
      );
    }
  }

  // ===========================================================================
  // EMAIL
  // ===========================================================================

  Future<void> _emailSupport(BuildContext context) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: const <String, String>{
        'subject': 'AM5ROYAL Support Enquiry',
      },
    );

    try {
      final bool opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && context.mounted) {
        _showMessage(
          context,
          'Unable to open the email application.',
        );
      }
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      _showMessage(
        context,
        'Unable to open the email application.',
      );
    }
  }

  // ===========================================================================
  // SNACKBAR
  // ===========================================================================

  void _showMessage(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final bool desktop = screenWidth >= 1000;
    final bool tablet = screenWidth >= 650 && screenWidth < 1000;
    final bool wideCards = screenWidth >= 820;
    final bool wideActions = screenWidth >= 600;

    final double horizontalPadding;

    if (desktop) {
      horizontalPadding = 55;
    } else if (tablet) {
      horizontalPadding = 32;
    } else {
      horizontalPadding = 18;
    }

    return Scaffold(
      backgroundColor: backgroundStart,

      // =======================================================================
      // APP BAR
      // =======================================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: navy,
        elevation: 0,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: true,
        titleSpacing: desktop ? 28 : 18,
        title: const Text(
          'Contact Us',
          style: TextStyle(
            color: navy,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      // =======================================================================
      // BODY
      // =======================================================================

      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              backgroundStart,
              backgroundEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: desktop ? 55 : 35,
            ),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1150),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // =======================================================
                      // HEADER
                      // =======================================================

                      _buildHeader(desktop: desktop),

                      const SizedBox(height: 38),

                      // =======================================================
                      // CONTACT INFORMATION
                      // =======================================================

                      if (wideCards)
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _ContactInfoCard(
                                  icon: Icons.phone_outlined,
                                  title: 'Phone',
                                  value: phoneDisplay,
                                  actionText: 'Call Now',
                                  onTap: () {
                                    _callSupport(context);
                                  },
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: _ContactInfoCard(
                                  icon: Icons.email_outlined,
                                  title: 'Email Support',
                                  value: supportEmail,
                                  actionText: 'Email Us',
                                  onTap: () {
                                    _emailSupport(context);
                                  },
                                ),
                              ),
                              const SizedBox(width: 18),
                              const Expanded(
                                child: _ContactInfoCard(
                                  icon: Icons.access_time_rounded,
                                  title: 'Working Hours',
                                  value: 'Monday - Saturday\n9:30 AM - 6:30 PM',
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Column(
                          children: [
                            _ContactInfoCard(
                              icon: Icons.phone_outlined,
                              title: 'Phone',
                              value: phoneDisplay,
                              actionText: 'Call Now',
                              onTap: () {
                                _callSupport(context);
                              },
                            ),
                            const SizedBox(height: 16),
                            _ContactInfoCard(
                              icon: Icons.email_outlined,
                              title: 'Email Support',
                              value: supportEmail,
                              actionText: 'Email Us',
                              onTap: () {
                                _emailSupport(context);
                              },
                            ),
                            const SizedBox(height: 16),
                            const _ContactInfoCard(
                              icon: Icons.access_time_rounded,
                              title: 'Working Hours',
                              value: 'Monday - Saturday\n9:30 AM - 6:30 PM',
                            ),
                          ],
                        ),

                      const SizedBox(height: 28),

                      // =======================================================
                      // SUPPORT MESSAGE
                      // =======================================================

                      _buildSupportCard(),

                      const SizedBox(height: 26),

                      // =======================================================
                      // QUICK ACTIONS
                      // =======================================================

                      if (wideActions)
                        Row(
                          children: [
                            Expanded(
                              child: _QuickActionButton(
                                icon: Icons.phone_rounded,
                                label: 'Call Support',
                                filled: true,
                                onPressed: () {
                                  _callSupport(context);
                                },
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _QuickActionButton(
                                icon: Icons.email_rounded,
                                label: 'Email Support',
                                filled: false,
                                onPressed: () {
                                  _emailSupport(context);
                                },
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: _QuickActionButton(
                                icon: Icons.phone_rounded,
                                label: 'Call Support',
                                filled: true,
                                onPressed: () {
                                  _callSupport(context);
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: _QuickActionButton(
                                icon: Icons.email_rounded,
                                label: 'Email Support',
                                filled: false,
                                onPressed: () {
                                  _emailSupport(context);
                                },
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 32),

                      // =======================================================
                      // BOTTOM TEXT
                      // =======================================================

                      const Center(
                        child: Text(
                          'AM5ROYAL • Professional Services Made Simple',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: mutedText,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Center(
                        child: Text(
                          'We are happy to assist you.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: mutedText,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _buildHeader({
    required bool desktop,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 3,
              decoration: BoxDecoration(
                color: gold,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(width: 11),
            const Text(
              'CONTACT US',
              style: TextStyle(
                color: royalBlue,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'We Are Here',
          style: TextStyle(
            color: navy,
            fontSize: desktop ? 50 : 38,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          'To Help.',
          style: TextStyle(
            color: royalBlue,
            fontSize: desktop ? 50 : 38,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 700),
          child: Text(
            'Have a question, service enquiry or business requirement? '
            'Our AM5ROYAL support team is ready to assist you.',
            style: TextStyle(
              color: mutedText,
              fontSize: 16,
              height: 1.7,
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SUPPORT CARD
  // ===========================================================================

  Widget _buildSupportCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            navy,
            royalBlue,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0x20FFFFFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: gold,
              size: 27,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need Assistance?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Contact our support team for service enquiries, '
                  'customer assistance and business requirements.',
                  style: TextStyle(
                    color: Color(0xDFFFFFFF),
                    fontSize: 13,
                    height: 1.6,
                  ),
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
// CONTACT INFORMATION CARD
// =============================================================================

class _ContactInfoCard extends StatefulWidget {
  const _ContactInfoCard({
    required this.icon,
    required this.title,
    required this.value,
    this.actionText,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final String? actionText;
  final VoidCallback? onTap;

  @override
  State<_ContactInfoCard> createState() => _ContactInfoCardState();
}

class _ContactInfoCardState extends State<_ContactInfoCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) {
        if (widget.onTap == null) {
          return;
        }

        setState(() {
          _hovered = true;
        });
      },
      onExit: (_) {
        if (widget.onTap == null) {
          return;
        }

        setState(() {
          _hovered = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(
          0,
          _hovered ? -3 : 0,
          0,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered
                ? ContactDetailsPage.royalBlue
                : ContactDetailsPage.borderColor,
            width: _hovered ? 1.3 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0x100B4EA2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.icon,
                        color: ContactDetailsPage.royalBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          color: ContactDetailsPage.navy,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  widget.value,
                  style: TextStyle(
                    color: widget.onTap != null
                        ? ContactDetailsPage.royalBlue
                        : ContactDetailsPage.mutedText,
                    fontSize: 13,
                    fontWeight: widget.onTap != null
                        ? FontWeight.w600
                        : FontWeight.w400,
                    height: 1.5,
                  ),
                ),
                if (widget.actionText != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.actionText!,
                        style: const TextStyle(
                          color: ContactDetailsPage.royalBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: ContactDetailsPage.royalBlue,
                        size: 15,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// QUICK ACTION BUTTON
// =============================================================================

class _QuickActionButton extends StatefulWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onPressed;

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
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
        duration: const Duration(milliseconds: 160),
        transform: Matrix4.translationValues(
          0,
          _hovered ? -2 : 0,
          0,
        ),
        child: widget.filled
            ? ElevatedButton.icon(
                onPressed: widget.onPressed,
                icon: Icon(
                  widget.icon,
                  size: 19,
                ),
                label: Text(
                  widget.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ContactDetailsPage.royalBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 22,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              )
            : OutlinedButton.icon(
                onPressed: widget.onPressed,
                icon: Icon(
                  widget.icon,
                  size: 19,
                ),
                label: Text(
                  widget.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ContactDetailsPage.royalBlue,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 22,
                  ),
                  side: const BorderSide(
                    color: ContactDetailsPage.royalBlue,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
      ),
    );
  }
}
