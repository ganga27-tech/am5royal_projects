import 'package:equatable/equatable.dart';

class BookingSlot extends Equatable {
  const BookingSlot({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  factory BookingSlot.fromJson(Map<String, dynamic> json) {
    return BookingSlot(
      start: DateTime.parse(json['start'] as String).toLocal(),
      end: DateTime.parse(json['end'] as String).toLocal(),
    );
  }

  /// Parses AM5 slot strings like `08:30-11:30` for a given day.
  factory BookingSlot.fromAm5Slot(String slot, DateTime day) {
    final parts = slot.split('-');
    final startParts = parts.first.split(':');
    final endParts = (parts.length > 1 ? parts[1] : parts.first).split(':');
    final start = DateTime(
      day.year,
      day.month,
      day.day,
      int.parse(startParts[0]),
      int.parse(startParts[1]),
    );
    final end = DateTime(
      day.year,
      day.month,
      day.day,
      int.parse(endParts[0]),
      int.parse(endParts[1]),
    );
    return BookingSlot(start: start, end: end);
  }

  String get label {
    final h = start.hour.toString().padLeft(2, '0');
    final m = start.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  List<Object?> get props => [start, end];
}

class Booking extends Equatable {
  const Booking({
    required this.id,
    required this.bookingCode,
    required this.customerUserId,
    required this.professionalId,
    required this.serviceId,
    required this.addressId,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.serviceName,
    required this.durationMinutes,
    required this.priceAmount,
    required this.currency,
    required this.status,
    this.professionalName,
    this.customerNotes,
    this.cancelReason,
    this.discountAmount = 0,
    this.payableAmount,
    this.paymentStatus = 'unpaid',
    this.couponCode,
  });

  final String id;
  final String bookingCode;
  final String customerUserId;
  final String professionalId;
  final String? professionalName;
  final String serviceId;
  final String addressId;
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final String serviceName;
  final int durationMinutes;
  final double priceAmount;
  final String currency;
  final double discountAmount;
  final double? payableAmount;
  final String paymentStatus;
  final String? couponCode;
  final String status;
  final String? customerNotes;
  final String? cancelReason;

  String get priceLabel => '₹${(payableAmount ?? priceAmount).toStringAsFixed(0)}';

  factory Booking.fromJson(Map<String, dynamic> json) {
    double n(dynamic v) {
      if (v == null) return 0;
      return v is num ? v.toDouble() : double.parse(v.toString());
    }

    final price = json['base_price'] ?? json['price_amount'];
    return Booking(
      id: json['id']?.toString() ?? '',
      bookingCode: json['booking_code'] as String? ?? json['orderId'] as String? ?? '',
      customerUserId: json['customer_user_id']?.toString() ?? '',
      professionalId: json['professional_id']?.toString() ?? json['vendor_id']?.toString() ?? '',
      professionalName: json['professional_name'] as String? ?? json['vendor_name'] as String?,
      serviceId: json['service_id']?.toString() ?? '',
      addressId: json['address_id']?.toString() ?? '',
      scheduledStart: DateTime.parse(json['scheduled_start'] as String).toLocal(),
      scheduledEnd: DateTime.parse(json['scheduled_end'] as String).toLocal(),
      serviceName: json['service_name'] as String? ?? 'Service',
      durationMinutes: json['duration_minutes'] as int? ?? 60,
      priceAmount: n(price),
      currency: json['currency'] as String? ?? 'INR',
      discountAmount: n(json['discount_amount']),
      payableAmount: json['payable_amount'] == null ? null : n(json['payable_amount']),
      paymentStatus: json['payment_status'] as String? ?? 'unpaid',
      couponCode: json['coupon_code'] as String?,
      status: (json['status'] as String? ?? 'pending').toLowerCase(),
      customerNotes: json['customer_notes'] as String?,
      cancelReason: json['cancel_reason'] as String?,
    );
  }

  factory Booking.fromAm5Order(Map<String, dynamic> json) {
    double n(dynamic v) {
      if (v == null) return 0;
      return v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0;
    }

    final serviceDate = json['serviceDate'] as String?;
    final serviceTime = json['serviceTime'] as String?;
    DateTime start = DateTime.now();
    DateTime end = start.add(const Duration(hours: 2));

    if (serviceDate != null) {
      try {
        final date = DateTime.parse(serviceDate);
        if (serviceTime != null && serviceTime.isNotEmpty) {
          final cleaned = serviceTime.replaceAll(RegExp(r'[^0-9:]'), '');
          final parts = cleaned.split(':');
          if (parts.length >= 2) {
            var hour = int.parse(parts[0]);
            final minute = int.parse(parts[1]);
            if (serviceTime.toUpperCase().contains('PM') && hour < 12) hour += 12;
            if (serviceTime.toUpperCase().contains('AM') && hour == 12) hour = 0;
            start = DateTime(date.year, date.month, date.day, hour, minute);
            end = start.add(const Duration(hours: 2));
          } else {
            start = date;
            end = date.add(const Duration(hours: 2));
          }
        } else {
          start = date;
          end = date.add(const Duration(hours: 2));
        }
      } catch (_) {}
    }

    final amount = n(json['finalAmount'] ?? json['totalAmount']);
    final rawStatus = (json['status'] as String? ?? 'PENDING').toUpperCase();

    return Booking(
      id: json['orderId']?.toString() ?? '',
      bookingCode: json['orderId']?.toString() ?? '',
      customerUserId: '',
      professionalId: '',
      professionalName: json['professional_name'] as String? ?? json['vendor_name'] as String?,
      serviceId: '',
      addressId: '',
      scheduledStart: start,
      scheduledEnd: end,
      serviceName: json['service_name'] as String? ?? 'Service',
      durationMinutes: 120,
      priceAmount: amount,
      currency: 'INR',
      payableAmount: amount,
      paymentStatus: 'unpaid',
      status: _normalizeAm5Status(rawStatus),
      customerNotes: null,
    );
  }

  static String _normalizeAm5Status(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
      case 'NEW':
        return 'pending';
      case 'ACCEPTED':
      case 'CONFIRMED':
        return 'confirmed';
      case 'IN_PROGRESS':
        return 'in_progress';
      case 'COMPLETED':
        return 'completed';
      case 'CANCELLED':
        return 'cancelled';
      default:
        return status.toLowerCase();
    }
  }

  @override
  List<Object?> get props => [id, status, bookingCode, paymentStatus];
}

class AvailabilityRule extends Equatable {
  const AvailabilityRule({
    required this.weekday,
    required this.startTime,
    required this.endTime,
    required this.timezone,
    required this.isActive,
  });

  final int weekday;
  final String startTime;
  final String endTime;
  final String timezone;
  final bool isActive;

  factory AvailabilityRule.fromJson(Map<String, dynamic> json) {
    return AvailabilityRule(
      weekday: json['weekday'] as int,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      timezone: json['timezone'] as String? ?? 'Asia/Kolkata',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'weekday': weekday,
        'start_time': startTime,
        'end_time': endTime,
        'timezone': timezone,
        'is_active': isActive,
      };

  @override
  List<Object?> get props => [weekday, startTime, endTime];
}
