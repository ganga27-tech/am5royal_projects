import 'package:equatable/equatable.dart';

class AdminCoupon extends Equatable {
  const AdminCoupon({
    required this.id,
    required this.code,
    required this.title,
    required this.discountType,
    required this.discountValue,
    required this.isActive,
    required this.redemptionCount,
    this.description,
    this.usageLimit,
  });

  final String id;
  final String code;
  final String title;
  final String? description;
  final String discountType;
  final double discountValue;
  final bool isActive;
  final int? usageLimit;
  final int redemptionCount;

  factory AdminCoupon.fromJson(Map<String, dynamic> json) {
    final v = json['discount_value'];
    return AdminCoupon(
      id: json['id'] as String,
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      discountType: json['discount_type'] as String? ?? 'fixed',
      discountValue: v is num ? v.toDouble() : double.parse('$v'),
      isActive: json['is_active'] as bool? ?? true,
      usageLimit: json['usage_limit'] as int?,
      redemptionCount: json['redemption_count'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, code, isActive];
}

class PriceOverride extends Equatable {
  const PriceOverride({
    required this.id,
    required this.serviceId,
    required this.city,
    required this.priceAmount,
    required this.currency,
    required this.isActive,
  });

  final String id;
  final String serviceId;
  final String city;
  final double priceAmount;
  final String currency;
  final bool isActive;

  factory PriceOverride.fromJson(Map<String, dynamic> json) {
    final p = json['price_amount'];
    return PriceOverride(
      id: json['id'] as String,
      serviceId: json['service_id'] as String,
      city: json['city'] as String? ?? '',
      priceAmount: p is num ? p.toDouble() : double.parse('$p'),
      currency: json['currency'] as String? ?? 'INR',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [id, city, priceAmount];
}

class AdminRole extends Equatable {
  const AdminRole({
    required this.id,
    required this.code,
    required this.name,
    required this.permissions,
    this.description,
  });

  final String id;
  final String code;
  final String name;
  final String? description;
  final List<String> permissions;

  factory AdminRole.fromJson(Map<String, dynamic> json) {
    final perms = json['permissions'];
    return AdminRole(
      id: json['id'] as String,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      permissions: perms is List ? perms.map((e) => e.toString()).toList() : const [],
    );
  }

  @override
  List<Object?> get props => [id, code];
}

class AdminUserSummary extends Equatable {
  const AdminUserSummary({
    required this.id,
    required this.status,
    required this.roles,
    this.email,
    this.fullName,
  });

  final String id;
  final String? email;
  final String? fullName;
  final String status;
  final List<String> roles;

  factory AdminUserSummary.fromJson(Map<String, dynamic> json) {
    final roles = json['roles'];
    return AdminUserSummary(
      id: json['id'] as String,
      email: json['email'] as String?,
      fullName: json['full_name'] as String?,
      status: json['status'] as String? ?? 'active',
      roles: roles is List ? roles.map((e) => e.toString()).toList() : const [],
    );
  }

  @override
  List<Object?> get props => [id, roles];
}
