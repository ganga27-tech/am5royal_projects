import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';

import '../../../../core/design_system/am5_colors.dart';
import '../../../../core/design_system/am5_spacing.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

enum _BookingOtpStep { loginPhone, loginOtp, bookingOtp }

/// Runs login OTP (if needed) then booking-security OTP before confirming.
class BookingOtpSheet extends StatefulWidget {
  const BookingOtpSheet({super.key, required this.isAuthenticated});

  final bool isAuthenticated;

  static Future<bool> show(BuildContext context) async {
    final isAuthenticated =
        context.read<AuthBloc>().state.status == AuthStatus.authenticated;
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookingOtpSheet(isAuthenticated: isAuthenticated),
    );
    return result == true;
  }

  @override
  State<BookingOtpSheet> createState() => _BookingOtpSheetState();
}

class _BookingOtpSheetState extends State<BookingOtpSheet> {
  late _BookingOtpStep _step;
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _phone;

  @override
  void initState() {
    super.initState();
    _step = widget.isAuthenticated ? _BookingOtpStep.bookingOtp : _BookingOtpStep.loginPhone;
    if (widget.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _sendBookingOtp());
    }
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  AuthApi get _authApi => context.read<AuthApi>();

  DeviceInfo get _device => context.read<DeviceInfo>();

  Future<void> _sendLoginOtp() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.length < 10) {
      setState(() => _error = 'Enter a valid 10-digit mobile number');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authApi.requestOtp(identifier: phone, platform: _device.platform ?? 'mobile');
      setState(() {
        _phone = phone;
        _step = _BookingOtpStep.loginOtp;
        _otpCtrl.clear();
        _loading = false;
      });
    } on Failure catch (f) {
      setState(() {
        _loading = false;
        _error = f.message;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = 'Could not send OTP. Please try again.';
      });
    }
  }

  Future<void> _verifyLoginOtp() async {
    final code = _otpCtrl.text.trim();
    if (code.length < 4) {
      setState(() => _error = 'Enter the OTP sent to your phone');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authApi.verifyOtp(
        destination: _phone!,
        code: code,
        device: _device,
      );
      if (!mounted) return;
      context.read<AuthBloc>().add(const AuthSessionRefreshed());
      setState(() {
        _step = _BookingOtpStep.bookingOtp;
        _otpCtrl.clear();
        _loading = false;
      });
      await _sendBookingOtp();
    } on Failure catch (f) {
      setState(() {
        _loading = false;
        _error = f.message;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = 'Invalid OTP. Please try again.';
      });
    }
  }

  Future<void> _sendBookingOtp() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authApi.sendBookingSecurityOtp();
      if (mounted) {
        setState(() => _loading = false);
      }
    } on Failure catch (f) {
      setState(() {
        _loading = false;
        _error = f.message;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = 'Could not send booking OTP. Please try again.';
      });
    }
  }

  Future<void> _verifyBookingOtp() async {
    final code = _otpCtrl.text.trim();
    if (code.length < 4) {
      setState(() => _error = 'Enter the booking confirmation OTP');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authApi.verifyBookingSecurityOtp(code: code);
      if (mounted) Navigator.of(context).pop(true);
    } on Failure catch (f) {
      setState(() {
        _loading = false;
        _error = f.message;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = 'Invalid OTP. Please try again.';
      });
    }
  }

  void _onPrimaryAction() {
    switch (_step) {
      case _BookingOtpStep.loginPhone:
        _sendLoginOtp();
      case _BookingOtpStep.loginOtp:
        _verifyLoginOtp();
      case _BookingOtpStep.bookingOtp:
        _verifyBookingOtp();
    }
  }

  void _onResend() {
    switch (_step) {
      case _BookingOtpStep.loginPhone:
        _sendLoginOtp();
      case _BookingOtpStep.loginOtp:
        if (_phone != null) {
          _authApi.requestOtp(identifier: _phone!, platform: _device.platform ?? 'mobile');
        }
      case _BookingOtpStep.bookingOtp:
        _sendBookingOtp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Am5Colors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(
          Am5Spacing.lg,
          Am5Spacing.md,
          Am5Spacing.lg,
          Am5Spacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Am5Colors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: Am5Spacing.lg),
            Text(_title, style: theme.textTheme.titleLarge),
            const SizedBox(height: Am5Spacing.sm),
            Text(_subtitle, style: theme.textTheme.bodyMedium),
            const SizedBox(height: Am5Spacing.lg),
            if (_step == _BookingOtpStep.loginPhone) ...[
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Mobile number',
                  hintText: '10-digit mobile number',
                  prefixText: '+91 ',
                  counterText: '',
                ),
              ),
            ] else ...[
              TextField(
                controller: _otpCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                autofocus: true,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'OTP',
                  hintText: 'Enter ${_step == _BookingOtpStep.loginOtp ? 'login' : 'booking'} OTP',
                ),
              ),
              const SizedBox(height: Am5Spacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _loading ? null : _onResend,
                  child: const Text('Resend OTP'),
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: Am5Spacing.sm),
              Text(
                _error!,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
              ),
            ],
            const SizedBox(height: Am5Spacing.lg),
            FilledButton(
              onPressed: _loading ? null : _onPrimaryAction,
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_primaryLabel),
            ),
          ],
        ),
      ),
    );
  }

  String get _title => switch (_step) {
        _BookingOtpStep.loginPhone => 'Sign in to continue',
        _BookingOtpStep.loginOtp => 'Verify login OTP',
        _BookingOtpStep.bookingOtp => 'Confirm your booking',
      };

  String get _subtitle => switch (_step) {
        _BookingOtpStep.loginPhone =>
          'Enter your mobile number. We will send a one-time code to sign you in.',
        _BookingOtpStep.loginOtp =>
          'Enter the OTP sent to +91 $_phone to verify your identity.',
        _BookingOtpStep.bookingOtp =>
          'Enter the booking confirmation OTP sent to your registered mobile number.',
      };

  String get _primaryLabel => switch (_step) {
        _BookingOtpStep.loginPhone => 'Send OTP',
        _BookingOtpStep.loginOtp => 'Verify & continue',
        _BookingOtpStep.bookingOtp => 'Confirm booking',
      };
}
