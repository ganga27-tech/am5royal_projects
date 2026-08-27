import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';

class OurStoryScreen extends StatelessWidget {
  const OurStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Our Story',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 1. Hero Section
            _buildHero(context, isDark, isMobile),

            // 2. What is AM5ROYAL?
            _buildWhatIsAm5(context, isDark, isMobile),

            // 2b. Brand Philosophy & Motto
            _buildBrandPhilosophy(context, isDark, isMobile),

            // 3. The Digital Frontier (Our Journey / Roadmap)
            _buildDigitalFrontier(context, isDark, isMobile),

            // 4. Empowering Our Partners
            _buildEmpoweringPartners(context, isDark, isMobile),

            // 5. Royal Services
            _buildRoyalServices(context, isDark, isMobile),

            // Upcoming Services
            _buildUpcomingServices(context, isDark, isMobile),

            // 6. Founders
            _buildFounders(context, isDark, isMobile),

            // 7. The Minds Behind the Throne (Core Team)
            _buildMindsBehindThrone(context, isDark, isMobile),

            // 8. Footer
            _buildFooter(context, isDark, isMobile),
          ],
        ),
      ),
    );
  }

  // --- 1. HERO SECTION ---
  Widget _buildHero(BuildContext context, bool isDark, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: isMobile ? 60 : 100,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        image: DecorationImage(
          image: const NetworkImage(
              'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=1200'),
          fit: BoxFit.cover,
          opacity: isDark ? 0.05 : 0.02,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Lead a Royal Life',
            style: GoogleFonts.outfit(
              fontSize: isMobile ? 36 : 56,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimary,
              letterSpacing: -1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Text(
              'Founded on 7th November 2025 by visionary founders Mr. Shravan Kumar M. (AM5 Royal) and Mr. Ramchander G. to create a platform that replaces uncertainty with trust, quality, and a truly royal experience.',
              style: GoogleFonts.outfit(
                fontSize: isMobile ? 15 : 18,
                height: 1.6,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // const SizedBox(height: 32),
          // ElevatedButton(
          //   onPressed: () {},
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: AppColors.primary,
          //     foregroundColor: Colors.white,
          //     padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(100),
          //     ),
          //     elevation: 0,
          //   ),
          //   child: Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Text(
          //         'Learn More',
          //         style: GoogleFonts.outfit(
          //           fontWeight: FontWeight.bold,
          //           fontSize: 15,
          //         ),
          //       ),
          //       const SizedBox(width: 8),
          //       const Icon(Icons.arrow_forward_rounded, size: 18),
          //     ],
          //   ),
          // ),
        ],
      ) as Widget, // Safe cast
    );
  }

  // --- 2. WHAT IS AM5ROYAL? ---
  Widget _buildWhatIsAm5(BuildContext context, bool isDark, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: 80,
      ),
      child: Column(
        children: [
          Text(
            'What is AM5ROYAL?',
            style: GoogleFonts.outfit(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'BUILDING ALLIANCES. EMPOWERING BUSINESSES. DELIVERING ROYAL EXPERIENCES.',
            style: GoogleFonts.outfit(
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = isMobile
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 60) / 4;

              final cards = [
                _buildLetterCard(
                  context,
                  isDark,
                  'A',
                  'A Strong Network',
                  'Fostering pathbreaking collaboration and networks that drive modern service ecosystems.',
                  null,
                ),
                _buildLetterCard(
                  context,
                  isDark,
                  'M',
                  'Multiple Business',
                  'A multidimensional system engineered to deliver structured business and financial growth.',
                  null,
                ),
                _buildLetterCard(
                  context,
                  isDark,
                  '5',
                  'Five Pillars',
                  'Royalty Life\nAssured Services\nTrusted Platform\nSeamless Quality\nConstant Innovation',
                  const [
                    'Royalty Life',
                    'Assured Services',
                    'Trusted Platform',
                    'Business Growth',
                    'Financial Growth',
                  ],
                ),
                _buildLetterCard(
                  context,
                  isDark,
                  'R',
                  'ROYAL',
                  'Everyone should experience the confidence and convenience of a truly royalty life.',
                  null,
                ),
              ];

              if (isMobile) {
                return Column(
                  children: cards
                      .map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: c,
                          ))
                      .toList(),
                );
              } else {
                return IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: cards
                        .map((c) => SizedBox(width: cardWidth, child: c))
                        .toList(),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLetterCard(
    BuildContext context,
    bool isDark,
    String letter,
    String title,
    String description,
    List<String>? bulletPoints,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : AppColors.border.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              letter,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                if (bulletPoints == null)
                  Text(
                    description,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      height: 1.6,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: bulletPoints
                        .map((bp) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: AppColors.accent, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      bp,
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandPhilosophy(
      BuildContext context, bool isDark, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: 60,
      ),
      color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F5F9),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFD4A33A).withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Our Brand Philosophy',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD4A33A),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'AM5ROYAL is a proudly Indian brand founded with the vision of connecting businesses and customers through trust, technology, and innovation. We are committed to empowering vendors, simplifying everyday services, and building long-term relationships that benefit everyone in our ecosystem through our all-in-one platform.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  height: 1.6,
                  color: isDark ? Colors.white70 : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 80,
                height: 2,
                color: const Color(0xFFD4A33A).withValues(alpha: 0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'OUR MOTTO',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: const Color(0xFFD4A33A),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '"Building Alliances. Empowering Businesses. Delivering Royal Experiences."',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 3. THE DIGITAL FRONTIER ---
  Widget _buildDigitalFrontier(
      BuildContext context, bool isDark, bool isMobile) {
    return Container(
      width: double.infinity,
      color: isDark ? AppColors.darkSurface : Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: 80,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The Digital Frontier',
                style: GoogleFonts.outfit(
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Led by Mr. Shravan Kumar M. and Mr. Ramchander G., our visionaries coordinate with development, marketing, and operations to design products addressing real-world needs securely and intelligently.',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  height: 1.6,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Internal Stats
              Row(
                children: [
                  _buildFrontierStat(
                      context, '12+ Years', 'Banking/Finance Exp'),
                  const SizedBox(width: 24),
                  _buildFrontierStat(
                      context, 'Global Tech', 'Engineering project manager'),
                ],
              ),
              const SizedBox(height: 32),

              // Future Roadmap
              Text(
                'Future Roadmap',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildRoadmapItem(context, 'Advanced Analytics',
                  'Tracking growth and performance parameters.'),
              _buildRoadmapItem(context, 'Intelligent Automation',
                  'Creating smart, secure recommendations.'),
            ],
          );

          // Beautiful tech graphic on the right
          final visual = Stack(
            children: [
              Container(
                height: isMobile ? 300 : 450,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [Colors.blue[900]!, Colors.blue[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  image: const DecorationImage(
                    image: NetworkImage(
                        'https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=800'),
                    fit: BoxFit.cover,
                    opacity: 0.15,
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.auto_awesome_mosaic_rounded,
                  size: 80,
                  color: Colors.white24,
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.accent, size: 24),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '2025',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Shared Vision Unified',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          );

          if (isMobile) {
            return Column(
              children: [
                visual,
                const SizedBox(height: 40),
                content,
              ],
            );
          } else {
            return Row(
              children: [
                Expanded(child: content),
                const SizedBox(width: 60),
                Expanded(child: visual),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildFrontierStat(BuildContext context, String value, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            color:
                isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRoadmapItem(BuildContext context, String title, String desc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.offline_bolt_outlined,
                color: AppColors.accent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  desc,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- 4. EMPOWERING OUR PARTNERS (Benefits) ---
  Widget _buildEmpoweringPartners(
      BuildContext context, bool isDark, bool isMobile) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF071430), // Solid Deep Navy Blue as in mockup
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: 80,
      ),
      child: Column(
        children: [
          Text(
            'Empowering Our Partners',
            style: GoogleFonts.outfit(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Why thousands of service professionals choose AM5ROYAL.',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = isMobile
                  ? 1
                  : (constraints.maxWidth > 1200
                      ? 4
                      : (constraints.maxWidth > 800 ? 3 : 2));
              final gap = 20.0;
              final width =
                  (constraints.maxWidth - (gap * (crossAxisCount - 1))) /
                      crossAxisCount;

              final benefits = [
                _buildBenefitItem(
                    context,
                    'Become Your Own Boss',
                    'Work independently and manage your business on your own terms.',
                    Icons.person_add_alt_1_rounded),
                _buildBenefitItem(
                    context,
                    'Get Genuine Customer Leads',
                    'Receive verified customer enquiries from people actively searching for your services.',
                    Icons.verified_rounded),
                _buildBenefitItem(
                    context,
                    'Company-Assisted Leads',
                    'Get exclusive company-generated leads to maximize your business opportunities.',
                    Icons.business_center_rounded),
                _buildBenefitItem(
                    context,
                    'Free Leads',
                    'Enjoy complimentary leads based on your subscription plan and special promotional offers.',
                    Icons.card_giftcard_rounded),
                _buildBenefitItem(
                    context,
                    'Lead Boost Opportunities',
                    'Increase your visibility and receive more quality leads through premium promotions.',
                    Icons.bolt_rounded),
                _buildBenefitItem(
                    context,
                    'No Fixed Working Hours',
                    'Accept service requests according to your availability and convenience.',
                    Icons.access_time_rounded),
                _buildBenefitItem(
                    context,
                    'Set Your Own Pricing',
                    'Quote competitive prices that match your expertise and business requirements.',
                    Icons.monetization_on_rounded),
                _buildBenefitItem(
                    context,
                    'Verified Vendor Profile',
                    'Build customer confidence with a trusted and verified business profile.',
                    Icons.badge_rounded),
                _buildBenefitItem(
                    context,
                    'Increase Your Income',
                    'Receive more bookings, serve more customers, and grow your monthly earnings.',
                    Icons.trending_up_rounded),
                _buildBenefitItem(
                    context,
                    'Multiple Service Categories',
                    'Register under one or multiple service categories based on your skills and expertise.',
                    Icons.category_rounded),
                _buildBenefitItem(
                    context,
                    'Easy Lead & Booking Management',
                    'Manage customer enquiries, bookings, and service requests through the AM5ROYAL platform.',
                    Icons.assignment_rounded),
                _buildBenefitItem(
                    context,
                    'Sell Your Service-Related Products',
                    'Showcase and sell eligible service-related products directly to customers.',
                    Icons.shopping_bag_rounded),
                _buildBenefitItem(
                    context,
                    'Rewards & Gift Programs',
                    'Earn reward points, exciting gifts, and exclusive incentives based on your performance.',
                    Icons.card_giftcard_rounded),
                _buildBenefitItem(
                    context,
                    'Business Promotion',
                    'Increase your online visibility and strengthen your brand presence across your service area.',
                    Icons.campaign_rounded),
                _buildBenefitItem(
                    context,
                    'Dedicated Vendor Support',
                    'Receive prompt assistance from the AM5ROYAL support team whenever you need help.',
                    Icons.support_agent_rounded),
                _buildBenefitItem(
                    context,
                    'Business Growth Opportunities',
                    'Expand your customer base and grow your business with AM5ROYAL across India.',
                    Icons.domain_rounded),
              ];

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: benefits
                    .map((b) => SizedBox(width: width, child: b))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(
      BuildContext context, String title, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accent, size: 28),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // --- 5. ROYAL SERVICES ---
  Widget _buildRoyalServices(BuildContext context, bool isDark, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: 80,
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Royal Services',
              style: GoogleFonts.outfit(
                fontSize: isMobile ? 24 : 32,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount =
                  isMobile ? 2 : (constraints.maxWidth > 900 ? 5 : 3);
              final gap = 16.0;
              final width =
                  (constraints.maxWidth - (gap * (crossAxisCount - 1))) /
                      crossAxisCount;

              final services = [
                _buildServiceCard(context, 'Plumbing',
                    'https://images.unsplash.com/photo-1581244277943-fe4a9c777189?q=80&w=300'),
                _buildServiceCard(context, 'Cleaning',
                    'https://images.unsplash.com/photo-1581578731548-c64695cc6952?q=80&w=300'),
                _buildServiceCard(context, '2/4 Wheeler',
                    'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?q=80&w=300'),
                _buildServiceCard(context, 'Pet Care',
                    'https://images.unsplash.com/photo-1516734212186-a967f81ad0d7?q=80&w=300'),
                _buildServiceCard(context, 'Beauty & Wellness',
                    'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?q=80&w=300'),
                _buildServiceCard(context, 'AC Repair',
                    'https://images.unsplash.com/photo-1563720223185-11003d516935?q=80&w=300'),
                _buildServiceCard(context, 'Driver',
                    'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?q=80&w=300'),
                _buildServiceCard(context, 'Pest Control',
                    'https://images.unsplash.com/photo-1587300003388-59208cc962cb?q=80&w=300'),
                _buildServiceCard(context, 'Smart Appliance',
                    'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?q=80&w=300'),
                _buildServiceCard(context, 'Modular Works',
                    'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?q=80&w=300'),
              ];

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: services
                    .map((s) => SizedBox(width: width, child: s))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
      BuildContext context, String title, String imageUrl) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      alignment: Alignment.bottomLeft,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(16)),
          gradient: const LinearGradient(
            colors: [Colors.black87, Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // --- 6. FOUNDERS ---
  Widget _buildFounders(BuildContext context, bool isDark, bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0A1628), const Color(0xFF071430)]
              : [const Color(0xFFF8F6FF), const Color(0xFFEEF2FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: 80,
      ),
      child: Column(
        children: [
          Text(
            'Our Visionary Founders',
            style: GoogleFonts.outfit(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Two leaders. One vision. Built on trust and excellence.',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 56),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              final founderCards = [
                _buildFounderCard(
                  context,
                  isDark,
                  initials: 'SKM',
                  name: 'Mr. Shravan Kumar M.',
                  title: 'Founder & CEO — AM5 Royal',
                  tagline: '"Visionary architect of the AM5 Alliance"',
                  bio:
                      'With over 12 years of expertise in banking and finance, Shravan built the backbone of AM5ROYAL\'s financial ecosystem. His deep understanding of market dynamics and service alliances drives the company\'s strategic growth across India.',
                  highlights: [
                    'Banking & Finance Expert — 12+ Years',
                    'Architect of the AM5 Alliance Model',
                    'Strategic Vision & Market Expansion',
                  ],
                  color: AppColors.primary,
                ),
                _buildFounderCard(
                  context,
                  isDark,
                  initials: 'RG',
                  name: 'Mr. Ramchander G.',
                  title: 'Founder & Chairman — AM5 Royal',
                  tagline: '"Engineering trust into every transaction"',
                  bio:
                      'A seasoned technologist and Engineering Project Manager with extensive experience in Saudi Arabia, Ramchander leads the technology, engineering, and operations vision of AM5ROYAL. He ensures that every platform interaction is secure, seamless, and truly royal.',
                  highlights: [
                    'Professional – Engineering Project Manager, Saudi Arabia',
                    'Product & Platform Strategy',
                    'Technology & Security Leadership',
                  ],
                  color: const Color(0xFFD4A017),
                ),
              ];

              if (!isWide || isMobile) {
                return Column(
                  children: founderCards
                      .map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: c,
                          ))
                      .toList(),
                );
              } else {
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: founderCards[0]),
                      const SizedBox(width: 24),
                      Expanded(child: founderCards[1]),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFounderCard(
    BuildContext context,
    bool isDark, {
    required String initials,
    required String name,
    required String title,
    required String tagline,
    required String bio,
    required List<String> highlights,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: color,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            tagline,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            bio,
            style: GoogleFonts.outfit(
              fontSize: 14,
              height: 1.7,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            height: 1,
            color: color.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 20),
          ...highlights.map(
            (h) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      h,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 7. THE MINDS BEHIND THE THRONE ---
  Widget _buildMindsBehindThrone(
      BuildContext context, bool isDark, bool isMobile) {
    return Container(
      width: double.infinity,
      color: isDark ? AppColors.darkSurface : Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: 80,
      ),
      child: Column(
        children: [
          Text(
            'The Minds Behind the Throne',
            style: GoogleFonts.outfit(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Driving excellence across design, marketing, and operations.',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = isMobile
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 40) / 3;

              final cards = [
                _buildTeamCard(
                  context,
                  isDark,
                  'Application Development',
                  ' Vishal K.',
                  'Transforming concepts into high-performance digital architectures.',
                  Icons.developer_board_rounded,
                ),
                _buildTeamCard(
                  context,
                  isDark,
                  'Strategy & Marketing',
                  'Sainath B.',
                  'Formulating dynamic market presence and partner onboarding strategy.',
                  Icons.campaign_rounded,
                ),
                _buildTeamCard(
                  context,
                  isDark,
                  'Operations & Management',
                  'Vijay Kumar V.',
                  'Ensuring prompt verification and absolute quality control checks.',
                  Icons.insights_rounded,
                ),
              ];

              if (isMobile) {
                return Column(
                  children: cards
                      .map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: c,
                          ))
                      .toList(),
                );
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: cards
                      .map((c) => SizedBox(width: cardWidth, child: c))
                      .toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(
    BuildContext context,
    bool isDark,
    String dept,
    String names,
    String desc,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 24),
          Text(
            dept,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            names,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // --- 7. FOOTER ---
  Widget _buildFooter(BuildContext context, bool isDark, bool isMobile) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF071430),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
      child: Column(
        children: [
          Text(
            'AM5ROYAL',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Building Alliances. Empowering Businesses. Delivering Royal Experiences.',
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          const Divider(color: Colors.white10),
          const SizedBox(height: 20),
          Text(
            '© 2026 AM5ROYAL. All rights reserved. Leading partners to a royal life.',
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: Colors.white38,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingServices(
      BuildContext context, bool isDark, bool isMobile) {
    return Container(
      width: double.infinity,
      color: isDark ? AppColors.darkSurface : Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: 80,
      ),
      child: Column(
        children: [
          Text(
            'Upcoming Services',
            style: GoogleFonts.outfit(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AM5ROYAL is continuously expanding its ecosystem to serve a wider range of customer and business needs. The following service categories are planned for upcoming releases:',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount =
                  isMobile ? 2 : (constraints.maxWidth > 900 ? 4 : 3);
              final gap = 20.0;
              final width =
                  (constraints.maxWidth - (gap * (crossAxisCount - 1))) /
                      crossAxisCount;

              final upcoming = [
                _buildUpcomingCard(context, isDark, 'Security & Safety',
                    Icons.security, Colors.blue),
                _buildUpcomingCard(context, isDark, 'Event & Wedding',
                    Icons.celebration, Colors.purple),
                _buildUpcomingCard(context, isDark, 'Religious & Spiritual',
                    Icons.spa, Colors.orange),
                _buildUpcomingCard(context, isDark, 'Rental & Hire',
                    Icons.car_rental, Colors.teal),
                _buildUpcomingCard(context, isDark, 'Finance Services',
                    Icons.payments, Colors.green),
                _buildUpcomingCard(context, isDark, 'Wholesale & Distribution',
                    Icons.storefront, Colors.indigo),
                _buildUpcomingCard(context, isDark, 'Healthcare & Medical',
                    Icons.medical_services, Colors.red),
                _buildUpcomingCard(context, isDark, 'Freelancers & Jobs',
                    Icons.work, Colors.blueGrey),
                _buildUpcomingCard(context, isDark, 'Accommodation',
                    Icons.hotel, Colors.amber),
                _buildUpcomingCard(context, isDark, 'Travel & Tourism',
                    Icons.flight, Colors.cyan),
                _buildUpcomingCard(context, isDark, 'Legal Services',
                    Icons.gavel, Colors.brown),
                _buildUpcomingCard(context, isDark, 'Food Products',
                    Icons.restaurant, Colors.lightGreen),
                _buildUpcomingCard(context, isDark, 'Used Vehicles',
                    Icons.directions_car, Colors.redAccent),
                _buildUpcomingCard(context, isDark, 'Real Estate', Icons.home,
                    Colors.deepOrange),
                _buildUpcomingCard(context, isDark, 'Furniture & Home',
                    Icons.weekend, Colors.pink),
                _buildUpcomingCard(context, isDark, 'Healthcare & Hospitals',
                    Icons.local_hospital, Colors.red),
              ];

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: upcoming
                    .map((s) => SizedBox(width: width, child: s))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingCard(BuildContext context, bool isDark, String title,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : AppColors.border.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
