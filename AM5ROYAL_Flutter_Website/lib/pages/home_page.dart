import 'package:flutter/material.dart';

import '../core/config/booking_config.dart';
import '../core/seo/seo_metadata.dart';
import '../core/seo/seo_routes.dart';
import '../core/seo/seo_service.dart';
import '../core/utils/vendor_navigation.dart';

import '../features/auth/services/auth_service.dart';
import '../features/booking/models/booking_models.dart';
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

import 'contact_details_page.dart';

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

  NavbarSectionId _currentSection = NavbarSectionId.home;

  static const Color backgroundStart = Color(0xFFF9EBD1);

  static const Color backgroundEnd = Color(0xFFFCEFDD);

  @override
  void initState() {
    super.initState();

    // --------------------------------------------------
    // READ CURRENT BROWSER HASH
    // --------------------------------------------------

    _currentSection = SeoService.sectionFromCurrentPath();

    // --------------------------------------------------
    // INITIAL SEO
    // --------------------------------------------------

    SeoService.applyMetadata(
      SeoRoutes.metadataForSection(
        _currentSection,
      ),
    );

    // --------------------------------------------------
    // BROWSER BACK / FORWARD
    // --------------------------------------------------

    SeoService.listenToNavigation(
      _handleBrowserNavigation,
    );
  }

  // ==========================================================
  // BROWSER BACK / FORWARD / HASH CHANGE
  // ==========================================================

  void _handleBrowserNavigation(
    NavbarSectionId section,
  ) {
    if (!mounted) {
      return;
    }

    if (_currentSection == section) {
      return;
    }

    setState(() {
      _currentSection = section;
    });

    SeoService.applyMetadata(
      SeoRoutes.metadataForSection(
        section,
      ),
    );

    _scrollToTop();
  }

  // ==========================================================
  // NAVBAR NAVIGATION
  // ==========================================================

  void _handleNavigation(
    NavbarSectionId section,
  ) {
    // --------------------------------------------------
    // VENDOR
    // --------------------------------------------------

    if (section == NavbarSectionId.vendor) {
      VendorNavigation.openVendorLogin();
      return;
    }

    // --------------------------------------------------
    // SAME SECTION
    // --------------------------------------------------

    if (_currentSection == section) {
      _scrollToTop();
      return;
    }

    // --------------------------------------------------
    // CHANGE SECTION IMMEDIATELY
    // --------------------------------------------------

    setState(() {
      _currentSection = section;
    });

    // --------------------------------------------------
    // SEO
    // --------------------------------------------------

    SeoService.applyMetadata(
      SeoRoutes.metadataForSection(
        section,
      ),
    );

    // --------------------------------------------------
    // BROWSER HASH
    // --------------------------------------------------

    SeoService.updateBrowserPath(
      SeoRoutes.pathForSection(
        section,
      ),
    );

    _scrollToTop();
  }

  // ==========================================================
  // SCROLL TO TOP
  // ==========================================================

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        if (!_scrollController.hasClients) {
          return;
        }

        _scrollController.jumpTo(0);
      },
    );
  }

  // ==========================================================
  // BOOK SERVICE
  // ==========================================================

  Future<void> _handleBookService() async {
    if (!mounted) {
      return;
    }

    final NavbarSectionId previousSection = _currentSection;

    SeoService.applyMetadata(
      SeoMetadata.booking,
    );

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return const BookingFlowPage(
            initialCategoryId: BookingConfig.homeServicesCategoryId,
          );
        },
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _currentSection = previousSection;
    });

    SeoService.applyMetadata(
      SeoRoutes.metadataForSection(
        previousSection,
      ),
    );

    SeoService.updateBrowserPath(
      SeoRoutes.pathForSection(
        previousSection,
      ),
    );

    _scrollToTop();
  }

  // ==========================================================
  // SUBCATEGORY SELECTED
  // ==========================================================

  Future<void> _handleSubcategorySelected(
    ServiceSubcategory subcategory,
  ) async {
    if (!mounted) {
      return;
    }

    final NavbarSectionId previousSection = _currentSection;

    SeoService.applyMetadata(
      SeoMetadata.booking,
    );

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return BookingFlowPage(
            initialCategoryId: BookingConfig.homeServicesCategoryId,
            initialSubcategoryId: subcategory.id,
          );
        },
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _currentSection = previousSection;
    });

    SeoService.applyMetadata(
      SeoRoutes.metadataForSection(
        previousSection,
      ),
    );

    SeoService.updateBrowserPath(
      SeoRoutes.pathForSection(
        previousSection,
      ),
    );

    _scrollToTop();
  }

  // ==========================================================
  // LOGIN
  // ==========================================================

  void _handleLogin() {
    Navigator.of(context).pushReplacementNamed(
      '/login',
    );
  }

  // ==========================================================
  // REGISTER
  // ==========================================================

  void _handleRegister() {
    Navigator.of(context).pushReplacementNamed(
      '/register',
    );
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  Future<void> _handleLogout() async {
    await widget.authService.logout();

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  // ==========================================================
  // SERVICE CARD -> HOME
  // ==========================================================

  void _handleServiceCardSelected() {
    if (_currentSection != NavbarSectionId.home) {
      setState(() {
        _currentSection = NavbarSectionId.home;
      });

      SeoService.applyMetadata(
        SeoRoutes.metadataForSection(
          NavbarSectionId.home,
        ),
      );

      SeoService.updateBrowserPath(
        SeoRoutes.pathForSection(
          NavbarSectionId.home,
        ),
      );
    }

    _scrollToTop();
  }

  // ==========================================================
  // CURRENT SECTION CONTENT
  // ==========================================================

  Widget _buildCurrentContent() {
    switch (_currentSection) {
      // ------------------------------------------------------
      // HOME
      // ------------------------------------------------------

      case NavbarSectionId.home:
        return _HomeContent(
          onServiceSelected: _handleServiceCardSelected,
          onSubcategorySelected: _handleSubcategorySelected,
          onBookService: _handleBookService,
        );

      // ------------------------------------------------------
      // SERVICES
      //
      // IMPORTANT:
      // Services click opens:
      //
      // 1. Our Services
      // 2. Upcoming Services
      //
      // Same sections used on Home.
      // ------------------------------------------------------

      case NavbarSectionId.services:
        return _ServicesPageContent(
          onSubcategorySelected: _handleSubcategorySelected,
          onBookService: _handleBookService,
        );

      // ------------------------------------------------------
      // VENDOR
      // ------------------------------------------------------

      case NavbarSectionId.vendor:
        return const _VendorContent();

      // ------------------------------------------------------
      // CUSTOMER
      // ------------------------------------------------------

      case NavbarSectionId.customer:
        return _CustomerContent(
          onBookService: _handleBookService,
        );

      // ------------------------------------------------------
      // FREELANCER
      // ------------------------------------------------------

      case NavbarSectionId.freelancer:
        return const FreelancerSection();

      // ------------------------------------------------------
      // CAREERS
      // ------------------------------------------------------

      case NavbarSectionId.careers:
        return const CareersSection();

      // ------------------------------------------------------
      // CONTACT
      // ------------------------------------------------------

      case NavbarSectionId.contact:
        return const ContactDetailsPage();

      // ------------------------------------------------------
      // HOW IT WORKS
      // ------------------------------------------------------

      case NavbarSectionId.howItWorks:
        return const HowItWorksSection();

      // ------------------------------------------------------
      // FAQS
      // ------------------------------------------------------

      case NavbarSectionId.faqs:
        return const FaqsSection();

      // ------------------------------------------------------
      // PRIVACY POLICY
      // ------------------------------------------------------

      case NavbarSectionId.privacyPolicy:
        return const PrivacyPolicySection();

      // ------------------------------------------------------
      // TERMS & CONDITIONS
      // ------------------------------------------------------

      case NavbarSectionId.termsConditions:
        return const TermsConditionsSection();
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==================================================
            // NAVBAR
            // ==================================================

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

            // ==================================================
            // PAGE CONTENT
            // ==================================================

            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCurrentContent(),
                    FooterSection(
                      onSectionSelected: _handleNavigation,
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

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }
}

// ============================================================================
// HOME CONTENT
// ============================================================================

class _HomeContent extends StatefulWidget {
  const _HomeContent({
    required this.onServiceSelected,
    required this.onSubcategorySelected,
    required this.onBookService,
  });

  final VoidCallback onServiceSelected;

  final ValueChanged<ServiceSubcategory> onSubcategorySelected;

  final VoidCallback onBookService;

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
        // ======================================================
        // HERO
        // ======================================================

        HeroSection(
          highlightCta: _highlightCta,
          onBookServicePressed: widget.onBookService,
          onPartnerPressed: VendorNavigation.openVendorLogin,
        ),

        // ======================================================
        // OUR SERVICES
        // ======================================================

        OurServicesSection(
          onSubcategorySelected: widget.onSubcategorySelected,
          onBookService: widget.onBookService,
        ),

        // ======================================================
        // UPCOMING SERVICES
        // ======================================================

        UpcomingServicesSection(
          onServiceSelected: _handleServiceSelected,
        ),

        // ======================================================
        // WHY CHOOSE US
        // ======================================================

        const WhyChooseSection(),

        // ======================================================
        // HOME CTA
        // ======================================================

        home_cta.HomeCtaSection(
          highlightCta: _highlightCta,
        ),
      ],
    );
  }
}

// ============================================================================
// SERVICES PAGE CONTENT
// ============================================================================
//
// SERVICES NAVBAR CLICK:
//
// Our Services
//      ↓
// Upcoming Services
//
// Exact same existing sections from Home.
// No backend/API changes.
// ============================================================================

class _ServicesPageContent extends StatelessWidget {
  const _ServicesPageContent({
    required this.onSubcategorySelected,
    required this.onBookService,
  });

  final ValueChanged<ServiceSubcategory> onSubcategorySelected;

  final VoidCallback onBookService;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ======================================================
        // OUR SERVICES
        // ======================================================

        OurServicesSection(
          onSubcategorySelected: onSubcategorySelected,
          onBookService: onBookService,
        ),

        // ======================================================
        // UPCOMING SERVICES
        // ======================================================

        const UpcomingServicesSection(),
      ],
    );
  }
}

// ============================================================================
// VENDOR CONTENT
// ============================================================================

class _VendorContent extends StatelessWidget {
  const _VendorContent();

  @override
  Widget build(BuildContext context) {
    return _SimpleContent(
      eyebrow: 'AM5ROYAL PARTNERS',
      title: 'Become a',
      highlightedTitle: 'Trusted Partner.',
      description: 'Grow your service business by '
          'connecting with customers looking '
          'for trusted professionals.',
      primaryButton: 'Partner With Us',
      secondaryButton: 'Learn More',
      onPrimaryPressed: VendorNavigation.openVendorLogin,
    );
  }
}

// ============================================================================
// CUSTOMER CONTENT
// ============================================================================

class _CustomerContent extends StatelessWidget {
  const _CustomerContent({
    required this.onBookService,
  });

  final VoidCallback onBookService;

  @override
  Widget build(BuildContext context) {
    return _SimpleContent(
      eyebrow: 'FOR CUSTOMERS',
      title: 'Trusted Services',
      highlightedTitle: 'When You Need Them.',
      description: 'Book reliable professionals for your '
          'home and business needs with a simple '
          'and convenient experience.',
      primaryButton: 'Book a Service',
      secondaryButton: 'Explore Services',
      onPrimaryPressed: onBookService,
    );
  }
}

// ============================================================================
// SIMPLE CONTENT
// ============================================================================

class _SimpleContent extends StatelessWidget {
  const _SimpleContent({
    required this.eyebrow,
    required this.title,
    required this.highlightedTitle,
    required this.description,
    required this.primaryButton,
    this.secondaryButton,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
  });

  final String eyebrow;
  final String title;
  final String highlightedTitle;
  final String description;

  final String primaryButton;

  final String? secondaryButton;

  final VoidCallback? onPrimaryPressed;

  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;

    final bool isMobile = width < 700;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 560,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 70 : 100,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1100,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================================================
              // EYEBROW
              // ==================================================

              Text(
                eyebrow,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      letterSpacing: 2.2,
                      fontWeight: FontWeight.w700,
                    ),
              ),

              const SizedBox(
                height: 18,
              ),

              // ==================================================
              // TITLE
              // ==================================================

              Text(
                title,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
              ),

              Text(
                highlightedTitle,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
              ),

              const SizedBox(
                height: 28,
              ),

              // ==================================================
              // DESCRIPTION
              // ==================================================

              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 720,
                ),
                child: Text(
                  description,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        height: 1.7,
                      ),
                ),
              ),

              const SizedBox(
                height: 38,
              ),

              // ==================================================
              // BUTTONS
              // ==================================================

              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  if (onPrimaryPressed != null)
                    ElevatedButton(
                      onPressed: onPrimaryPressed,
                      child: Text(
                        primaryButton,
                      ),
                    ),
                  if (secondaryButton != null)
                    OutlinedButton(
                      onPressed: onSecondaryPressed,
                      child: Text(
                        secondaryButton!,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
