import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

typedef UpiReturnCallback = void Function();

/// Dismisses Razorpay's native CheckoutActivity when it gets stuck after
/// returning from PhonePe / GPay / Paytm.
class RazorpayCheckoutHelper {
  RazorpayCheckoutHelper._();

  static const _channel = MethodChannel('com.am5royal.am5royal/razorpay');
  static UpiReturnCallback? onUpiReturn;

  static Future<void> initialize({UpiReturnCallback? onReturn}) async {
    if (kIsWeb) return;
    onUpiReturn = onReturn;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onUpiReturn') {
        onUpiReturn?.call();
      }
    });
  }

  static Future<bool> dismissCheckout() async {
    if (kIsWeb) return false;
    try {
      final dismissed = await _channel.invokeMethod<bool>('dismissCheckout');
      return dismissed ?? false;
    } catch (e) {
      debugPrint('Razorpay checkout dismiss failed: $e');
      return false;
    }
  }

  static Future<void> setAutoDismissEnabled(bool enabled) async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod<void>(
        'setAutoDismissEnabled',
        enabled,
      );
    } catch (e) {
      debugPrint('Razorpay auto-dismiss toggle failed: $e');
    }
  }
}
