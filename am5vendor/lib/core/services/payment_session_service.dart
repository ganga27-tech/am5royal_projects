import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PendingPaymentSession {
  final String orderId;
  final int planId;
  final bool checkoutOpened;
  final Map<String, dynamic>? orderData;

  const PendingPaymentSession({
    required this.orderId,
    required this.planId,
    required this.checkoutOpened,
    this.orderData,
  });
}

/// Persists in-flight Razorpay checkout state across app restarts
/// (common when returning from PhonePe / GPay / Paytm).
class PaymentSessionService {
  PaymentSessionService(this._prefs);

  static const pendingOrderKey = 'pending_subscription_order_id';
  static const pendingPlanKey = 'pending_subscription_plan_id';
  static const checkoutOpenedKey = 'payment_checkout_in_progress';
  static const pendingOrderDataKey = 'pending_subscription_order_data';

  final SharedPreferences _prefs;

  Future<PendingPaymentSession?> getActiveSession() async {
    final orderId = _prefs.getString(pendingOrderKey);
    final planId = _prefs.getInt(pendingPlanKey);
    if (orderId == null || planId == null) return null;

    Map<String, dynamic>? orderData;
    final rawOrderData = _prefs.getString(pendingOrderDataKey);
    if (rawOrderData != null && rawOrderData.isNotEmpty) {
      try {
        orderData = Map<String, dynamic>.from(
          jsonDecode(rawOrderData) as Map<dynamic, dynamic>,
        );
      } catch (_) {}
    }

    return PendingPaymentSession(
      orderId: orderId,
      planId: planId,
      checkoutOpened: _prefs.getBool(checkoutOpenedKey) ?? false,
      orderData: orderData,
    );
  }

  Future<void> saveCheckoutSession({
    required String orderId,
    required int planId,
    required Map<String, dynamic> orderData,
  }) async {
    await _prefs.setString(pendingOrderKey, orderId);
    await _prefs.setInt(pendingPlanKey, planId);
    await _prefs.setString(pendingOrderDataKey, jsonEncode(orderData));
    await _prefs.setBool(checkoutOpenedKey, false);
  }

  Future<void> markCheckoutOpened() async {
    await _prefs.setBool(checkoutOpenedKey, true);
  }

  Future<void> clearSession() async {
    await _prefs.remove(pendingOrderKey);
    await _prefs.remove(pendingPlanKey);
    await _prefs.remove(checkoutOpenedKey);
    await _prefs.remove(pendingOrderDataKey);
  }
}
