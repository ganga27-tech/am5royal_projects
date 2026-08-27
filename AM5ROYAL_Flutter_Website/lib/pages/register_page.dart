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

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      _showMessage('Please accept the Terms & Conditions.', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _auth.sendOtp(
        mobile: _mobileController.text.trim().isNotEmpty
            ? _mobileController.text.trim()
            : null,
        email: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
      );
      if (!mounted) return;
      setState(() => _otpSent = true);
      _showMessage('OTP sent successfully.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = _auth.friendlyError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyAndRegister() async {
    FocusScope.of(context).unfocus();
    final String otp = _otpController.text.trim();
    if (otp.length != 5) {
      setState(() => _errorMessage = 'Enter the 5-digit OTP.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bool isNewUser = await _auth.verifyOtp(
        mobile: _mobileController.text.trim().isNotEmpty
            ? _mobileController.text.trim()
            : null,
        email: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        otp: otp,
      );

      if (_nameController.text.trim().isNotEmpty) {
        await _auth.updateProfile(fullName: _nameController.text.trim());
      } else if (isNewUser) {
        await _auth.updateProfile(fullName: 'Customer');
      }

      if (!mounted) return;
      widget.onRegisterSuccess?.call();
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = _auth.friendlyError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red.shade700 : navy,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool desktop = MediaQuery.sizeOf(context).width >= 850;

    return Scaffold(
      backgroundColor: backgroundStart,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [backgroundStart, backgroundEnd],
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
                constraints: const BoxConstraints(maxWidth: 480),
                child: _buildRegisterCard(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterCard() {
    final bool mobileEntered = _mobileController.text.trim().isNotEmpty;
    final bool emailEntered = _emailController.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x18082B5C)),
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
            const Text(
              'Create Account',
              style: TextStyle(
                color: navy,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Register with OTP — same account as the AM5 ROYAL app',
              style: TextStyle(color: Color(0xFF65758B), fontSize: 13),
            ),
            const SizedBox(height: 25),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration(
                hint: 'Full name',
                icon: Icons.person_outline_rounded,
              ),
              validator: (value) {
                if ((value ?? '').trim().length < 2) {
                  return 'Enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _mobileController,
              enabled: !emailEntered && !_otpSent,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              onChanged: (_) => setState(() {}),
              decoration: _inputDecoration(
                hint: 'Mobile number',
                icon: Icons.phone_outlined,
              ).copyWith(counterText: '', prefixText: '+91 '),
              validator: (value) {
                final mobile = value?.trim() ?? '';
                final email = _emailController.text.trim();
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
            TextFormField(
              controller: _emailController,
              enabled: !mobileEntered && !_otpSent,
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => setState(() {}),
              decoration: _inputDecoration(
                hint: 'Email address (optional)',
                icon: Icons.email_outlined,
              ),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty && _mobileController.text.trim().isEmpty) {
                  return 'Enter mobile number or email';
                }
                if (email.isNotEmpty &&
                    !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            if (_otpSent) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 5,
                decoration: _inputDecoration(
                  hint: 'Enter 5-digit OTP',
                  icon: Icons.lock_clock_outlined,
                ).copyWith(counterText: ''),
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _acceptedTerms,
                  activeColor: royalBlue,
                  onChanged: (value) =>
                      setState(() => _acceptedTerms = value ?? false),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 11),
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
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : (_otpSent ? _verifyAndRegister : _sendOtp),
                style: ElevatedButton.styleFrom(
                  backgroundColor: royalBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 21,
                        height: 21,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _otpSent ? 'Verify & Create Account' : 'Send OTP',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account?',
                  style: TextStyle(color: Color(0xFF65758B), fontSize: 13),
                ),
                TextButton(
                  onPressed: widget.onLoginPressed,
                  child: const Text(
                    'Login',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: royalBlue, size: 20),
      filled: true,
      fillColor: const Color(0xFFF8FAFD),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Color(0xFFE0E7EF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Color(0xFFE0E7EF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: royalBlue, width: 1.5),
      ),
    );
  }
}
