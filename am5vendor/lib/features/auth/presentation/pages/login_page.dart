import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/auth.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/send_otp_bloc.dart';
import '../bloc/send_otp_event.dart';
import '../bloc/send_otp_state.dart';
import '../bloc/verify_otp_bloc.dart';
import '../bloc/verify_otp_event.dart';
import '../bloc/verify_otp_state.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/auth_storage_service.dart';
import '../../../../core/services/onboarding_navigation_service.dart';
import '../providers/auth_providers.dart';
import '../../../../core/widgets/responsive_layout.dart';

class LoginPage extends ConsumerStatefulWidget {
  final bool fromLogout;
  const LoginPage({super.key, this.fromLogout = false});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  // Input controllers
  final TextEditingController _contactController = TextEditingController();

  // OTP Verification state variables
  bool _otpSent = false;
  String? _identifier;
  final List<TextEditingController> _otpControllers =
      List.generate(5, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(5, (_) => FocusNode());
  int _secondsRemaining = 59;
  Timer? _timer;

  // State variables
  bool _isLoading = false;
  int _activeServiceIndex = -1;
  String? _contactError;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _contactController.dispose();

    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _checkOnboardingStatusAndNavigate() async {
    final authStorage = di.sl<AuthStorageService>();
    final role = authStorage.getUserRole();

    if (!mounted) return;

    if (role == 'admin') {
      setState(() => _isLoading = false);
      context.go('/admin-dashboard');
      return;
    } else if (role == 'telecaller' || role == 'tele_caller') {
      setState(() => _isLoading = false);
      context.go('/telecaller-dashboard');
      return;
    } else if (role == 'marketing' ||
        role == 'marketing_team' ||
        role == 'field_sales') {
      setState(() => _isLoading = false);
      context.go('/marketing-dashboard');
      return;
    }

    final navigated = await OnboardingNavigationService.fetchStatusAndNavigate(
      context,
      fallbackToOnboardingStart: true,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (!navigated) {
        context.go('/map');
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 59;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  String get _timerString {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _resetLoginView() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _contactController.clear();
    setState(() {
      _otpSent = false;
      _identifier = null;
      _contactError = null;
    });
  }

  void _handleVerifyAndLogin() {
    final otp = _otpControllers.map((c) => c.text).join();
    if (!AuthValidator.isValidOtp(otp)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter the full 5-digit OTP.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    ref.read(verifyOtpBlocProvider).add(VerifyOtpEvent.submit(
          contact: _identifier ?? _contactController.text.trim(),
          otp: otp,
        ));
  }

  final String _selectedCountryCode = '+91';

  void _validateContact(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _contactError = null;
      });
      return;
    }

    final isEmail = AuthValidator.isEmailInput(trimmed);
    if (isEmail) {
      if (AuthValidator.isValidEmail(trimmed)) {
        setState(() {
          _contactError = null;
        });
      } else {
        setState(() {
          _contactError =
              'Please enter a valid email address (e.g. user@example.com).';
        });
      }
    } else {
      if (AuthValidator.isValidMobile(trimmed)) {
        setState(() {
          _contactError = null;
        });
      } else {
        setState(() {
          _contactError = 'Please enter a valid 10-digit mobile number';
        });
      }
    }
  }

  void _handleSendOtp() {
    final contact = _contactController.text.trim();
    if (contact.isEmpty) {
      setState(() {
        _contactError = 'Please enter a mobile number or email address.';
      });
      return;
    }

    final isEmail = AuthValidator.isEmailInput(contact);
    if (isEmail) {
      if (!AuthValidator.isValidEmail(contact)) {
        setState(() {
          _contactError = 'Please enter a valid email address.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter a valid email address.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }
    } else {
      if (!AuthValidator.isValidMobile(contact)) {
        setState(() {
          _contactError = 'Please enter a valid mobile number.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter a valid mobile number.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }
    }

    setState(() {
      _contactError = null;
    });

    ref.read(sendOtpBlocProvider).add(SendOtpEvent.submit(contact));
  }

  @override
  Widget build(BuildContext context) {
    final sendOtpBloc = ref.watch(sendOtpBlocProvider);
    final verifyOtpBloc = ref.watch(verifyOtpBlocProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              state.maybeWhen(
                initial: () {
                  setState(() {
                    _isLoading = false;
                  });
                },
                loading: () {
                  setState(() {
                    _isLoading = true;
                  });
                },
                success: (message, auth) {
                  // Do NOT set isLoading to false here, we do it after navigation logic
                  AnalyticsService().logLogin(loginMethod: 'OTP');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: const Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                  _checkOnboardingStatusAndNavigate();
                },
                error: (message) {
                  setState(() {
                    _isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                orElse: () {},
              );
            },
          ),
          BlocListener<SendOtpBloc, SendOtpState>(
            bloc: sendOtpBloc,
            listener: (context, state) {
              state.maybeWhen(
                loading: () {
                  setState(() {
                    _isLoading = true;
                  });
                },
                success: (response) {
                  setState(() {
                    _isLoading = false;
                    _otpSent = true;
                    _identifier = response.identifier;
                  });
                  _startTimer();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response.message),
                      backgroundColor: const Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                error: (message) {
                  setState(() {
                    _isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                orElse: () {
                  setState(() {
                    _isLoading = false;
                  });
                },
              );
            },
          ),
          BlocListener<VerifyOtpBloc, VerifyOtpState>(
            bloc: verifyOtpBloc,
            listener: (context, state) {
              state.maybeWhen(
                loading: () {
                  setState(() {
                    _isLoading = true;
                  });
                },
                success: (response) async {
                  final prefs = di.sl<SharedPreferences>();
                  await prefs.setBool('is_new_user', response.isNewUser);
                  // Keep isLoading true while fetching onboarding status
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('OTP Verified Successfully!'),
                        backgroundColor: Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12))),
                      ),
                    );
                    _checkOnboardingStatusAndNavigate();
                  }
                },
                error: (message) {
                  setState(() {
                    _isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                orElse: () {
                  setState(() {
                    _isLoading = false;
                  });
                },
              );
            },
          ),
        ],
        child: Stack(
          children: [
            // 1. Watercolor Splash Background
            Positioned.fill(
              child: Image.asset(
                'assets/images/water.png',
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.85),
              ),
            ),

            // Subtle color blend overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.4),
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.5),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // 2. Main Content inside LayoutBuilder & ResponsiveLayout
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ResponsiveLayout(
                    mobile: _buildMobileLayout(context, constraints),
                    tablet: constraints.maxWidth > 800
                        ? _buildDesktopLayout(context, constraints)
                        : _buildMobileLayout(context, constraints),
                    desktop: _buildDesktopLayout(context, constraints),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, BoxConstraints constraints) {
    final isMobile = constraints.maxWidth < 700;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight,
        ),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- TOP CONTENT (Branding & services) ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),

                  // Top Logo Image (Hands holding crown)
                  Center(
                    child: SizedBox(
                      height: 120,
                      child: Image.asset(
                        'assets/images/AM5 ROYAL TM logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Brand Title
                  Text(
                    'AM5 ROYAL',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF0F4C81),
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Slogan Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: Divider(
                            color: Color(0xFF0F4C81),
                            thickness: 1.2,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 5,
                                color: Color(0xFF0F4C81),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'TRUST  •  QUALITY  •  LOYALTY',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF0F4C81),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.circle,
                                size: 5,
                                color: Color(0xFF0F4C81),
                              ),
                            ],
                          ),
                        ),
                        const Expanded(
                          child: Divider(
                            color: Color(0xFF0F4C81),
                            thickness: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Services Header Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Divider(
                            color: Color(0xFF0F4C81),
                            thickness: 1.2,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            'OUR SERVICES',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF0F4C81),
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(
                            color: Color(0xFF0F4C81),
                            thickness: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Services (6 Icons)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildServiceItem(
                          index: 0,
                          icon: Icons.verified_user_rounded,
                          title: 'Secure &\nTrusted',
                        ),
                        _buildServiceItem(
                          index: 1,
                          icon: Icons.inventory_2_rounded,
                          title: 'Quality\nProducts',
                        ),
                        _buildServiceItem(
                          index: 2,
                          icon: Icons.local_shipping_rounded,
                          title: 'Fast\nDelivery',
                        ),
                        _buildServiceItem(
                          index: 3,
                          icon: Icons.headset_mic_rounded,
                          title: 'Vendor Support',
                        ),
                        _buildServiceItem(
                          index: 4,
                          icon: Icons.stars_rounded,
                          title: 'Best Deals \nVendors',
                        ),
                        if (!isMobile)
                          _buildServiceItem(
                            index: 5,
                            icon: Icons.handshake_rounded,
                            title: 'Reliable\nVendor Partnership',
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),

              // Spacer pushes the login card downwards so it occupies the bottom of the viewport
              const Spacer(),

              // --- BOTTOM CONTENT (Welcome Box Card) ---
              _buildLoginCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, BoxConstraints constraints) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Column: Branding and services
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Top Logo Image
                        Center(
                          child: SizedBox(
                            height: 140,
                            child: Image.asset(
                              'assets/images/AM5 ROYAL TM logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Brand Title
                        Text(
                          'AM5 ROYAL',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF0F4C81),
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Slogan Divider
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(
                              child: Divider(
                                color: Color(0xFF0F4C81),
                                thickness: 1.2,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    size: 5,
                                    color: Color(0xFF0F4C81),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'TRUST  •  QUALITY  •  LOYALTY',
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF0F4C81),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.circle,
                                    size: 5,
                                    color: Color(0xFF0F4C81),
                                  ),
                                ],
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                color: Color(0xFF0F4C81),
                                thickness: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Services Header Section
                        Text(
                          'OUR SERVICES',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF0F4C81),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Services Icons Grid (Wrap for responsive wrapping)
                        Wrap(
                          spacing: 24,
                          runSpacing: 24,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildServiceItem(
                              index: 0,
                              icon: Icons.verified_user_rounded,
                              title: 'Secure &\nTrusted',
                              isDesktop: true,
                            ),
                            _buildServiceItem(
                              index: 1,
                              icon: Icons.inventory_2_rounded,
                              title: 'Quality\nProducts',
                              isDesktop: true,
                            ),
                            _buildServiceItem(
                              index: 2,
                              icon: Icons.local_shipping_rounded,
                              title: 'Fast\nDelivery',
                              isDesktop: true,
                            ),
                            _buildServiceItem(
                              index: 3,
                              icon: Icons.headset_mic_rounded,
                              title: 'Vendor Support',
                              isDesktop: true,
                            ),
                            _buildServiceItem(
                              index: 4,
                              icon: Icons.stars_rounded,
                              title: 'Best Deals \nVendors',
                              isDesktop: true,
                            ),
                            _buildServiceItem(
                              index: 5,
                              icon: Icons.handshake_rounded,
                              title: 'Reliable\nVendor Partnership',
                              isDesktop: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Right Column: Welcome Box Card
                Expanded(
                  flex: 4,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: _buildLoginCard(context, isDesktop: true),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context, {bool isDesktop = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
        margin: isDesktop
            ? EdgeInsets.zero
            : const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.45),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : const Color(0xFF0F4C81))
                        .withValues(alpha: 0.08),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!_otpSent) ...[
                    Text(
                      'Welcome Back!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: isDark ? Colors.white : const Color(0xFF0D3B66),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Contact Field (Phone / Email)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Mobile / Email',
                        style: GoogleFonts.outfit(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : const Color(0xFF0D3B66),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _contactController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        color: isDark ? Colors.white : const Color(0xFF2D3748),
                        fontWeight: FontWeight.w500,
                      ),
                      inputFormatters: [
                        if (!AuthValidator.isEmailInput(
                            _contactController.text))
                          LengthLimitingTextInputFormatter(10),
                      ],
                      onChanged: (val) {
                        setState(() {});
                        _validateContact(val);
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter mobile number or email',
                        hintStyle: GoogleFonts.outfit(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.4)
                              : const Color(0xFFA0AEC0),
                          fontSize: 15,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 12, right: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: AuthValidator.isEmailInput(
                                        _contactController.text)
                                    ? Icon(
                                        Icons.email_outlined,
                                        key: const ValueKey('email_icon'),
                                        color: isDark
                                            ? AppColors.accentLight
                                            : const Color(0xFF71717A),
                                        size: 22,
                                      )
                                    : Container(
                                        key: const ValueKey(
                                            'mobile_country_code'),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.white
                                                  .withValues(alpha: 0.1)
                                              : const Color(0xFFEDF2F7),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.phone_android_rounded,
                                              size: 16,
                                              color: isDark
                                                  ? AppColors.accentLight
                                                  : const Color(0xFF0F4C81),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _selectedCountryCode,
                                              style: GoogleFonts.outfit(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: isDark
                                                    ? Colors.white
                                                    : const Color(0xFF0F4C81),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                height: 20,
                                width: 1,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : const Color(0xFFCBD5E0),
                              ),
                            ],
                          ),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.black.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.6),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : const Color(0xFFE2E8F0),
                              width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : const Color(0xFFE2E8F0),
                              width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: isDark
                                  ? AppColors.accent
                                  : const Color(0xFF0F4C81),
                              width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Colors.redAccent, width: 1.5),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Colors.redAccent, width: 2),
                        ),
                        errorText: _contactError,
                        errorStyle: GoogleFonts.outfit(
                          color: Colors.redAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Send OTP Button
                    Container(
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'Send OTP',
                                style: GoogleFonts.outfit(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // // "OR" Divider
                    // Row(
                    //   children: [
                    //     const Expanded(
                    //       child: Divider(
                    //         color: Color(0xFFE2E8F0),
                    //         thickness: 1,
                    //       ),
                    //     ),
                    //     Padding(
                    //       padding: const EdgeInsets.symmetric(horizontal: 16),
                    //       child: Text(
                    //         'OR',
                    //         style: GoogleFonts.outfit(
                    //           color: const Color(0xFFA0AEC0),
                    //           fontSize: 14,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //     ),
                    //     const Expanded(
                    //       child: Divider(
                    //         color: Color(0xFFE2E8F0),
                    //         thickness: 1,
                    //       ),
                    //     ),
                    //   ],
                    // ),

                    // const SizedBox(height: 16),

                    // // Social Login Buttons
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     _buildSocialButton(
                    //       child: Image.asset('assets/images/google_logo.png', height: 26, width: 26),
                    //       onTap: _isLoading ? null : _handleGoogleSignIn,
                    //     ),
                    //     const SizedBox(width: 20),
                    //     _buildSocialButton(
                    //       child: const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 30),
                    //       onTap: _isLoading ? null : () {},
                    //     ),
                    //     const SizedBox(width: 20),
                    //     _buildSocialButton(
                    //       child: const Icon(Icons.apple, color: Colors.black, size: 30),
                    //       onTap: _isLoading ? null : () {},
                    //     ),
                    //   ],
                    // ),
                  ] else ...[
                    Text(
                      'Verification Code',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: isDark ? Colors.white : const Color(0xFF0D3B66),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Please enter the 5-digit verification code sent to:\n${_identifier ?? ""}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : const Color(0xFF7F8C8D),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 5-digit OTP Inputs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(5, (index) {
                        return SizedBox(
                          width: 44,
                          height: 52,
                          child: TextField(
                            controller: _otpControllers[index],
                            focusNode: _otpFocusNodes[index],
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : const Color(0xFF0D3B66),
                            ),
                            cursorColor: isDark
                                ? AppColors.accentLight
                                : const Color(0xFF0F4C81),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: isDark
                                  ? AppColors.darkSurfaceVariant
                                  : Colors.white.withValues(alpha: 0.85),
                              contentPadding: EdgeInsets.zero,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? AppColors.darkBorder
                                      : const Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? AppColors.darkBorder
                                      : const Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? AppColors.accentLight
                                      : const Color(0xFF007AFF),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                if (index < 4) {
                                  _otpFocusNodes[index + 1].requestFocus();
                                } else {
                                  _otpFocusNodes[index].unfocus();
                                }
                              } else {
                                if (index > 0) {
                                  _otpFocusNodes[index - 1].requestFocus();
                                }
                              }
                              // Auto-trigger API call once all fields are filled
                              final otp =
                                  _otpControllers.map((c) => c.text).join();
                              if (otp.length == 5) {
                                _handleVerifyAndLogin();
                              }
                            },
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 24),

                    // Resend timer row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't receive code? ",
                          style: GoogleFonts.outfit(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : const Color(0xFF7F8C8D),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        MouseRegion(
                          cursor: _secondsRemaining == 0
                              ? SystemMouseCursors.click
                              : SystemMouseCursors.basic,
                          child: GestureDetector(
                            onTap: _secondsRemaining == 0
                                ? () {
                                    _startTimer();
                                    ref.read(sendOtpBlocProvider).add(
                                        SendOtpEvent.submit(_identifier ?? ''));
                                  }
                                : null,
                            child: Text(
                              _secondsRemaining == 0
                                  ? 'Resend OTP'
                                  : _timerString,
                              style: GoogleFonts.outfit(
                                color: isDark
                                    ? AppColors.accentLight
                                    : const Color(0xFF007AFF),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Verify & Login Button
                    Container(
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleVerifyAndLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'Verify & Login',
                                style: GoogleFonts.outfit(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Back to Login Link
                    TextButton(
                      onPressed: _resetLoginView,
                      child: Text(
                        'Change Email / Mobile',
                        style: GoogleFonts.outfit(
                          color: isDark
                              ? AppColors.accentLight
                              : const Color(0xFF007AFF),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildServiceItem({
    required int index,
    required IconData icon,
    required String title,
    bool isDesktop = false,
  }) {
    final isActive = _activeServiceIndex == index;
    return HoverableServiceItem(
      index: index,
      icon: icon,
      title: title,
      isActive: isActive,
      isDesktop: isDesktop,
      onTap: () {
        setState(() {
          _activeServiceIndex = isActive ? -1 : index;
        });
      },
    );
  }
}

/// A stateful wrapper that provides hover interactions (scaling, cursor styling)
/// locally to each service item in the list.
class HoverableServiceItem extends StatefulWidget {
  final int index;
  final IconData icon;
  final String title;
  final bool isActive;
  final bool isDesktop;
  final VoidCallback onTap;

  const HoverableServiceItem({
    super.key,
    required this.index,
    required this.icon,
    required this.title,
    required this.isActive,
    required this.isDesktop,
    required this.onTap,
  });

  @override
  State<HoverableServiceItem> createState() => _HoverableServiceItemState();
}

class _HoverableServiceItemState extends State<HoverableServiceItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    // Desktop layout uses a fixed base scale, while mobile uses screen proportion scale
    final double scale =
        widget.isDesktop ? 1.2 : (screenWidth / 390.0).clamp(0.8, 1.3);

    final double outerWidth = (widget.isDesktop ? 70.0 : 54.0) * scale;
    final double circleSize = 48 * scale;
    final double iconSize = 22 * scale;
    final double fontSize = (widget.isDesktop ? 10.0 : 9.0) * scale;
    final double spacingHeight = 6 * scale;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: outerWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.isActive || _isHovered
                          ? const Color(0xFF0F4C81)
                          : const Color(0xFFE2E8F0),
                      width: widget.isActive || _isHovered
                          ? (2.0 * scale)
                          : (1.0 * scale),
                    ),
                    boxShadow: widget.isActive || _isHovered
                        ? [
                            BoxShadow(
                              color: const Color(0xFF0F4C81)
                                  .withValues(alpha: 0.15),
                              blurRadius: 8 * scale,
                              offset: Offset(0, 4 * scale),
                            )
                          ]
                        : [],
                  ),
                  child: Icon(
                    widget.icon,
                    color: const Color(0xFF0D47A1),
                    size: iconSize,
                  ),
                ),
                SizedBox(height: spacingHeight),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF0D47A1),
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
