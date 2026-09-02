import 'package:equatable/equatable.dart';

class SupportTicket extends Equatable {
  const SupportTicket({
    required this.id,
    required this.ticketCode,
    required this.subject,
    required this.category,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.bookingId,
    this.messages = const [],
  });

  final String id;
  final String ticketCode;
  final String subject;
  final String category;
  final String priority;
  final String status;
  final String? bookingId;
  final List<SupportMessage> messages;
  final String createdAt;

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    final msgs = json['messages'];
    return SupportTicket(
      id: json['id'] as String,
      ticketCode: json['ticket_code'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      priority: json['priority'] as String? ?? 'medium',
      status: json['status'] as String? ?? 'open',
      bookingId: json['booking_id'] as String?,
      messages: msgs is List
          ? msgs.map((e) => SupportMessage.fromJson(e as Map<String, dynamic>)).toList()
          : const [],
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  factory SupportTicket.fromAm5Ticket(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id']?.toString() ?? '',
      ticketCode: json['ticket_number'] as String? ?? '',
      subject: json['title'] as String? ?? '',
      category: (json['ticket_type'] as String? ?? 'general').toLowerCase(),
      priority: (json['priority'] as String? ?? 'normal').toLowerCase(),
      status: (json['status'] as String? ?? 'open').toLowerCase(),
      bookingId: json['booking_id']?.toString(),
      messages: [
        if (json['description'] != null)
          SupportMessage(
            id: '1',
            body: json['description'] as String,
            isStaff: false,
            createdAt: json['created_at']?.toString() ?? '',
          ),
      ],
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, status];
}

class SupportMessage extends Equatable {
  const SupportMessage({
    required this.id,
    required this.body,
    required this.isStaff,
    required this.createdAt,
  });

  final String id;
  final String body;
  final bool isStaff;
  final String createdAt;

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
      id: json['id'] as String,
      body: json['body'] as String? ?? '',
      isStaff: json['is_staff'] as bool? ?? false,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, body];
}

class MembershipPlan extends Equatable {
  const MembershipPlan({
    required this.id,
    required this.code,
    required this.name,
    required this.priceAmount,
    required this.currency,
    required this.durationDays,
    required this.discountPercent,
    required this.walletCredit,
    required this.isActive,
    this.description,
  });

  final String id;
  final String code;
  final String name;
  final String? description;
  final double priceAmount;
  final String currency;
  final int durationDays;
  final double discountPercent;
  final double walletCredit;
  final bool isActive;

  factory MembershipPlan.fromJson(Map<String, dynamic> json) {
    double n(dynamic v) => v is num ? v.toDouble() : double.parse('$v');
    return MembershipPlan(
      id: json['id'] as String,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      priceAmount: n(json['price_amount'] ?? 0),
      currency: json['currency'] as String? ?? 'INR',
      durationDays: json['duration_days'] as int? ?? 30,
      discountPercent: n(json['discount_percent'] ?? 0),
      walletCredit: n(json['wallet_credit'] ?? 0),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [id, code];
}

class MembershipStatus extends Equatable {
  const MembershipStatus({
    required this.active,
    this.plan,
    this.endsAt,
    this.status,
  });

  final bool active;
  final MembershipPlan? plan;
  final String? endsAt;
  final String? status;

  factory MembershipStatus.fromJson(Map<String, dynamic> json) {
    final plan = json['plan'];
    return MembershipStatus(
      active: json['active'] as bool? ?? false,
      plan: plan is Map<String, dynamic> ? MembershipPlan.fromJson(plan) : null,
      endsAt: json['ends_at']?.toString(),
      status: json['status'] as String?,
    );
  }

  @override
  List<Object?> get props => [active, status];
}

class ReferralInfo extends Equatable {
  const ReferralInfo({
    required this.code,
    required this.shareMessage,
    required this.referrerBonus,
    required this.refereeBonus,
    required this.redemptionsCount,
  });

  final String code;
  final String shareMessage;
  final double referrerBonus;
  final double refereeBonus;
  final int redemptionsCount;

  factory ReferralInfo.fromJson(Map<String, dynamic> json) {
    double n(dynamic v) => v is num ? v.toDouble() : double.parse('$v');
    return ReferralInfo(
      code: json['code'] as String? ?? '',
      shareMessage: json['share_message'] as String? ?? '',
      referrerBonus: n(json['referrer_bonus'] ?? 0),
      refereeBonus: n(json['referee_bonus'] ?? 0),
      redemptionsCount: json['redemptions_count'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [code, redemptionsCount];
}

class Invoice extends Equatable {
  const Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.bookingId,
    required this.serviceName,
    required this.subtotalAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.currency,
    required this.status,
    required this.issuedAt,
  });

  final String id;
  final String invoiceNumber;
  final String bookingId;
  final String serviceName;
  final double subtotalAmount;
  final double discountAmount;
  final double totalAmount;
  final String currency;
  final String status;
  final String issuedAt;

  factory Invoice.fromJson(Map<String, dynamic> json) {
    double n(dynamic v) => v is num ? v.toDouble() : double.parse('$v');
    return Invoice(
      id: json['id'] as String,
      invoiceNumber: json['invoice_number'] as String? ?? '',
      bookingId: json['booking_id'] as String,
      serviceName: json['service_name'] as String? ?? '',
      subtotalAmount: n(json['subtotal_amount'] ?? 0),
      discountAmount: n(json['discount_amount'] ?? 0),
      totalAmount: n(json['total_amount'] ?? 0),
      currency: json['currency'] as String? ?? 'INR',
      status: json['status'] as String? ?? 'issued',
      issuedAt: json['issued_at']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, invoiceNumber];
}
