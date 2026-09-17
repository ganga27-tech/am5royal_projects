import 'package:flutter/material.dart';

import '../features/auth/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
    this.onLoginPressed,
    this.onRegisterSuccess,
  });

  final VoidCallback? onLoginPressed;
  final VoidCallback? onRegisterSuccess;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  final AuthService _auth = AuthService.instance;

  bool _otpSent = false;
  bool _acceptedTerms = false;
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

    if (!_acceptedTerms) {
      _showMessage(
        'Please accept the Terms & Conditions.',
        isError: true,
      );
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
      final String mobile = _mobileController.text.trim();
      final String email = _emailController.text.trim();

      await _auth.sendOtp(
        mobile: mobile.isNotEmpty ? mobile : null,
        email: email.isNotEmpty ? email : null,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _otpSent = true;
        _errorMessage = null;
      });

      _showMessage('OTP sent successfully.');
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
  // VERIFY OTP + REGISTER
  // ===========================================================================

  Future<void> _verifyAndRegister() async {
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

    if (!_acceptedTerms) {
      _showMessage(
        'Please accept the Terms & Conditions.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String mobile = _mobileController.text.trim();
      final String email = _emailController.text.trim();
      final String fullName = _nameController.text.trim();

      final bool isNewUser = await _auth.verifyOtp(
        mobile: mobile.isNotEmpty ? mobile : null,
        email: email.isNotEmpty ? email : null,
        otp: otp,
      );

      if (fullName.isNotEmpty) {
        await _auth.updateProfile(
          fullName: fullName,
        );
      } else if (isNewUser) {
        await _auth.updateProfile(
          fullName: 'Customer',
        );
      }

      if (!mounted) {
        return;
      }

      // Important:
      // Do NOT call Navigator.pop() here.
      // Parent/app handles successful registration navigation.
      widget.onRegisterSuccess?.call();
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
  // MESSAGE
  // ===========================================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red.shade700 : navy,
      ),
    );
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void dispose() {
    _nameController.dispose();
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
    final bool desktop = width >= 850;

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
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: desktop ? 30 : 18,
              vertical: desktop ? 35 : 20,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 480,
                ),
                child: _buildRegisterCard(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // REGISTER CARD
  // ===========================================================================

  Widget _buildRegisterCard() {
    final bool mobileEntered = _mobileController.text.trim().isNotEmpty;

    final bool emailEntered = _emailController.text.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0x18082B5C),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22082B5C),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -----------------------------------------------------------------
            // HEADER
            // -----------------------------------------------------------------

            const Center(
              child: Icon(
                Icons.person_add_alt_1_rounded,
                size: 52,
                color: royalBlue,
              ),
            ),

            const SizedBox(height: 18),

            const Center(
              child: Text(
                'Create Account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: navy,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            const SizedBox(height: 6),

            const Center(
              child: Text(
                'Register with OTP to get started with AM5 ROYAL',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF65758B),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 26),

            // -----------------------------------------------------------------
            // FULL NAME
            // -----------------------------------------------------------------

            TextFormField(
              controller: _nameController,
              enabled: !_isLoading,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(
                hint: 'Full name',
                icon: Icons.person_outline_rounded,
              ),
              validator: (value) {
                final String name = value?.trim() ?? '';

                if (name.isEmpty) {
                  return 'Enter your name';
                }

                if (name.length < 2) {
                  return 'Enter a valid name';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // -----------------------------------------------------------------
            // MOBILE
            // -----------------------------------------------------------------

            TextFormField(
              controller: _mobileController,
              enabled: !emailEntered && !_otpSent && !_isLoading,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              maxLength: 10,
              onChanged: (_) {
                if (mounted) {
                  setState(() {});
                }
              },
              decoration: _inputDecoration(
                hint: 'Mobile number',
                icon: Icons.phone_outlined,
              ).copyWith(
                counterText: '',
                prefixText: '+91 ',
              ),
              validator: (value) {
                final String mobile = value?.trim() ?? '';

                final String email = _emailController.text.trim();

                if (mobile.isEmpty && email.isEmpty) {
                  return 'Enter mobile number or email';
                }

                if (mobile.isNotEmpty &&
                    !RegExp(r'^[6-9][0-9]{9}$').hasMatch(mobile)) {
                  return 'Enter a valid 10-digit mobile number';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // -----------------------------------------------------------------
            // EMAIL
            // -----------------------------------------------------------------

            TextFormField(
              controller: _emailController,
              enabled: !mobileEntered && !_otpSent && !_isLoading,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onChanged: (_) {
                if (mounted) {
                  setState(() {});
                }
              },
              decoration: _inputDecoration(
                hint: 'Email address',
                icon: Icons.email_outlined,
              ),
              validator: (value) {
                final String email = value?.trim() ?? '';

                final String mobile = _mobileController.text.trim();

                if (email.isEmpty && mobile.isEmpty) {
                  return 'Enter mobile number or email';
                }

                if (email.isNotEmpty &&
                    !RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(email)) {
                  return 'Enter a valid email address';
                }

                return null;
              },
            ),

            // -----------------------------------------------------------------
            // OTP
            // -----------------------------------------------------------------

            if (_otpSent) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _otpController,
                enabled: !_isLoading,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                maxLength: 5,
                autofocus: true,
                onFieldSubmitted: (_) {
                  if (!_isLoading) {
                    _verifyAndRegister();
                  }
                },
                decoration: _inputDecoration(
                  hint: 'Enter 5-digit OTP',
                  icon: Icons.lock_clock_outlined,
                ).copyWith(
                  counterText: '',
                ),
              ),
            ],

            // -----------------------------------------------------------------
            // ERROR
            // -----------------------------------------------------------------

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              _buildErrorMessage(),
            ],

            const SizedBox(height: 14),

            // -----------------------------------------------------------------
            // TERMS
            // -----------------------------------------------------------------

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _acceptedTerms,
                  activeColor: royalBlue,
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _acceptedTerms = value ?? false;
                          });
                        },
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 11,
                    ),
                    child: Text(
                      'I agree to the Terms & Conditions and Privacy Policy.',
                      style: TextStyle(
                        color: Color(0xFF536985),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // -----------------------------------------------------------------
            // MAIN BUTTON
            // -----------------------------------------------------------------

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : (_otpSent ? _verifyAndRegister : _sendOtp),
                style: ElevatedButton.styleFrom(
                  backgroundColor: royalBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF9DB5D2),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        _otpSent ? 'Verify & Create Account' : 'Send OTP',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),

            // -----------------------------------------------------------------
            // RESEND OTP
            // -----------------------------------------------------------------

            if (_otpSent) ...[
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  child: const Text(
                    'Resend OTP',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 18),

            // -----------------------------------------------------------------
            // LOGIN
            // -----------------------------------------------------------------

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account?',
                  style: TextStyle(
                    color: Color(0xFF65758B),
                    fontSize: 13,
                  ),
                ),
                TextButton(
                  onPressed: _isLoading ? null : widget.onLoginPressed,
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: royalBlue,
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
  // ERROR MESSAGE
  // ===========================================================================

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
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
          const Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: Colors.redAccent,
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
  // INPUT DECORATION
  // ===========================================================================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: royalBlue,
        size: 20,
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFD),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: Color(0xFFE0E7EF),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: Color(0xFFE0E7EF),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: royalBlue,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.5,
        ),
      ),
    );
  }
}
