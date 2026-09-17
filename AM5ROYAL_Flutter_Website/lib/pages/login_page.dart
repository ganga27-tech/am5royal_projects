import 'package:flutter/material.dart';

import '../core/constants/app_assets.dart';
import '../features/auth/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.onRegisterPressed,
    this.onLoginSuccess,
  });

  final VoidCallback? onRegisterPressed;
  final VoidCallback? onLoginSuccess;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  final AuthService _auth = AuthService.instance;

  bool _useMobile = true;
  bool _otpSent = false;
  bool _isLoading = false;

  String? _errorMessage;

  static const Color backgroundStart = Color(0xFFF9EBD1);
  static const Color backgroundEnd = Color(0xFFFCEFDD);

  static const Color navy = Color(0xFF082B5C);
  static const Color royalBlue = Color(0xFF0B4EA2);
  static const Color gold = Color(0xFFF5B301);

  // ===========================================================================
  // SEND OTP
  // ===========================================================================

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();

    final FormState? form = _formKey.currentState;

    if (form == null || !form.validate()) {
      return;
    }

    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _auth.sendOtp(
        mobile: _useMobile ? _mobileController.text.trim() : null,
        email: _useMobile ? null : _emailController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _otpSent = true;
        _errorMessage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = _auth.friendlyError(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ===========================================================================
  // VERIFY OTP
  // ===========================================================================

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();

    if (_isLoading) {
      return;
    }

    final String otp = _otpController.text.trim();

    if (otp.length != 5 || !RegExp(r'^[0-9]{5}$').hasMatch(otp)) {
      setState(() {
        _errorMessage = 'Enter the 5-digit OTP.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _auth.verifyOtp(
        mobile: _useMobile ? _mobileController.text.trim() : null,
        email: _useMobile ? null : _emailController.text.trim(),
        otp: otp,
      );

      if (!mounted) {
        return;
      }

      // Login success is handled by the parent/app.
      // Do NOT use Navigator.pop() here.
      widget.onLoginSuccess?.call();
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = _auth.friendlyError(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ===========================================================================
  // SWITCH MOBILE / EMAIL
  // ===========================================================================

  void _switchLoginMethod(bool mobile) {
    if (_isLoading) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _useMobile = mobile;
      _otpSent = false;
      _otpController.clear();
      _errorMessage = null;

      if (mobile) {
        _emailController.clear();
      } else {
        _mobileController.clear();
      }
    });
  }

  // ===========================================================================
  // MOBILE VALIDATION
  // ===========================================================================

  String? _validateMobile(String? value) {
    final String mobile = value?.trim() ?? '';

    if (mobile.isEmpty) {
      return 'Please enter your mobile number';
    }

    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(mobile)) {
      return 'Enter a valid 10-digit mobile number';
    }

    return null;
  }

  // ===========================================================================
  // EMAIL VALIDATION
  // ===========================================================================

  String? _validateEmail(String? value) {
    final String email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your email address';
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void dispose() {
    _mobileController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final bool desktop = width >= 900;

    return Scaffold(
      backgroundColor: backgroundStart,
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: desktop ? 30 : 20,
                vertical: 30,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1050,
                ),
                child: desktop
                    ? _DesktopLoginLayout(
                        form: _buildLoginCard(),
                      )
                    : _buildLoginCard(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // LOGIN CARD
  // ===========================================================================

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        maxWidth: 480,
      ),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0x180B4EA2),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18082B5C),
            blurRadius: 35,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // LOGO
            Center(
              child: Image.asset(
                AppAssets.logo,
                height: 52,
                errorBuilder: (_, __, ___) {
                  return Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          navy,
                          royalBlue,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: const Icon(
                      Icons.home_repair_service_rounded,
                      color: gold,
                      size: 34,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // TITLE
            const Text(
              'Welcome Back',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: navy,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.7,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Login with OTP to continue with AM5 ROYAL',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF66778D),
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 26),

            // MOBILE / EMAIL SELECTOR
            _LoginMethodSelector(
              useMobile: _useMobile,
              onMobilePressed: () {
                _switchLoginMethod(true);
              },
              onEmailPressed: () {
                _switchLoginMethod(false);
              },
            ),

            const SizedBox(height: 22),

            // MOBILE / EMAIL FIELD
            AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 220,
              ),
              child: _useMobile ? _buildMobileField() : _buildEmailField(),
            ),

            // OTP FIELD
            if (_otpSent) ...[
              const SizedBox(height: 16),
              _buildOtpField(),
            ],

            // ERROR MESSAGE
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              _buildErrorMessage(),
            ],

            const SizedBox(height: 18),

            // MAIN BUTTON
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed:
                    _isLoading ? null : (_otpSent ? _verifyOtp : _sendOtp),
                style: ElevatedButton.styleFrom(
                  backgroundColor: royalBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF9DB5D2),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        _otpSent ? 'Verify & Login' : 'Send OTP',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),

            // RESEND OTP
            if (_otpSent) ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: _isLoading ? null : _sendOtp,
                child: const Text(
                  'Resend OTP',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 22),

            // REGISTER LINK
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account?",
                  style: TextStyle(
                    color: Color(0xFF66778D),
                    fontSize: 13,
                  ),
                ),
                TextButton(
                  onPressed: _isLoading ? null : widget.onRegisterPressed,
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // OTP FIELD
  // ===========================================================================

  Widget _buildOtpField() {
    return TextFormField(
      controller: _otpController,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      maxLength: 5,
      autofocus: true,
      onFieldSubmitted: (_) {
        if (!_isLoading) {
          _verifyOtp();
        }
      },
      decoration: InputDecoration(
        labelText: 'Enter OTP',
        hintText: '5-digit OTP',
        counterText: '',
        prefixIcon: const Icon(
          Icons.lock_clock_outlined,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFD),
        border: _fieldBorder(),
        enabledBorder: _fieldBorder(),
        focusedBorder: _focusedBorder(),
      ),
    );
  }

  // ===========================================================================
  // ERROR MESSAGE
  // ===========================================================================

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0x22D32F2F),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.error_outline_rounded,
              size: 18,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // MOBILE FIELD
  // ===========================================================================

  Widget _buildMobileField() {
    return TextFormField(
      key: const ValueKey<String>('mobile'),
      controller: _mobileController,
      validator: _validateMobile,
      enabled: !_otpSent && !_isLoading,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      maxLength: 10,
      decoration: InputDecoration(
        labelText: 'Mobile Number',
        hintText: 'Enter your mobile number',
        counterText: '',
        prefixIcon: const Icon(
          Icons.phone_android_outlined,
        ),
        prefixText: '+91  ',
        filled: true,
        fillColor: const Color(0xFFF8FAFD),
        border: _fieldBorder(),
        enabledBorder: _fieldBorder(),
        focusedBorder: _focusedBorder(),
        errorBorder: _errorBorder(),
        focusedErrorBorder: _focusedErrorBorder(),
      ),
    );
  }

  // ===========================================================================
  // EMAIL FIELD
  // ===========================================================================

  Widget _buildEmailField() {
    return TextFormField(
      key: const ValueKey<String>('email'),
      controller: _emailController,
      validator: _validateEmail,
      enabled: !_otpSent && !_isLoading,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Email Address',
        hintText: 'Enter your email address',
        prefixIcon: const Icon(
          Icons.email_outlined,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFD),
        border: _fieldBorder(),
        enabledBorder: _fieldBorder(),
        focusedBorder: _focusedBorder(),
        errorBorder: _errorBorder(),
        focusedErrorBorder: _focusedErrorBorder(),
      ),
    );
  }

  // ===========================================================================
  // INPUT BORDERS
  // ===========================================================================

  OutlineInputBorder _fieldBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(
        color: Color(0x160B4EA2),
      ),
    );
  }

  OutlineInputBorder _focusedBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(
        color: royalBlue,
        width: 1.5,
      ),
    );
  }

  OutlineInputBorder _errorBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(
        color: Colors.redAccent,
      ),
    );
  }

  OutlineInputBorder _focusedErrorBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(
        color: Colors.redAccent,
        width: 1.5,
      ),
    );
  }
}

// ============================================================================
// DESKTOP LOGIN LAYOUT
// ============================================================================

class _DesktopLoginLayout extends StatelessWidget {
  const _DesktopLoginLayout({
    required this.form,
  });

  final Widget form;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 70),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to\nAM5 ROYAL',
                  style: TextStyle(
                    color: Color(0xFF082B5C),
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                SizedBox(height: 18),
                Text(
                  'Your trusted platform for reliable home and business services.',
                  style: TextStyle(
                    color: Color(0xFF536985),
                    fontSize: 16,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ),
        form,
      ],
    );
  }
}

// ============================================================================
// LOGIN METHOD SELECTOR
// ============================================================================

class _LoginMethodSelector extends StatelessWidget {
  const _LoginMethodSelector({
    required this.useMobile,
    required this.onMobilePressed,
    required this.onEmailPressed,
  });

  final bool useMobile;
  final VoidCallback onMobilePressed;
  final VoidCallback onEmailPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _MethodButton(
              title: 'Mobile',
              icon: Icons.phone_android_rounded,
              selected: useMobile,
              onPressed: onMobilePressed,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _MethodButton(
              title: 'Email',
              icon: Icons.email_outlined,
              selected: !useMobile,
              onPressed: onEmailPressed,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// METHOD BUTTON
// ============================================================================

class _MethodButton extends StatelessWidget {
  const _MethodButton({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(
        milliseconds: 180,
      ),
      height: 43,
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
      ),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 17,
        ),
        label: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
