import 'package:flutter/material.dart';

class WhyChooseSection extends StatelessWidget {
  const WhyChooseSection({super.key});

  static const List<_WhyChooseItem> items = [
    _WhyChooseItem(
      icon: Icons.verified_user_rounded,
      title: 'Verified\nProfessionals',
      description: 'All professionals are\nverified and trusted.',
    ),
    _WhyChooseItem(
      icon: Icons.timer_rounded,
      title: 'Fast & Reliable\nService',
      description: 'Quick response and\non-time service.',
    ),
    _WhyChooseItem(
      icon: Icons.lock_rounded,
      title: 'Secure\nPayments',
      description: '100% secure\nonline payments.',
    ),
    _WhyChooseItem(
      icon: Icons.local_offer_rounded,
      title: 'Affordable\nPricing',
      description: 'Best quality service\nat affordable price.',
    ),
    _WhyChooseItem(
      icon: Icons.headset_mic_rounded,
      title: '24/7 Customer\nSupport',
      description: 'We are here to help\nyou anytime.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        24,
        22,
        24,
        28,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1050,
          ),
          child: Column(
            children: [
              const Text(
                'Why Choose AM5ROYAL?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF0B2D5C),
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              Container(
                width: 32,
                height: 2,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B4EA2),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 850) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: items
                          .map(
                            (item) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: _WhyChooseCard(
                                  item: item,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  }

                  return Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 25,
                    runSpacing: 25,
                    children: items
                        .map(
                          (item) => SizedBox(
                            width: 145,
                            child: _WhyChooseCard(
                              item: item,
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WhyChooseCard extends StatelessWidget {
  const _WhyChooseCard({
    required this.item,
  });

  final _WhyChooseItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F6FF),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFD9E8FA),
            ),
          ),
          child: Icon(
            item.icon,
            color: const Color(0xFF0B4EA2),
            size: 27,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          item.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF102A43),
            fontSize: 12,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          item.description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF687B91),
            fontSize: 9.5,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _WhyChooseItem {
  const _WhyChooseItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
