class VerificationIncentiveModel {
  final int id;
  final int vendorId;
  final String vendorName;
  final double subscriptionAmount;
  final double incentivePercent;
  final double incentiveAmount;
  final String paymentDate;
  final int? planId;
  final String? planName;
  final int? employeeId;

  VerificationIncentiveModel({
    required this.id,
    required this.vendorId,
    required this.vendorName,
    required this.subscriptionAmount,
    required this.incentivePercent,
    required this.incentiveAmount,
    required this.paymentDate,
    this.planId,
    this.planName,
    this.employeeId,
  });

  factory VerificationIncentiveModel.fromJson(Map<String, dynamic> json) {
    return VerificationIncentiveModel(
      id: json['id'] ?? 0,
      vendorId: json['vendor_id'] ?? 0,
      vendorName: json['vendor_name'] ?? '',
      subscriptionAmount: (json['subscription_amount'] as num?)?.toDouble() ?? 0,
      incentivePercent: (json['incentive_percent'] as num?)?.toDouble() ?? 0,
      incentiveAmount: (json['incentive_amount'] as num?)?.toDouble() ?? 0,
      paymentDate: json['payment_date']?.toString() ?? '',
      planId: json['plan_id'],
      planName: json['plan_name']?.toString(),
      employeeId: json['employee_id'],
    );
  }
}
