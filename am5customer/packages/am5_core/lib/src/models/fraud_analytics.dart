import 'package:equatable/equatable.dart';

class AnalyticsSummary extends Equatable {
  const AnalyticsSummary({
    required this.bookingsTotal,
    required this.bookingsCompleted,
    required this.bookingsCancelled,
    required this.revenueCaptured,
    required this.customersActive,
    required this.partnersActive,
    required this.couponRedemptions,
    required this.referralRedemptions,
    required this.openFraudSignals,
    required this.auditEvents,
  });

  final int bookingsTotal;
  final int bookingsCompleted;
  final int bookingsCancelled;
  final double revenueCaptured;
  final int customersActive;
  final int partnersActive;
  final int couponRedemptions;
  final int referralRedemptions;
  final int openFraudSignals;
  final int auditEvents;

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    final rev = json['revenue_captured'];
    return AnalyticsSummary(
      bookingsTotal: json['bookings_total'] as int? ?? 0,
      bookingsCompleted: json['bookings_completed'] as int? ?? 0,
      bookingsCancelled: json['bookings_cancelled'] as int? ?? 0,
      revenueCaptured: rev is num ? rev.toDouble() : double.parse('$rev'),
      customersActive: json['customers_active'] as int? ?? 0,
      partnersActive: json['partners_active'] as int? ?? 0,
      couponRedemptions: json['coupon_redemptions'] as int? ?? 0,
      referralRedemptions: json['referral_redemptions'] as int? ?? 0,
      openFraudSignals: json['open_fraud_signals'] as int? ?? 0,
      auditEvents: json['audit_events'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [bookingsTotal, revenueCaptured, openFraudSignals];
}

class AuditLogEntry extends Equatable {
  const AuditLogEntry({
    required this.id,
    required this.eventType,
    required this.createdAt,
    this.userId,
    this.ipAddress,
  });

  final String id;
  final String? userId;
  final String eventType;
  final String? ipAddress;
  final String createdAt;

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    return AuditLogEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      eventType: json['event_type'] as String? ?? '',
      ipAddress: json['ip_address'] as String?,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, eventType];
}

class FraudSignal extends Equatable {
  const FraudSignal({
    required this.id,
    required this.signalType,
    required this.severity,
    required this.status,
    required this.title,
    required this.createdAt,
    this.description,
    this.userId,
  });

  final String id;
  final String signalType;
  final String severity;
  final String status;
  final String title;
  final String? description;
  final String? userId;
  final String createdAt;

  factory FraudSignal.fromJson(Map<String, dynamic> json) {
    return FraudSignal(
      id: json['id'] as String,
      signalType: json['signal_type'] as String? ?? '',
      severity: json['severity'] as String? ?? 'medium',
      status: json['status'] as String? ?? 'open',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      userId: json['user_id'] as String?,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, status, severity];
}
