import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class TermsConditionsSection extends StatelessWidget {
  const TermsConditionsSection({super.key});

  static const List<_TermBlock> blocks = [
    _TermBlock(
      title: 'Acceptance of Terms',
      body: 'By accessing or using the AM5ROYAL app and website, you agree '
          'to be bound by these Terms & Conditions and our Privacy Policy.',
    ),
    _TermBlock(
      title: 'Use of Services',
      body: 'AM5ROYAL connects customers with independent vendors and '
          'freelancers for home services. We do not directly perform the '
          'services listed on the platform.',
    ),
    _TermBlock(
      title: 'Vendor & Freelancer Responsibilities',
      body: 'Vendors and freelancers are independently responsible for the '
          'quality, safety and timeliness of the services they deliver '
          'through AM5ROYAL.',
    ),
    _TermBlock(
      title: 'Payments & Cancellations',
      body: 'All payments are processed securely through the app. '
          'Cancellation and refund eligibility are governed by our '
          'cancellation policy displayed at the time of booking.',
    ),
    _TermBlock(
      title: 'User Conduct',
      body: 'Users agree not to misuse the platform, provide false '
          'information, or engage in any activity that compromises the '
          'safety of other users, vendors or freelancers.',
    ),
    _TermBlock(
      title: 'Limitation of Liability',
      body: 'AM5ROYAL is not liable for any indirect, incidental or '
          'consequential damages arising from the use of services booked '
          'through the platform.',
    ),
    _TermBlock(
      title: 'Governing Law',
      body: 'These Terms are governed by the laws of India. Any disputes '
          'will be subject to the exclusive jurisdiction of the courts in '
          'Hyderabad, Telangana.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;

    return Container(
      width: double.infinity,

      // ======================================================================
      // WEBSITE BACKGROUND COLOR
      // ======================================================================

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
                      child: const Text(
                        'TERMS & CONDITIONS',
                        style: TextStyle(
                          color: AppColors.accentGold,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Terms & Conditions',
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
                      _TermSection(
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
// TERM SECTION
// =============================================================================

class _TermSection extends StatelessWidget {
  const _TermSection({
    required this.block,
  });

  final _TermBlock block;

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
// TERM DATA
// =============================================================================

class _TermBlock {
  const _TermBlock({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}
