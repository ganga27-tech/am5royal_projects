import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class CareersSection extends StatelessWidget {
  const CareersSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final bool isDesktop = screenWidth >= 900;

    return Container(
      width: double.infinity,

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

      child: Column(
        children: [
          _CareersHeader(
            isDesktop: isDesktop,
          ),
          _OpenPositions(
            isDesktop: isDesktop,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CAREERS HEADER
// =============================================================================

class _CareersHeader extends StatelessWidget {
  const _CareersHeader({
    required this.isDesktop,
  });

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 70 : 24,
        vertical: isDesktop ? 70 : 50,
      ),

      // =====================================================================
      // NAVY HEADER
      // =====================================================================

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
              // ===============================================================
              // LABEL
              // ===============================================================

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
                  'CAREERS AT AM5ROYAL',
                  style: TextStyle(
                    color: AppColors.accentGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ===============================================================
              // TITLE
              // ===============================================================

              Text(
                'Join Our Team',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isDesktop ? 44 : 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 14),

              // ===============================================================
              // DESCRIPTION
              // ===============================================================

              const Text(
                'We are hiring across engineering, marketing and operations '
                'teams, pan-India.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xD9FFFFFF),
                  fontSize: 15,
                  height: 1.6,
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
// OPEN POSITIONS
// =============================================================================

class _OpenPositions extends StatelessWidget {
  const _OpenPositions({
    required this.isDesktop,
  });

  final bool isDesktop;

  static const List<_JobData> jobs = [
    _JobData(
      icon: Icons.code_rounded,
      category: 'Tech',
      title: 'Backend Developer',
      type: 'Full-Time',
      location: 'Pan India (Remote / Hybrid)',
    ),
    _JobData(
      icon: Icons.phone_android_rounded,
      category: 'Tech',
      title: 'Frontend Developer',
      type: 'Full-Time',
      location: 'Pan India (Remote / Hybrid)',
    ),
    _JobData(
      icon: Icons.campaign_rounded,
      category: 'Marketing',
      title: 'Digital Marketing Executive',
      type: 'Full-Time',
      location: 'Pan India (Remote / Hybrid)',
    ),
    _JobData(
      icon: Icons.verified_user_rounded,
      category: 'Operations',
      title: 'Vendor Verification Executive',
      type: 'Full-Time · Multiple Languages',
      location: 'Pan India',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 70 : 20,
        vertical: isDesktop ? 60 : 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===============================================================
              // SECTION TITLE
              // ===============================================================

              const Text(
                'Open Positions',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Currently hiring for the following roles across India.',
                style: TextStyle(
                  color: Color(0xFF536985),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 28),

              // ===============================================================
              // DESKTOP GRID
              // ===============================================================

              if (isDesktop)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: jobs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    mainAxisExtent: 145,
                  ),
                  itemBuilder: (context, index) {
                    return _JobCard(
                      job: jobs[index],
                    );
                  },
                )

              // ===============================================================
              // MOBILE LIST
              // ===============================================================

              else
                Column(
                  children: [
                    for (int index = 0; index < jobs.length; index++) ...[
                      _JobCard(
                        job: jobs[index],
                      ),
                      if (index < jobs.length - 1)
                        const SizedBox(
                          height: 14,
                        ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// JOB CARD
// =============================================================================

class _JobCard extends StatefulWidget {
  const _JobCard({
    required this.job,
  });

  final _JobData job;

  @override
  State<_JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<_JobCard> {
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
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(
          0,
          _hovered ? -3 : 0,
          0,
        ),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered ? const Color(0xFFB8CDE3) : const Color(0x140B4EA2),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x0F0B1F3A),
              blurRadius: _hovered ? 22 : 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ===============================================================
            // JOB ICON
            // ===============================================================

            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0x0D0B4EA2),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                widget.job.icon,
                color: AppColors.royalBlue,
                size: 24,
              ),
            ),

            const SizedBox(width: 15),

            // ===============================================================
            // JOB DETAILS
            // ===============================================================

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CategoryBadge(
                    category: widget.job.category,
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  Text(
                    widget.job.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    '${widget.job.type} • '
                    '${widget.job.location}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF65758B),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // ===============================================================
            // ARROW
            // ===============================================================

            AnimatedContainer(
              duration: const Duration(
                milliseconds: 180,
              ),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _hovered
                    ? const Color(
                        0x120B4EA2,
                      )
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.royalBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// CATEGORY BADGE
// =============================================================================

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({
    required this.category,
  });

  final String category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0x0D0B4EA2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category.toUpperCase(),
        style: const TextStyle(
          color: AppColors.royalBlue,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// =============================================================================
// JOB DATA
// =============================================================================

class _JobData {
  const _JobData({
    required this.icon,
    required this.category,
    required this.title,
    required this.type,
    required this.location,
  });

  final IconData icon;
  final String category;
  final String title;
  final String type;
  final String location;
}
