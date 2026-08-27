import 'package:flutter/material.dart';

import '../core/seo/seo_metadata.dart';
import '../core/seo/seo_routes.dart';
import '../core/seo/seo_service.dart';
import '../core/utils/vendor_navigation.dart';
import '../features/auth/services/auth_service.dart';
import '../features/booking/pages/booking_flow_page.dart';
import '../sections/careers/careers_section.dart';
import '../sections/faqs/faqs_section.dart';
import '../sections/footer/footer_section.dart';
import '../sections/freelancer/freelancer_section.dart';
import '../sections/home/hero_section.dart';
import '../sections/home/home_cta_section.dart' as home_cta;
import '../sections/home/our_services_section.dart';
import '../sections/home/upcoming_services_section.dart';
import '../sections/home/why_choose_section.dart';
import '../sections/how_it_works/how_it_works_section.dart';
import '../sections/navbar/navbar_section.dart';
import '../sections/privacy_policy/privacy_policy_section.dart';
import '../sections/terms_conditions/terms_conditions_section.dart';

import 'login_page.dart';
import 'register_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.authService,
  });

  final AuthService authService;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _servicesSectionKey = GlobalKey();

  NavbarSectionId _currentSection = NavbarSectionId.home;

  static const Color backgroundStart = Color(0xFFF9EBD1);
  static const Color backgroundEnd = Color(0xFFFCEFDD);

  @override
  void initState() {
    super.initState();
    _bootstrapFromUrl();
    SeoService.listenToNavigation(_handleBrowserNavigation);
  }

  void _bootstrapFromUrl() {
    final NavbarSectionId section = SeoService.sectionFromCurrentPath();
    if (section == NavbarSectionId.services) {
      _currentSection = NavbarSectionId.home;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToServices());
    } else {
      _currentSection = section;
    }
    SeoService.applyMetadata(SeoRoutes.metadataForSection(section));
  }

  void _handleBrowserNavigation(NavbarSectionId section) {
    if (section == NavbarSectionId.services) {
      setState(() => _currentSection = NavbarSectionId.home);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToServices());
    } else {
      setState(() => _currentSection = section);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
    }
    SeoService.applyMetadata(SeoRoutes.metadataForSection(section));
  }

  // ==========================================================================
  // NAVIGATION
  // ==========================================================================

  void _handleNavigation(NavbarSectionId section) {
    if (section == NavbarSectionId.vendor) {
      VendorNavigation.openVendorLogin();
      return;
    }

    if (section == NavbarSectionId.services) {
      setState(() => _currentSection = NavbarSectionId.home);
      SeoService.applySection(NavbarSectionId.services);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToServices());
      return;
    }

    setState(() {
      _currentSection = section;
    });
    SeoService.applySection(section);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    });
  }

  // ==========================================================================
  // LOGIN
  // ==========================================================================

  void _scrollToServices() {
    final BuildContext? context = _servicesSectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _handleBookService() async {
    if (!mounted) return;
    SeoService.applyMetadata(SeoMetadata.booking);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const BookingFlowPage(),
      ),
    );
    if (!mounted) return;
    SeoService.applySection(_currentSection);
  }

  void _handleLogin() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => LoginPage(
          onRegisterPressed: _handleRegister,
          onLoginSuccess: () => setState(() {}),
        ),
      ),
    );
  }

  void _handleRegister() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => RegisterPage(
          onLoginPressed: _handleLogin,
          onRegisterSuccess: () => setState(() {}),
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    await widget.authService.logout();
    if (mounted) setState(() {});
  }

  // ==========================================================================
  // SERVICE SELECTED
  // ==========================================================================

  void _handleServiceCardSelected() {
    if (_currentSection != NavbarSectionId.home) {
      setState(() {
        _currentSection = NavbarSectionId.home;
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOutCubic,
      );
    });
  }

  // ==========================================================================
  // CURRENT PAGE
  // ==========================================================================

  Widget _buildCurrentContent() {
    switch (_currentSection) {
      case NavbarSectionId.home:
        return _HomeContent(
          onServiceSelected: _handleServiceCardSelected,
          onBookService: _handleBookService,
          servicesSectionKey: _servicesSectionKey,
        );

      case NavbarSectionId.services:
        return _ServicesContent(onBookService: _handleBookService);

      case NavbarSectionId.vendor:
        return const _VendorContent();

      case NavbarSectionId.customer:
        return _CustomerContent(onBookService: _handleBookService);

      case NavbarSectionId.freelancer:
        return const FreelancerSection();

      case NavbarSectionId.careers:
        return const CareersSection();

      case NavbarSectionId.contact:
        return const _ContactContent();

      case NavbarSectionId.howItWorks:
        return const HowItWorksSection();

      case NavbarSectionId.faqs:
        return const FaqsSection();

      case NavbarSectionId.privacyPolicy:
        return const PrivacyPolicySection();

      case NavbarSectionId.termsConditions:
        return const TermsConditionsSection();
    }
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundStart,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundStart,
              backgroundEnd,
            ],
          ),
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // NAVBAR
              NavbarSection(
                currentSection: _currentSection,
                onSectionSelected: _handleNavigation,
                onLoginPressed: _handleLogin,
                onRegisterPressed: _handleRegister,
                isAuthenticated: widget.authService.isAuthenticated,
                customerName: widget.authService.profile?.fullName,
                onLogout: _handleLogout,
                onBookService: _handleBookService,
              ),

              // CONTENT
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: KeyedSubtree(
                  key: ValueKey<NavbarSectionId>(
                    _currentSection,
                  ),
                  child: _buildCurrentContent(),
                ),
              ),

              // FOOTER
              FooterSection(
                onSectionSelected: _handleNavigation,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

// =============================================================================
// HOME CONTENT
// =============================================================================

class _HomeContent extends StatefulWidget {
  const _HomeContent({
    required this.onServiceSelected,
    required this.onBookService,
    required this.servicesSectionKey,
  });

  final VoidCallback onServiceSelected;
  final VoidCallback onBookService;
  final GlobalKey servicesSectionKey;

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  bool _highlightCta = false;

  void _handleServiceSelected() {
    widget.onServiceSelected();

    setState(() {
      _highlightCta = true;
    });

    Future<void>.delayed(
      const Duration(seconds: 3),
      () {
        if (!mounted) {
          return;
        }

        setState(() {
          _highlightCta = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // HERO
        HeroSection(
          highlightCta: _highlightCta,
          onBookServicePressed: widget.onBookService,
          onPartnerPressed: VendorNavigation.openVendorLogin,
        ),

        // OUR SERVICES
        KeyedSubtree(
          key: widget.servicesSectionKey,
          child: OurServicesSection(
            onServiceSelected: _handleServiceSelected,
            onBookService: widget.onBookService,
          ),
        ),

        // UPCOMING SERVICES
        UpcomingServicesSection(
          onServiceSelected: _handleServiceSelected,
        ),

        // WHY CHOOSE
        const WhyChooseSection(),

        // APP CTA
        home_cta.HomeCtaSection(
          highlightCta: _highlightCta,
        ),
      ],
    );
  }
}

// =============================================================================
// SERVICES PAGE
// =============================================================================

class _ServicesContent extends StatelessWidget {
  const _ServicesContent({required this.onBookService});

  final VoidCallback onBookService;

  @override
  Widget build(BuildContext context) {
    return _SimpleContent(
      eyebrow: 'OUR SERVICES',
      title: 'Professional Services',
      highlightedTitle: 'At Your Doorstep.',
      description:
          'Find reliable professionals for your home and business needs. '
          'AM5ROYAL brings multiple services together on one convenient platform.',
      primaryButton: 'Book a Service',
      secondaryButton: 'Become a Partner',
      onPrimaryPressed: onBookService,
      onSecondaryPressed: VendorNavigation.openVendorLogin,
    );
  }
}

// =============================================================================
// VENDOR PAGE
// =============================================================================

class _VendorContent extends StatelessWidget {
  const _VendorContent();

  @override
  Widget build(BuildContext context) {
    return _SimpleContent(
      eyebrow: 'AM5ROYAL PARTNERS',
      title: 'Become a',
      highlightedTitle: 'Trusted Partner.',
      description:
          'Grow your service business by connecting with customers looking '
          'for trusted professionals.',
      primaryButton: 'Partner With Us',
      secondaryButton: 'Learn More',
      onPrimaryPressed: VendorNavigation.openVendorLogin,
    );
  }
}

// =============================================================================
// CUSTOMER PAGE
// =============================================================================

class _CustomerContent extends StatelessWidget {
  const _CustomerContent({required this.onBookService});

  final VoidCallback onBookService;

  @override
  Widget build(BuildContext context) {
    final bool desktop = MediaQuery.sizeOf(context).width >= 900;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 620,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: desktop ? 70 : 24,
        vertical: 70,
      ),
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1150,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x120B4EA2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0x300B4EA2),
                  ),
                ),
                child: const Text(
                  'CUSTOMER EXPERIENCE',
                  style: TextStyle(
                    color: Color(0xFF0B4EA2),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Your Services.',
                style: TextStyle(
                  color: const Color(0xFF0B1F3A),
                  fontSize: desktop ? 52 : 38,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              Text(
                'Made Simple.',
                style: TextStyle(
                  color: const Color(0xFF0B4EA2),
                  fontSize: desktop ? 52 : 38,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 22),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 650,
                ),
                child: Text(
                  'Book trusted professionals for your home service needs '
                  'with AM5ROYAL. Simple booking, reliable professionals '
                  'and convenient service management.',
                  style: TextStyle(
                    color: Color(0xFF536985),
                    fontSize: 16,
                    height: 1.7,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: onBookService,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B4EA2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: const Text(
                  'Book a Service',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
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
// CONTACT PAGE
// =============================================================================

class _ContactContent extends StatelessWidget {
  const _ContactContent();

  @override
  Widget build(BuildContext context) {
    return const _SimpleContent(
      eyebrow: 'GET IN TOUCH',
      title: 'We Are Here',
      highlightedTitle: 'To Help.',
      description:
          'Have a question, enquiry or business requirement? Connect with '
          'the AM5ROYAL team.',
      primaryButton: 'Contact Us',
      secondaryButton: 'Learn More',
    );
  }
}

// =============================================================================
// SIMPLE CONTENT
// =============================================================================

class _SimpleContent extends StatelessWidget {
  const _SimpleContent({
    required this.eyebrow,
    required this.title,
    required this.highlightedTitle,
    required this.description,
    required this.primaryButton,
    required this.secondaryButton,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
  });

  final String eyebrow;
  final String title;
  final String highlightedTitle;
  final String description;
  final String primaryButton;
  final String secondaryButton;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    final bool desktop = MediaQuery.sizeOf(context).width >= 900;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 620,
      ),
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
            horizontal: desktop ? 70 : 24,
            vertical: desktop ? 80 : 55,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1150,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 34,
                      height: 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5B301),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Text(
                      eyebrow,
                      style: const TextStyle(
                        color: Color(0xFF0B4EA2),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xFF0B1F3A),
                    fontSize: desktop ? 52 : 38,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                Text(
                  highlightedTitle,
                  style: TextStyle(
                    color: const Color(0xFF0B4EA2),
                    fontSize: desktop ? 52 : 38,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 22),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 650,
                  ),
                  child: Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFF536985),
                      fontSize: 16,
                      height: 1.7,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton(
                      onPressed: onPrimaryPressed ?? () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B4EA2),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      child: Text(
                        primaryButton,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: onSecondaryPressed ?? () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0B4EA2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 15,
                        ),
                        side: const BorderSide(
                          color: Color(0xFF0B4EA2),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      child: Text(
                        secondaryButton,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
