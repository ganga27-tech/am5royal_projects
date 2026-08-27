class OrderEntity {
  final int id;
  final String bookingReference;
  final String? customerName;
  final String? customerPhone;
  final String? serviceAddress;
  final String? serviceName;
  final String? bookingDate;
  final String? bookingTime;
  final String status;
  final double? totalAmount;
  final String? startOtp;
  final String? endOtp;

  OrderEntity({
    required this.id,
    required this.bookingReference,
    this.customerName,
    this.customerPhone,
    this.serviceAddress,
    this.serviceName,
    this.bookingDate,
    this.bookingTime,
    required this.status,
    this.totalAmount,
    this.startOtp,
    this.endOtp,
  });
}
