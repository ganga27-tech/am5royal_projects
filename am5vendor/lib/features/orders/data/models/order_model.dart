import '../../domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  OrderModel({
    required super.id,
    required super.bookingReference,
    super.customerName,
    super.customerPhone,
    super.serviceAddress,
    super.serviceName,
    super.bookingDate,
    super.bookingTime,
    required super.status,
    super.totalAmount,
    super.startOtp,
    super.endOtp,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      bookingReference: json['booking_reference'] ?? '',
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      serviceAddress: json['service_address'],
      serviceName: json['service_name'],
      bookingDate: json['booking_date'],
      bookingTime: json['booking_time'],
      status: json['status'] ?? 'new',
      totalAmount: json['total_amount']?.toDouble(),
      startOtp: json['start_otp'],
      endOtp: json['end_otp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_reference': bookingReference,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'service_address': serviceAddress,
      'service_name': serviceName,
      'booking_date': bookingDate,
      'booking_time': bookingTime,
      'status': status,
      'total_amount': totalAmount,
      'start_otp': startOtp,
      'end_otp': endOtp,
    };
  }
}
