import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  static const List<_StepData> steps = [
    _StepData(
      number: '01',
      icon: Icons.search_rounded,
      title: 'Choose a Service',
      description:
      'Browse categories like electrical, plumbing, cleaning, AC repair, '
          'painting and carpentry on the AM5ROYAL app.',
    ),
    _StepData(
      number: '02',
      icon: Icons.event_available_rounded,
      title: 'Book Your Slot',
      description:
      'Pick a convenient date and time, and confirm your booking '
          'in a few taps.',
    ),
    _StepData(
      number: '03',
      icon: Icons.handshake_rounded,
      title: 'Get Matched',
      description:
      'A verified vendor near you is assigned to your service '
          'request automatically.',
    ),
    _StepData(
      number: '04',
      icon: Icons.task_alt_rounded,
      title: 'Service Delivered',
      description:
      'Your vendor completes the job. Pay securely through the app '
          'and rate your experience.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;

    return Container(
      width: double.infinity,
      color: const Color(0xFFF7F9FC),
      child: Column(
        children: [
          _PageHeader(
            isDesktop: isDesktop,
            eyebrow: 'HOW IT WORKS',
            title: 'Getting Started is Simple',
            subtitle:
            'From booking to service delivery — here is how AM5ROYAL '
                'works for you.',
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 70 : 20,
              vertical: isDesktop ? 60 : 40,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: isDesktop
                    ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < steps.length; i++) ...[
                      if (i != 0) const SizedBox(width: 20),
                      Expanded(child: _StepCard(step: steps[i])),
                    ],
                  ],
                )
                    : Column(
                  children: [
                    for (int i = 0; i < steps.length; i++) ...[
                      if (i != 0) const SizedBox(height: 16),
                      _StepCard(step: steps[i]),
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

class _StepCard extends StatelessWidget {
  const _StepCard({required this.step});

  final _StepData step;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x140B4EA2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0B1F3A),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0x0D0B4EA2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(step.icon, color: AppColors.royalBlue, size: 22),
              ),
              const Spacer(),
              Text(
                step.number,
                style: const TextStyle(
                  color: Color(0x330B4EA2),
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            step.title,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            step.description,
            style: const TextStyle(
              color: Color(0xFF536985),
              fontSize: 13,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepData {
  const _StepData({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
  });

  final String number;
  final IconData icon;
  final String title;
  final String description;
}

// Shared header widget — used only within this file.
class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.isDesktop,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final bool isDesktop;
  final String eyebrow;
  final String title;
  final String subtitle;

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
          colors: [AppColors.navy, AppColors.royalBlue],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
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
                  border: Border.all(color: const Color(0x35FFFFFF)),
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
              const SizedBox(height: 14),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
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