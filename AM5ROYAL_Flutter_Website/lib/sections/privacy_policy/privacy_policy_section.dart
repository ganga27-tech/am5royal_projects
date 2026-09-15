import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class PrivacyPolicySection extends StatelessWidget {
  const PrivacyPolicySection({super.key});

  static const List<_PolicyBlock> blocks = [
    _PolicyBlock(
      title: 'Information We Collect',
      body: 'We collect information you provide directly — such as your name, '
          'phone number, email, address and payment details — as well as '
          'usage data like booking history and app activity.',
    ),
    _PolicyBlock(
      title: 'How We Use Your Information',
      body: 'Your information is used to process bookings, connect you with '
          'verified vendors, improve our services, and communicate '
          'important updates related to your account.',
    ),
    _PolicyBlock(
      title: 'Sharing of Information',
      body: 'We share only the necessary details with vendors and '
          'freelancers to fulfil your service request. We do not sell your '
          'personal information to third parties.',
    ),
    _PolicyBlock(
      title: 'Data Security',
      body: 'AM5ROYAL uses industry-standard security measures to protect '
          'your data against unauthorized access, alteration or '
          'disclosure.',
    ),
    _PolicyBlock(
      title: 'Your Rights',
      body: 'You may access, update or request deletion of your personal '
          'information at any time through the app or by contacting our '
          'support team.',
    ),
    _PolicyBlock(
      title: 'Changes to This Policy',
      body: 'We may update this policy periodically. Continued use of the '
          'app after changes indicates your acceptance of the revised '
          'policy.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _LegalPage(
      eyebrow: 'PRIVACY POLICY',
      title: 'Your Privacy Matters',
      blocks: blocks,
    );
  }
}

// =============================================================================
// SHARED LEGAL PAGE LAYOUT (private to this file)
// =============================================================================

class _LegalPage extends StatelessWidget {
  const _LegalPage({
    required this.eyebrow,
    required this.title,
    required this.blocks,
  });

  final String eyebrow;
  final String title;
  final List<_PolicyBlock> blocks;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;

    return Container(
      width: double.infinity,

      // =========================================================================
      // WEBSITE BACKGROUND COLOR
      // =========================================================================

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

      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 70 : 24,
              vertical: isDesktop ? 70 : 50,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.navy,
                  AppColors.royalBlue,
                ],
              ),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 700,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x18FFFFFF),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color(0x35FFFFFF),
                        ),
                      ),
                      child: Text(
                        eyebrow,
                        style: const TextStyle(
                          color: AppColors.accentGold,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isDesktop ? 42 : 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 70 : 20,
              vertical: isDesktop ? 60 : 40,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 800,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < blocks.length; i++) ...[
                      _PolicySection(
                        block: blocks[i],
                      ),
                      if (i != blocks.length - 1) const SizedBox(height: 18),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// POLICY SECTION
// =============================================================================

class _PolicySection extends StatelessWidget {
  const _PolicySection({
    required this.block,
  });

  final _PolicyBlock block;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0x140B4EA2),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0B1F3A),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: const BoxDecoration(
                color: AppColors.accentGold,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      block.title,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      block.body,
                      style: const TextStyle(
                        color: Color(0xFF536985),
                        fontSize: 13.5,
                        height: 1.65,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// POLICY DATA
// =============================================================================

class _PolicyBlock {
  const _PolicyBlock({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}
