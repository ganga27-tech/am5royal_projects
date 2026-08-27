// lib/presentation/sections/freelancer/freelancer_section.dart

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class FreelancerSection extends StatelessWidget {
  const FreelancerSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final bool isDesktop = screenWidth >= 900;

    return Container(
      width: double.infinity,

      constraints: const BoxConstraints(
        minHeight: 650,
      ),

      // =====================================================================
      // AM5ROYAL GLOBAL BACKGROUND
      // =====================================================================

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

      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 70 : 24,
            vertical: 70,
          ),
          child: isDesktop
              ? const _DesktopFreelancerContent()
              : const _MobileFreelancerContent(),
        ),
      ),
    );
  }
}

// =============================================================================
// DESKTOP FREELANCER CONTENT
// =============================================================================

class _DesktopFreelancerContent extends StatelessWidget {
  const _DesktopFreelancerContent();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 1150,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ===================================================================
          // LEFT CONTENT
          // ===================================================================

          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -------------------------------------------------------------
                // SMALL LABEL
                // -------------------------------------------------------------

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x0D0B4EA2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0x220B4EA2),
                    ),
                  ),
                  child: const Text(
                    'FREELANCER OPPORTUNITIES',
                    style: TextStyle(
                      color: AppColors.royalBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // -------------------------------------------------------------
                // MAIN HEADING
                // -------------------------------------------------------------

                const Text(
                  'Your Opportunities.',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 52,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    letterSpacing: -1.2,
                  ),
                ),

                const Text(
                  'Coming Soon.',
                  style: TextStyle(
                    color: AppColors.royalBlue,
                    fontSize: 52,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    letterSpacing: -1.2,
                  ),
                ),

                const SizedBox(height: 22),

                // -------------------------------------------------------------
                // DESCRIPTION
                // -------------------------------------------------------------

                const SizedBox(
                  width: 620,
                  child: Text(
                    'We are building a dedicated space for skilled freelancers '
                    'across India to showcase their work, connect with '
                    'customers and grow their opportunities with AM5ROYAL.',
                    style: TextStyle(
                      color: Color(0xFF536985),
                      fontSize: 17,
                      height: 1.7,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // -------------------------------------------------------------
                // STATUS
                // -------------------------------------------------------------

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0x180B4EA2),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x100B1F3A),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        color: AppColors.accentGold,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Freelancer platform is under development',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 70),

          // ===================================================================
          // RIGHT PREVIEW CARD
          // ===================================================================

          const Expanded(
            flex: 4,
            child: _FreelancerPreviewCard(),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// MOBILE FREELANCER CONTENT
// =============================================================================

class _MobileFreelancerContent extends StatelessWidget {
  const _MobileFreelancerContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------------------------------------------------------------------
        // LABEL
        // ---------------------------------------------------------------------

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: const Color(0x0D0B4EA2),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0x220B4EA2),
            ),
          ),
          child: const Text(
            'FREELANCER OPPORTUNITIES',
            style: TextStyle(
              color: AppColors.royalBlue,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ),

        const SizedBox(height: 18),

        // ---------------------------------------------------------------------
        // MAIN HEADING
        // ---------------------------------------------------------------------

        const Text(
          'Your Opportunities.',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 40,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),

        const Text(
          'Coming Soon.',
          style: TextStyle(
            color: AppColors.royalBlue,
            fontSize: 40,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),

        const SizedBox(height: 18),

        // ---------------------------------------------------------------------
        // DESCRIPTION
        // ---------------------------------------------------------------------

        const Text(
          'We are building a dedicated space for skilled freelancers '
          'across India to showcase their work, connect with '
          'customers and grow their opportunities with AM5ROYAL.',
          style: TextStyle(
            color: Color(0xFF536985),
            fontSize: 15,
            height: 1.65,
          ),
        ),

        const SizedBox(height: 30),

        // ---------------------------------------------------------------------
        // PREVIEW CARD
        // ---------------------------------------------------------------------

        const _FreelancerPreviewCard(),
      ],
    );
  }
}

// =============================================================================
// FREELANCER PREVIEW CARD
// =============================================================================

class _FreelancerPreviewCard extends StatelessWidget {
  const _FreelancerPreviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 360,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),

        // ===================================================================
        // NAVY CARD — KEPT FOR CONTRAST
        // ===================================================================

        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.navy,
            AppColors.royalBlue,
          ],
        ),

        boxShadow: const [
          BoxShadow(
            color: Color(0x220B1F3A),
            blurRadius: 30,
            offset: Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // =================================================================
          // ICON
          // =================================================================

          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: const Color(0x18FFFFFF),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0x35FFFFFF),
              ),
            ),
            child: const Icon(
              Icons.work_outline_rounded,
              color: AppColors.accentGold,
              size: 38,
            ),
          ),

          const SizedBox(height: 24),

          // =================================================================
          // TITLE
          // =================================================================

          const Text(
            'Turn Your Skills Into\nOpportunities',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 14),

          // =================================================================
          // DESCRIPTION
          // =================================================================

          const Text(
            'Verified profile. Steady work.\n'
            'Direct customer connect.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xD9FFFFFF),
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 22),

          // =================================================================
          // LAUNCHING SOON
          // =================================================================

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: const Color(0x18FFFFFF),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0x35FFFFFF),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.rocket_launch_rounded,
                  color: AppColors.accentGold,
                  size: 17,
                ),
                SizedBox(width: 8),
                Text(
                  'Launching Soon',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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
