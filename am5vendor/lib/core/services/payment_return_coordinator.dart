import 'package:go_router/go_router.dart';

import '../di/injection_container.dart' as di;
import '../utils/razorpay_checkout_helper.dart';
import 'payment_session_service.dart';

/// Handles returning from PhonePe / GPay after UPI payment.
class PaymentReturnCoordinator {
  PaymentReturnCoordinator._();

  static bool _handling = false;
  static DateTime? _lastHandledAt;

  static Future<void> onReturnFromUpi(GoRouter router) async {
    final now = DateTime.now();
    if (_handling) return;
    if (_lastHandledAt != null &&
        now.difference(_lastHandledAt!) < const Duration(seconds: 5)) {
      return;
    }

    final session = await di.sl<PaymentSessionService>().getActiveSession();
    if (session == null || !session.checkoutOpened) return;

    _handling = true;
    _lastHandledAt = now;
    try {
      await RazorpayCheckoutHelper.dismissCheckout();
      router.go('/subscription?recover=1&r=${now.millisecondsSinceEpoch}');
    } finally {
      _handling = false;
    }
  }
}
