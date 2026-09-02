import 'package:equatable/equatable.dart';

class WalletInfo extends Equatable {
  const WalletInfo({
    required this.id,
    required this.balance,
    required this.currency,
    required this.status,
  });

  final String id;
  final double balance;
  final String currency;
  final String status;

  String get balanceLabel => '₹${balance.toStringAsFixed(0)}';

  factory WalletInfo.fromJson(Map<String, dynamic> json) {
    final bal = json['balance'];
    return WalletInfo(
      id: json['id'] as String,
      balance: bal is num ? bal.toDouble() : double.parse(bal.toString()),
      currency: json['currency'] as String? ?? 'INR',
      status: json['status'] as String? ?? 'active',
    );
  }

  @override
  List<Object?> get props => [id, balance, status];
}

class CouponQuote extends Equatable {
  const CouponQuote({
    required this.code,
    required this.title,
    required this.discountAmount,
    required this.payableAmount,
    required this.valid,
    required this.message,
  });

  final String code;
  final String title;
  final double discountAmount;
  final double payableAmount;
  final bool valid;
  final String message;

  factory CouponQuote.fromJson(Map<String, dynamic> json) {
    double n(dynamic v) => v is num ? v.toDouble() : double.parse(v.toString());
    return CouponQuote(
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      discountAmount: n(json['discount_amount'] ?? 0),
      payableAmount: n(json['payable_amount'] ?? 0),
      valid: json['valid'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [code, valid, discountAmount];
}

class PaymentInfo extends Equatable {
  const PaymentInfo({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.currency,
    required this.method,
    required this.provider,
    required this.status,
    required this.gatewayAmount,
    required this.walletAmount,
    required this.discountAmount,
    this.providerOrderId,
    this.clientSecret,
    this.couponCode,
  });

  final String id;
  final String bookingId;
  final double amount;
  final String currency;
  final String method;
  final String provider;
  final String? providerOrderId;
  final String? clientSecret;
  final String status;
  final double gatewayAmount;
  final double walletAmount;
  final double discountAmount;
  final String? couponCode;

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    double n(dynamic v) => v is num ? v.toDouble() : double.parse(v.toString());
    return PaymentInfo(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      amount: n(json['amount']),
      currency: json['currency'] as String? ?? 'INR',
      method: json['method'] as String,
      provider: json['provider'] as String,
      providerOrderId: json['provider_order_id'] as String?,
      clientSecret: json['client_secret'] as String?,
      status: json['status'] as String,
      gatewayAmount: n(json['gateway_amount'] ?? 0),
      walletAmount: n(json['wallet_amount'] ?? 0),
      discountAmount: n(json['discount_amount'] ?? 0),
      couponCode: json['coupon_code'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, status, amount];
}
