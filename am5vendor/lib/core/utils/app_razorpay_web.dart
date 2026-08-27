// ignore_for_file: undefined_prefixed_name, undefined_function, uri_does_not_exist
import 'dart:js' as js;
import 'app_razorpay.dart';

class WebRazorpay implements AppRazorpay {
  late Function(String paymentId, String orderId, String signature) _onSuccess;
  late Function(String message, int? code) _onError;
  late Function(String walletName) _onExternalWallet;

  @override
  void init({
    required Function(String paymentId, String orderId, String signature) onSuccess,
    required Function(String message, int? code) onError,
    required Function(String walletName) onExternalWallet,
  }) {
    _onSuccess = onSuccess;
    _onError = onError;
    _onExternalWallet = onExternalWallet;
  }

  @override
  void open(Map<String, dynamic> options) {
    // Make a mutable copy of the options to avoid modifying read-only inputs
    final optionsCopy = Map<String, dynamic>.from(options);

    // Convert options Map to js object
    final jsOptions = js.JsObject.jsify(optionsCopy);

    // Add success callback handler
    jsOptions['handler'] = js.allowInterop((response) {
      final jsResponse = js.JsObject.fromBrowserObject(response);
      final paymentId = jsResponse['razorpay_payment_id'] as String? ?? '';
      final orderId = jsResponse['razorpay_order_id'] as String? ?? '';
      final signature = jsResponse['razorpay_signature'] as String? ?? '';
      _onSuccess(paymentId, orderId, signature);
    });

    // Add dismiss/error handler
    jsOptions['modal'] = js.JsObject.jsify({
      'ondismiss': js.allowInterop(() {
        _onError('Payment cancelled by user', 2);
      })
    });

    // Instantiate and open Razorpay
    if (js.context['Razorpay'] != null) {
      final rzp = js.JsObject(js.context['Razorpay'], [jsOptions]);
      rzp.callMethod('open');
    } else {
      _onError('Razorpay SDK not loaded in web page. Please check index.html script tag.', null);
    }
  }

  @override
  void clear() {
    // No-op on web
  }
}

AppRazorpay getRazorpay() => WebRazorpay();
