import 'dart:async';
import 'dart:convert';
import '../../../../core/network/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/auth_storage_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:new_version_plus/new_version_plus.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/onboarding_navigation_service.dart';
import '../../../../core/services/payment_session_service.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _authResolved = false;
  bool _isAuthenticated = false;
  bool _timerFinished = false;

  // Onboarding API Status variables
  bool _otpVerified = false;
  bool _servicesAdded = false;
  bool _availabilityAdded = false;
  bool _registrationDone = false;
  bool _businessRegistrationDone = false;
  bool _subscription = false;
  String _vendorStatus = 'active';

  // Version check variables
  bool _needsForceUpdate = false;
  String _currentVersion = "";
  String _requiredVersion = "";
  String _updateUrl = "";
  String _updateMessage = "";

  @override
  void initState() {
    super.initState();

    // Animations setup
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();

    // Trigger session onboarding check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOnboardingAndSession();
    });

    // Min splash timer (3 seconds)
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _timerFinished = true;
        });
        _checkAndNavigate();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkOnboardingAndSession() async {
    try {
      // Eagerly resolve ApiClient to guarantee Dio is fully configured
      di.sl<ApiClient>();

      final paymentSession = di.sl<PaymentSessionService>();
      final pendingPayment = await paymentSession.getActiveSession();
      if (pendingPayment != null && pendingPayment.checkoutOpened) {
        if (mounted) {
          setState(() {
            _authResolved = true;
            _timerFinished = true;
          });
          context.go('${AppRoutes.subscription}?recover=1');
        }
        return;
      }

      // 1. Force update check
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersionStr = packageInfo.version; // e.g. "1.1.4"

        final newVersion = NewVersionPlus(
          iOSId: packageInfo.packageName,
          androidId: packageInfo.packageName,
        );

        final status = await newVersion.getVersionStatus();
        if (status != null) {
          final requiredVersionStr = status.storeVersion;
          final forceUpdate = status.canUpdate;
          final updateUrl = status.appStoreLink;
          final message = status.releaseNotes ??
              'A critical update is available to keep your vendor app running smoothly. Please update to continue.';

          if (forceUpdate &&
              _isVersionLessThan(currentVersionStr, requiredVersionStr)) {
            if (mounted) {
              setState(() {
                _needsForceUpdate = true;
                _currentVersion = currentVersionStr;
                _requiredVersion = requiredVersionStr;
                _updateUrl = updateUrl;
                _updateMessage = message;
                _authResolved = true;
              });
              _checkAndNavigate();
            }
            return;
          }
        }
      } catch (e) {
        debugPrint('Splash Force Update check failed: $e');
      }

      final authStorage = di.sl<AuthStorageService>();
      final token = authStorage.getAccessToken();
      debugPrint(
          'Splash Onboarding Check: Cached token exists? ${token != null && token.isNotEmpty}');

      if (token != null && token.isNotEmpty) {
        final role = authStorage.getUserRole();
        if (role != null && role.isNotEmpty) {
          if (role == 'admin') {
            if (mounted) {
              setState(() {
                _isAuthenticated = true;
                _authResolved = true;
              });
              context.go(AppRoutes.adminDashboard);
            }
            return;
          } else if (role == 'marketing' ||
              role == 'marketing_team' ||
              role == 'field_sales') {
            if (mounted) {
              setState(() {
                _isAuthenticated = true;
                _authResolved = true;
              });
              context.go(AppRoutes.marketingDashboard);
            }
            return;
          }
          // Vendor role: continue to onboarding-status sync below.
        }

        final dio = di.sl<Dio>();
        debugPrint('Splash Onboarding Check: Requesting onboarding status...');
        final response = await dio.get('/vendors/me/onboarding-status');
        debugPrint(
            'Splash Onboarding Check: Status code ${response.statusCode}, raw data: ${response.data}');

        if (response.statusCode == 200) {
          var data = response.data;
          if (data is String) {
            data = jsonDecode(data);
          }

          final bool otpVerified = data['otp_verified'] ?? false;
          final bool servicesAdded = data['services_added'] ?? false;
          final bool availabilityAdded = data['availability_added'] ?? false;
          final bool registrationDone = data['registration_done'] ?? false;
          final bool businessRegistrationDone =
              data['business_registration_done'] ?? false;
          final bool subscription = data['subscription'] ?? false;
          final String vendorStatus = data['status']?.toString() ?? 'active';

          debugPrint('Splash Onboarding Parsed values: '
              'otpVerified=$otpVerified, '
              'servicesAdded=$servicesAdded, '
              'availabilityAdded=$availabilityAdded, '
              'registrationDone=$registrationDone, '
              'businessRegistrationDone=$businessRegistrationDone, '
              'subscription=$subscription');

          if (mounted) {
            setState(() {
              _isAuthenticated = true;
              _otpVerified = otpVerified;
              _servicesAdded = servicesAdded;
              _availabilityAdded = availabilityAdded;
              _registrationDone = registrationDone;
              _businessRegistrationDone = businessRegistrationDone;
              _subscription = subscription;
              _vendorStatus = vendorStatus;
              _authResolved = true;
            });
            _checkAndNavigate();
          }
          return;
        }
      }
    } catch (e) {
      debugPrint('Splash Onboarding Status check failed with exception: $e');
    }

    if (mounted) {
      setState(() {
        _isAuthenticated = false;
        _authResolved = true;
      });
      _checkAndNavigate();
    }
  }

  bool _isVersionLessThan(String current, String required) {
    try {
      List<int> currentParts =
          current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      List<int> requiredParts =
          required.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      for (int i = 0; i < requiredParts.length; i++) {
        int currentPart = i < currentParts.length ? currentParts[i] : 0;
        int requiredPart = requiredParts[i];
        if (currentPart < requiredPart) return true;
        if (currentPart > requiredPart) return false;
      }
    } catch (_) {}
    return false;
  }

  Future<void> _checkAndNavigate() async {
    if (_timerFinished && _authResolved) {
      if (_needsForceUpdate) {
        context.go(
          AppRoutes.forceUpdate,
          extra: {
            'currentVersion': _currentVersion,
            'requiredVersion': _requiredVersion,
            'updateUrl': _updateUrl,
            'message': _updateMessage,
          },
        );
        return;
      }
      if (_isAuthenticated) {
        await OnboardingNavigationService.navigateFromStatusData(
          context,
          {
            'otp_verified': _otpVerified,
            'services_added': _servicesAdded,
            'availability_added': _availabilityAdded,
            'registration_done': _registrationDone,
            'business_registration_done': _businessRegistrationDone,
            'subscription': _subscription,
            'status': _vendorStatus,
          },
        );
      } else {
        context.go(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Indian Monuments at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SvgPicture.asset(
              'assets/images/Indian Monuments.svg',
              fit: BoxFit.fitWidth,
              width: MediaQuery.of(context).size.width,
            ),
          ),
          // Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Main Logo
                    Image.asset(
                      'assets/images/AM5 ROYAL TM logo.png',
                      height: 120,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/am5royal_logo.png',
                          height: 120,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox.shrink(),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // App Name Text
                    Text(
                      'AM5 ROYAL',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFD4AF37), // Golden
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Tagline
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'The Royal Vision of MSKGRC',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Loading indicator
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFFD4AF37)
                              .withValues(alpha: 0.8), // Gold progress
                        ),
                      ),
                    ),
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
