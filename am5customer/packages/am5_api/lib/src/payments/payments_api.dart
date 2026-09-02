import 'package:am5_core/am5_core.dart';

import '../client/api_client.dart';

/// AM5 customer orders are created with COD; no separate payment gateway flow yet.
class PaymentsApi {
  PaymentsApi(this._client);

  final ApiClient _client;

  Future<CouponQuote> validateCoupon({required String code, required double orderAmount}) async {
    // AM5 applies discounts during order calculation; no standalone coupon validate API.
    return CouponQuote(
      code: code,
      title: code,
      discountAmount: 0,
      payableAmount: orderAmount,
      valid: false,
      message: 'Coupon validation is not available yet. Discounts are applied during booking.',
    );
  }

  Future<WalletInfo> getWallet() async {
    return const WalletInfo(
      id: 'customer-wallet',
      balance: 0,
      currency: 'INR',
      status: 'active',
    );
  }

  Future<PaymentInfo> createPayment({
    required String bookingId,
    String? couponCode,
    double useWalletAmount = 0,
  }) async {
    return PaymentInfo(
      id: 'cod-$bookingId',
      bookingId: bookingId,
      amount: 0,
      currency: 'INR',
      method: 'COD',
      provider: 'am5',
      status: 'captured',
      gatewayAmount: 0,
      walletAmount: useWalletAmount,
      discountAmount: 0,
      couponCode: couponCode,
    );
  }

  Future<PaymentInfo> confirmPayment(String paymentId, {String? paymentToken}) async {
    return PaymentInfo(
      id: paymentId,
      bookingId: paymentId.replaceFirst('cod-', ''),
      amount: 0,
      currency: 'INR',
      method: 'COD',
      provider: 'am5',
      status: 'captured',
      gatewayAmount: 0,
      walletAmount: 0,
      discountAmount: 0,
    );
  }
}
