export 'app_razorpay_stub.dart'
    if (dart.library.html) 'app_razorpay_web.dart'
    if (dart.library.io) 'app_razorpay_mobile.dart';

abstract class AppRazorpay {
  void init({
    required Function(String paymentId, String orderId, String signature) onSuccess,
    required Function(String message, int? code) onError,
    required Function(String walletName) onExternalWallet,
  });

  void open(Map<String, dynamic> options);

  void clear();
}
