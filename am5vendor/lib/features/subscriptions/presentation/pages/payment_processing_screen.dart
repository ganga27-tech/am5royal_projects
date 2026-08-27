import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/onboarding_navigation_service.dart';
import '../../../../core/services/onboarding_session_guard.dart';
import '../../../../core/services/payment_session_service.dart';
import '../../../../core/utils/app_razorpay.dart';
import '../../../../core/utils/razorpay_checkout_options.dart';
import '../../../../core/utils/razorpay_checkout_helper.dart';
import '../../domain/usecases/recover_payment_usecase.dart';
import '../bloc/subscription_bloc.dart';
import '../bloc/subscription_event.dart';
import '../bloc/subscription_state.dart';

class PaymentProcessingScreen extends StatefulWidget {
  final String? orderId;
  final int? planId;
  final Map<String, dynamic>? orderData;
  final bool recoveryOnly;
  final bool fromOnboarding;

  const PaymentProcessingScreen({
    super.key,
    this.orderId,
    this.planId,
    this.orderData,
    this.recoveryOnly = false,
    this.fromOnboarding = false,
  });

  @override
  State<PaymentProcessingScreen> createState() =>
      _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen>
    with WidgetsBindingObserver {
  static const _maxRecoveryAttempts = 6;
  static const _recoveryDelay = Duration(seconds: 2);

  late AppRazorpay _razorpay;
  late SubscriptionBloc _subscriptionBloc;
  late PaymentSessionService _paymentSession;
  late RecoverPaymentUseCase _recoverPayment;

  String? _orderId;
  int? _planId;
  Map<String, dynamic>? _orderData;

  static const _razorpayPaymentCancelledCode = 2;

  bool _checkoutOpened = false;
  bool _isHandlingUpiReturn = false;
  bool _isRecovering = false;
  bool _isCompleted = false;
  String _statusMessage = 'Preparing secure checkout...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _paymentSession = di.sl<PaymentSessionService>();
    _recoverPayment = di.sl<RecoverPaymentUseCase>();
    _subscriptionBloc = di.sl<SubscriptionBloc>();

    _razorpay = getRazorpay();
    _razorpay.init(
      onSuccess: _handlePaymentSuccess,
      onError: _handlePaymentError,
      onExternalWallet: (_) {
        _isHandlingUpiReturn = false;
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    RazorpayCheckoutHelper.setAutoDismissEnabled(false);
    _razorpay.clear();
    _subscriptionBloc.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      return;
    }

    if (state == AppLifecycleState.resumed &&
        _checkoutOpened &&
        !_isCompleted) {
      _handleReturnFromUpiApp();
    }
  }

  Future<void> _handleReturnFromUpiApp() async {
    if (_isHandlingUpiReturn || _isRecovering || _isCompleted) return;
    _isHandlingUpiReturn = true;

    await RazorpayCheckoutHelper.dismissCheckout();
    _razorpay.clear();

    if (_isRecovering || _isCompleted) {
      _isHandlingUpiReturn = false;
      return;
    }

    if (mounted) {
      setState(() {
        _statusMessage = 'Verifying payment after returning from UPI app...';
      });
    }

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted || _isCompleted) {
      _isHandlingUpiReturn = false;
      return;
    }

    await _beginRecovery(
      reason: 'Verifying payment after returning from UPI app...',
    );
    _isHandlingUpiReturn = false;
  }

  Future<void> _bootstrap() async {
    await _hydrateSession();

    if (!mounted || _orderId == null || _planId == null) {
      if (mounted) context.go('/subscription');
      return;
    }

    if (widget.recoveryOnly || _checkoutOpened) {
      await RazorpayCheckoutHelper.dismissCheckout();
      await _beginRecovery(
        reason: 'Verifying your payment, please wait...',
      );
      return;
    }

    await _openCheckout();
  }

  Future<void> _hydrateSession() async {
    _orderId = widget.orderId;
    _planId = widget.planId;
    _orderData = widget.orderData;

    final session = await _paymentSession.getActiveSession();
    if (session != null) {
      _orderId ??= session.orderId;
      _planId ??= session.planId;
      _orderData ??= session.orderData;
      _checkoutOpened = session.checkoutOpened;
    }

    if (_orderId != null &&
        _planId != null &&
        _orderData != null &&
        !widget.recoveryOnly) {
      await _paymentSession.saveCheckoutSession(
        orderId: _orderId!,
        planId: _planId!,
        orderData: _orderData!,
      );
    }
  }

  Future<void> _openCheckout() async {
    if (_orderData == null || _orderId == null || _planId == null) {
      _showFailure('Unable to start payment. Please try again.');
      return;
    }

    setState(() {
      _statusMessage = 'Opening payment options...';
    });

    final amount = _orderData!['amount'];
    final parsedAmount = amount is int
        ? amount
        : int.tryParse(amount?.toString() ?? '') ?? 0;

    final options = await RazorpayCheckoutOptions.build(
      razorpayKey: 'rzp_live_TKoWIICulRFoyv',
      amount: parsedAmount,
      orderId: _orderId!,
      description: _orderData!['plan_name']?.toString() ?? 'Subscription',
      currency: _orderData!['currency']?.toString() ?? 'INR',
    );

    await _paymentSession.markCheckoutOpened();
    _checkoutOpened = true;
    await RazorpayCheckoutHelper.setAutoDismissEnabled(true);

    try {
      _razorpay.open(options);
      if (mounted) {
        setState(() {
          _statusMessage =
              'Complete payment in PhonePe, GPay, or Paytm.\nDo not close this screen.';
        });
      }
    } catch (e) {
      debugPrint('Razorpay open error: $e');
      await _beginRecovery(
        reason: 'Retrying payment verification...',
      );
    }
  }

  void _handlePaymentSuccess(
    String paymentId,
    String orderId,
    String signature,
  ) {
    if (_planId == null || _isCompleted) return;
    setState(() {
      _statusMessage = 'Confirming payment with server...';
    });
    _subscriptionBloc.add(
      VerifyPaymentEvent(
        paymentId: paymentId,
        orderId: orderId,
        signature: signature,
        planId: _planId!,
      ),
    );
  }

  void _handlePaymentError(String message, int? code) {
    if (_isCompleted) return;

    if (_isCheckoutCancelled(message, code)) {
      _restartCheckoutAfterCancel();
      return;
    }

    _handleReturnFromUpiApp();
  }

  bool _isCheckoutCancelled(String message, int? code) {
    if (code == _razorpayPaymentCancelledCode) return true;
    final normalized = message.toLowerCase();
    return normalized.contains('cancel') ||
        normalized.contains('dismiss') ||
        normalized.contains('closed');
  }

  Future<void> _restartCheckoutAfterCancel() async {
    if (_isCompleted) return;

    _isRecovering = false;
    _isHandlingUpiReturn = false;
    await RazorpayCheckoutHelper.dismissCheckout();
    _razorpay.clear();
    _checkoutOpened = false;

    if (!mounted) return;
    setState(() {
      _statusMessage = 'Reopening payment options...';
    });

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted || _isCompleted) return;
    await _openCheckout();
  }

  Future<void> _beginRecovery({required String reason}) async {
    if (_isRecovering || _isCompleted || _orderId == null || _planId == null) {
      return;
    }

    _isRecovering = true;
    if (mounted) {
      setState(() {
        _statusMessage = reason;
      });
    }

    for (var attempt = 0; attempt < _maxRecoveryAttempts; attempt++) {
      if (!mounted || _isCompleted) return;
      if (attempt > 0) {
        await Future.delayed(_recoveryDelay);
      }

      final recovered = await _tryRecoverPayment();
      if (recovered) return;

      final synced = await _trySyncFromOnboardingStatus();
      if (synced) return;

      if (mounted) {
        setState(() {
          _statusMessage =
              'Still verifying payment (${attempt + 1}/$_maxRecoveryAttempts)...';
        });
      }
    }

    _isRecovering = false;
    if (mounted && !_isCompleted) {
      _showFailure(
        'We could not confirm your payment yet. If money was deducted, please wait a minute and reopen the app.',
      );
    }
  }

  Future<bool> _tryRecoverPayment() async {
    if (_orderId == null || _planId == null) return false;

    final result = await _recoverPayment(
      RecoverPaymentParams(
        razorpayOrderId: _orderId!,
        planId: _planId!,
      ),
    );

    if (result.isRight()) {
      await _completeSuccess();
      return true;
    }
    return false;
  }

  Future<bool> _trySyncFromOnboardingStatus() async {
    try {
      final dio = di.sl<Dio>();
      final response = await dio.get('/vendors/me/onboarding-status');
      if (response.statusCode != 200) return false;

      var data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }
      if (data is! Map<String, dynamic>) return false;

      final subscription = data['subscription'] == true;
      final vendorStatus = data['status']?.toString() ?? '';

      if (subscription &&
          (OnboardingNavigationService.isVerificationPending(vendorStatus) ||
              vendorStatus.toLowerCase() == 'active')) {
        await _completeSuccess();
        return true;
      }
    } catch (e) {
      debugPrint('Onboarding sync during payment recovery failed: $e');
    }
    return false;
  }

  Future<void> _completeSuccess() async {
    if (_isCompleted) return;
    _isCompleted = true;
    _isRecovering = false;

    await RazorpayCheckoutHelper.dismissCheckout();
    _razorpay.clear();
    await RazorpayCheckoutHelper.setAutoDismissEnabled(false);

    await _paymentSession.clearSession();
    await OnboardingSessionGuard.instance.markPaymentCompleted();
    await di.sl<SharedPreferences>().setBool('subscription_completed', true);

    if (!mounted) return;
    context.go('/home');
  }

  Future<void> _returnToPlans() async {
    await RazorpayCheckoutHelper.dismissCheckout();
    _razorpay.clear();
    await RazorpayCheckoutHelper.setAutoDismissEnabled(false);
    await _paymentSession.clearSession();

    if (!mounted) return;
    context.go(
      '/subscription?r=${DateTime.now().millisecondsSinceEpoch}',
      extra: {'fromOnboarding': widget.fromOnboarding},
    );
  }

  void _showFailure(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            'Payment Verification Pending',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Text(
            message,
            style: GoogleFonts.outfit(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _returnToPlans();
              },
              child: Text(
                'Back to Plans',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _isRecovering = false;
                _beginRecovery(reason: 'Retrying payment verification...');
              },
              child: Text(
                'Retry',
                style: GoogleFonts.outfit(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _subscriptionBloc,
      child: BlocListener<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          if (state is PaymentVerificationSuccess) {
            _completeSuccess();
          }
        },
        child: PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor:
                isDark ? AppColors.darkBackground : const Color(0xFFF7FBFF),
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 56,
                        height: 56,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.accent),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Processing Payment',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _statusMessage,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          height: 1.5,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
