import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class FaqsSection extends StatelessWidget {
  const FaqsSection({super.key});

  static const List<_FaqData> faqs = [
    _FaqData(
      question: 'How do I book a service on AM5ROYAL?',
      answer:
      'Open the AM5ROYAL app, choose a service category, select a slot '
          'and confirm your booking. A verified vendor will be assigned '
          'to you automatically.',
    ),
    _FaqData(
      question: 'Are the vendors and freelancers verified?',
      answer:
      'Yes. Every vendor and freelancer on AM5ROYAL goes through an '
          'identity, address and document verification process before '
          'being approved on the platform.',
    ),
    _FaqData(
      question: 'What payment methods are supported?',
      answer:
      'AM5ROYAL supports UPI, credit/debit cards and net banking '
          'through a secure in-app payment gateway.',
    ),
    _FaqData(
      question: 'Can I cancel or reschedule a booking?',
      answer:
      'Yes, bookings can be cancelled or rescheduled from the app '
          'before the vendor is dispatched, subject to our cancellation '
          'policy.',
    ),
    _FaqData(
      question: 'How do I become a vendor or freelancer?',
      answer:
      'Tap on "Become a Vendor" or "Freelancer" from the app or '
          'website, complete your profile and submit the required '
          'verification documents.',
    ),
    _FaqData(
      question: 'Which cities does AM5ROYAL currently operate in?',
      answer:
      'AM5ROYAL is expanding across India city by city. Check the app '
          'for live service availability in your area.',
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
            eyebrow: 'FAQS',
            title: 'Frequently Asked Questions',
            subtitle: 'Everything you need to know about using AM5ROYAL.',
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 70 : 20,
              vertical: isDesktop ? 60 : 40,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [for (final faq in faqs) _FaqTile(faq: faq)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.faq});

  final _FaqData faq;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x140B4EA2)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 4,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          iconColor: AppColors.royalBlue,
          collapsedIconColor: AppColors.royalBlue,
          title: Text(
            faq.question,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                faq.answer,
                style: const TextStyle(
                  color: Color(0xFF536985),
                  fontSize: 13.5,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqData {
  const _FaqData({required this.question, required this.answer});

  final String question;
  final String answer;
}

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