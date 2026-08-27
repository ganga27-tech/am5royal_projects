import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'app_razorpay.dart';

class MobileRazorpay implements AppRazorpay {
  late Razorpay _razorpay;

  MobileRazorpay() {
    _razorpay = Razorpay();
  }

  @override
  void init({
    required Function(String paymentId, String orderId, String signature) onSuccess,
    required Function(String message, int? code) onError,
    required Function(String walletName) onExternalWallet,
  }) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) {
      onSuccess(response.paymentId ?? '', response.orderId ?? '', response.signature ?? '');
    });
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) {
      onError(response.message ?? 'Unknown error', response.code);
    });
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse response) {
      onExternalWallet(response.walletName ?? '');
    });
  }

  @override
  void open(Map<String, dynamic> options) {
    _razorpay.open(options);
  }

  @override
  void clear() {
    _razorpay.clear();
  }
}

AppRazorpay getRazorpay() => MobileRazorpay();
