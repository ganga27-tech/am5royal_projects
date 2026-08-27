import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/auth_storage_service.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class EmployeeLoginPage extends StatefulWidget {
  const EmployeeLoginPage({super.key});

  @override
  State<EmployeeLoginPage> createState() => _EmployeeLoginPageState();
}

class _EmployeeLoginPageState extends State<EmployeeLoginPage> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _identifierError;
  String? _passwordError;
  int _activeFeatureIndex = -1;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    bool hasError = false;

    if (identifier.isEmpty) {
      setState(
          () => _identifierError = 'Please enter your email or mobile number.');
      hasError = true;
    } else {
      setState(() => _identifierError = null);
    }

    if (password.length < 6) {
      setState(
          () => _passwordError = 'Password must be at least 6 characters.');
      hasError = true;
    } else {
      setState(() => _passwordError = null);
    }

    if (hasError) return;

    context.read<AuthBloc>().add(AuthEvent.loginEmployee(
          email: identifier,
          password: password,
        ));
  }

  Widget _buildFeatureItem({
    required int index,
    required IconData icon,
    required String title,
    bool isDesktop = false,
  }) {
    final isActive = _activeFeatureIndex == index;
    return HoverablePortalItem(
      index: index,
      icon: icon,
      title: title,
      isActive: isActive,
      isDesktop: isDesktop,
      onTap: () {
        setState(() {
          _activeFeatureIndex = isActive ? -1 : index;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          state.maybeWhen(
            loading: () => setState(() => _isLoading = true),
            success: (message, auth) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: const Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
              // Check the cached role in AuthStorageService
              final authStorage = di.sl<AuthStorageService>();
              final role = authStorage.getUserRole();
              if (role == 'admin') {
                context.go('/admin-dashboard');
              } else if (role == 'telecaller' || role == 'tele_caller') {
                context.go('/telecaller-dashboard');
              } else if (role == 'marketing' || role == 'marketing_team' || role == 'field_sales') {
                context.go('/marketing-dashboard');
              } else {
                context.go('/home');
              }
            },
            error: (message) {
              setState(() => _isLoading = false);
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
            orElse: () => setState(() => _isLoading = false),
          );
        },
        child: Stack(
          children: [
            // 1. Watercolor background image
            Positioned.fill(
              child: Image.asset(
                'assets/images/water.png',
                fit: BoxFit.cover,
                opacity: AlwaysStoppedAnimation(isDark ? 0.3 : 0.85),
              ),
            ),

            // 2. Subtle color blend overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            AppColors.darkBackground.withValues(alpha: 0.7),
                            AppColors.darkBackground.withValues(alpha: 0.5),
                            AppColors.darkBackground.withValues(alpha: 0.8),
                          ]
                        : [
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

            // 3. Responsive main layouts
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              // Top Brand elements
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      height: 100,
                      child: Image.asset(
                        'assets/images/AM5 ROYAL TM logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'AM5 ROYAL',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: isDark ? Colors.white : const Color(0xFF0C3D98),
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
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
                        Expanded(
                          child: Divider(
                            color: isDark ? AppColors.darkBorder : const Color(0xFF0C3D98),
                            thickness: 1.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 4,
                                color: isDark ? AppColors.accentLight : const Color(0xFF0C3D98),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'TRUST  •  QUALITY  •  LOYALTY',
                                style: GoogleFonts.outfit(
                                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF0C3D98),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.circle,
                                size: 4,
                                color: isDark ? AppColors.accentLight : const Color(0xFF0C3D98),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: isDark ? AppColors.darkBorder : const Color(0xFF0C3D98),
                            thickness: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Features header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: isDark ? AppColors.darkBorder : const Color(0xFF0C3D98),
                            thickness: 1.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            'PORTAL FEATURES',
                            style: GoogleFonts.outfit(
                              color: isDark ? AppColors.accentLight : const Color(0xFF0C3D98),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: isDark ? AppColors.darkBorder : const Color(0xFF0C3D98),
                            thickness: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Horizontal list of feature items
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFeatureItem(
                          index: 0,
                          icon: Icons.assignment_turned_in_outlined,
                          title: 'Task\nManager',
                        ),
                        const SizedBox(width: 12),
                        _buildFeatureItem(
                          index: 1,
                          icon: Icons.sync_alt_outlined,
                          title: 'Vendor\nSync',
                        ),
                        const SizedBox(width: 12),
                        _buildFeatureItem(
                          index: 2,
                          icon: Icons.analytics_outlined,
                          title: 'Analytics\nReports',
                        ),
                        const SizedBox(width: 12),
                        _buildFeatureItem(
                          index: 3,
                          icon: Icons.vpn_key_outlined,
                          title: 'Access\nKey',
                        ),
                        const SizedBox(width: 12),
                        _buildFeatureItem(
                          index: 4,
                          icon: Icons.monitor_heart_outlined,
                          title: 'System\nMonitor',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

              const Spacer(),

              // Card component
              _buildLoginCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, BoxConstraints constraints) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                // Left Column: Branding and portal features
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 60),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Top Brand Logo Image
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
                            color: isDark ? Colors.white : const Color(0xFF0D3B66),
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
                            Expanded(
                              child: Divider(
                                color: isDark ? AppColors.darkBorder : const Color(0xFF0C3D98),
                                thickness: 1.2,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 5,
                                    color: isDark ? AppColors.accentLight : const Color(0xFF0C3D98),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'TRUST  •  QUALITY  •  LOYALTY',
                                    style: GoogleFonts.outfit(
                                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF0C3D98),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.circle,
                                    size: 5,
                                    color: isDark ? AppColors.accentLight : const Color(0xFF0C3D98),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: isDark ? AppColors.darkBorder : const Color(0xFF0C3D98),
                                thickness: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),

                        // Features Header Section
                        Text(
                          'SYSTEM PORTAL FEATURES',
                          style: GoogleFonts.outfit(
                            color: isDark ? AppColors.accentLight : const Color(0xFF0C3D98),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Features Row / Wrap
                        Wrap(
                          spacing: 24,
                          runSpacing: 24,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildFeatureItem(
                              index: 0,
                              icon: Icons.assignment_turned_in_outlined,
                              title: 'Task\nManager',
                              isDesktop: true,
                            ),
                            _buildFeatureItem(
                              index: 1,
                              icon: Icons.sync_alt_outlined,
                              title: 'Vendor\nSync',
                              isDesktop: true,
                            ),
                            _buildFeatureItem(
                              index: 2,
                              icon: Icons.analytics_outlined,
                              title: 'Analytics\nReports',
                              isDesktop: true,
                            ),
                            _buildFeatureItem(
                              index: 3,
                              icon: Icons.vpn_key_outlined,
                              title: 'Access\nKey',
                              isDesktop: true,
                            ),
                            _buildFeatureItem(
                              index: 4,
                              icon: Icons.monitor_heart_outlined,
                              title: 'System\nMonitor',
                              isDesktop: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Right Column: Card container
                Expanded(
                  flex: 4,
                  child: Align(
                    alignment: Alignment.center,
                    child: _buildLoginCard(context, isDesktop: true),
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
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isDesktop) ...[
                  Center(
                    child: SizedBox(
                      height: 80,
                      child: Image.asset(
                        'assets/images/AM5 ROYAL TM logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  'Employee Portal',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: isDark ? Colors.white : const Color(0xFF0D3B66),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Login with your assigned credentials.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    height: 1.4,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 28),

                // Email/Mobile Label
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    ' Email or Mobile Number',
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

                // Email/Mobile Input
                TextField(
                  controller: _identifierController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    setState(() {}); // triggers switcher & clears error checks
                  },
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF2D3748),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter email or mobile number',
                    hintStyle: GoogleFonts.outfit(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.4)
                          : const Color(0xFFA0AEC0),
                      fontSize: 15,
                    ),
                    prefixIcon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        (_identifierController.text.trim().contains('@') ||
                                RegExp(r'[a-zA-Z]').hasMatch(
                                    _identifierController.text.trim()))
                            ? Icons.email_outlined
                            : Icons.smartphone_outlined,
                        key: ValueKey<bool>(
                          _identifierController.text.trim().contains('@') ||
                              RegExp(r'[a-zA-Z]')
                                  .hasMatch(_identifierController.text.trim()),
                        ),
                        color: isDark
                            ? AppColors.accentLight
                            : const Color(0xFF71717A),
                        size: 22,
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
                              : const Color(0xFF0C3D98),
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
                    errorText: _identifierError,
                    errorStyle: GoogleFonts.outfit(
                      color: Colors.redAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Password Label
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    ' Password',
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

                // Password Input
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onChanged: (value) {
                    if (_passwordError != null) {
                      setState(() {
                        _passwordError = null;
                      });
                    }
                  },
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF2D3748),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: GoogleFonts.outfit(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.4)
                          : const Color(0xFFA0AEC0),
                      fontSize: 15,
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: isDark
                          ? AppColors.accentLight
                          : const Color(0xFF71717A),
                      size: 22,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: isDark
                            ? AppColors.accentLight
                            : const Color(0xFF71717A),
                      ),
                      onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword),
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
                              : const Color(0xFF0C3D98),
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
                    errorText: _passwordError,
                    errorStyle: GoogleFonts.outfit(
                      color: Colors.redAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
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
                    onPressed: _isLoading ? null : _handleLogin,
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
                            'Login',
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Go to Vendor Login Link
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    style: TextButton.styleFrom(
                      foregroundColor: isDark
                          ? AppColors.accentLight
                          : const Color(0xFF0C3D98),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      'Go to Vendor Login',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
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
}

class HoverablePortalItem extends StatefulWidget {
  final int index;
  final IconData icon;
  final String title;
  final bool isActive;
  final bool isDesktop;
  final VoidCallback onTap;

  const HoverablePortalItem({
    super.key,
    required this.index,
    required this.icon,
    required this.title,
    required this.isActive,
    required this.isDesktop,
    required this.onTap,
  });

  @override
  State<HoverablePortalItem> createState() => _HoverablePortalItemState();
}

class _HoverablePortalItemState extends State<HoverablePortalItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double scale = widget.isDesktop ? 1.2 : 1.0;

    final double outerWidth = (widget.isDesktop ? 76.0 : 64.0) * scale;
    final double circleSize = 48 * scale;
    final double iconSize = 22 * scale;
    final double fontSize = (widget.isDesktop ? 10.0 : 9.0) * scale;

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
          child: SizedBox(
            width: outerWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.isActive || _isHovered
                          ? (isDark ? AppColors.accentLight : const Color(0xFF0C3D98))
                          : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
                      width: widget.isActive || _isHovered ? 2.0 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : const Color(0xFF0F4C81))
                            .withValues(alpha: widget.isActive || _isHovered ? 0.12 : 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      widget.icon,
                      color: widget.isActive || _isHovered
                          ? (isDark ? AppColors.accentLight : const Color(0xFF0C3D98))
                          : (isDark ? AppColors.darkTextSecondary : const Color(0xFF71717A)),
                      size: iconSize,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: fontSize,
                    fontWeight: widget.isActive || _isHovered
                        ? FontWeight.bold
                        : FontWeight.w500,
                    color: widget.isActive || _isHovered
                        ? (isDark ? Colors.white : const Color(0xFF0D3B66))
                        : (isDark ? AppColors.darkTextSecondary : const Color(0xFF71717A)),
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
