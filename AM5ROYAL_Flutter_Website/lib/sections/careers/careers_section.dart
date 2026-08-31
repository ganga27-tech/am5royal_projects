import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../features/careers/data/careers_api.dart';
import '../../features/careers/pages/career_application_page.dart';

class CareersSection extends StatefulWidget {
  const CareersSection({
    super.key,
  });

  @override
  State<CareersSection> createState() => _CareersSectionState();
}

class _CareersSectionState extends State<CareersSection> {
  final CareersApi _api = CareersApi();
  List<JobOpening> _openings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOpenings();
  }

  Future<void> _loadOpenings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final openings = await _api.getOpenings();
      if (!mounted) return;
      setState(() {
        _openings = openings;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _openApplication(JobOpening opening) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CareerApplicationPage(opening: opening),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isDesktop = screenWidth >= 900;

    return Container(
      width: double.infinity,
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
          _CareersHeader(isDesktop: isDesktop),
          _OpenPositions(
            isDesktop: isDesktop,
            openings: _openings,
            isLoading: _isLoading,
            error: _error,
            onRetry: _loadOpenings,
            onApply: _openApplication,
          ),
        ],
      ),
    );
  }
}

class _CareersHeader extends StatelessWidget {
  const _CareersHeader({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0x18FFFFFF),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0x35FFFFFF)),
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

class _OpenPositions extends StatelessWidget {
  const _OpenPositions({
    required this.isDesktop,
    required this.openings,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.onApply,
  });

  final bool isDesktop;
  final List<JobOpening> openings;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final ValueChanged<JobOpening> onApply;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 70 : 20,
        vertical: isDesktop ? 60 : 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: AppColors.royalBlue),
                  ),
                )
              else if (error != null)
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Could not load openings.',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
                    ],
                  ),
                )
              else if (openings.isEmpty)
                const Center(
                  child: Text(
                    'No open positions at the moment. Check back soon!',
                    style: TextStyle(color: Color(0xFF536985)),
                  ),
                )
              else if (isDesktop)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: openings.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    mainAxisExtent: 188,
                  ),
                  itemBuilder: (context, index) {
                    return _JobCard(
                      opening: openings[index],
                      onApply: () => onApply(openings[index]),
                    );
                  },
                )
              else
                Column(
                  children: [
                    for (int index = 0; index < openings.length; index++) ...[
                      _JobCard(
                        opening: openings[index],
                        onApply: () => onApply(openings[index]),
                      ),
                      if (index < openings.length - 1) const SizedBox(height: 14),
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

class _JobCard extends StatefulWidget {
  const _JobCard({
    required this.opening,
    required this.onApply,
  });

  final JobOpening opening;
  final VoidCallback onApply;

  @override
  State<_JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<_JobCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final opening = widget.opening;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0x0D0B4EA2),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    categoryIcon(opening.category),
                    color: AppColors.royalBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CategoryBadge(category: opening.category),
                      const SizedBox(height: 7),
                      Text(
                        opening.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${opening.employmentType} • ${opening.location}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF65758B),
                          fontSize: 12.5,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _hovered ? const Color(0x120B4EA2) : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.royalBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: widget.onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Apply Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
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
