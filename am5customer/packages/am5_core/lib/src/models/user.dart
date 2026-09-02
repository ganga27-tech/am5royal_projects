import 'package:equatable/equatable.dart';

class LivoraUser extends Equatable {
  const LivoraUser({
    required this.id,
    required this.fullName,
    required this.status,
    required this.roles,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.preferredLocale,
    this.email,
    this.phone,
  });

  final String id;
  final String? email;
  final String? phone;
  final String fullName;
  final String status;
  final List<String> roles;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final String preferredLocale;

  factory LivoraUser.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'];
    final rolesRaw = json['roles'];
    return LivoraUser(
      id: idValue?.toString() ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      fullName: (json['full_name'] as String?) ?? 'Customer',
      status: (json['status'] as String?) ?? 'active',
      roles: rolesRaw is List
          ? rolesRaw.map((e) => e.toString().toLowerCase()).toList()
          : const ['customer'],
      isEmailVerified: json['is_email_verified'] as bool? ?? true,
      isPhoneVerified: json['is_phone_verified'] as bool? ?? true,
      preferredLocale: json['preferred_locale'] as String? ?? 'en',
    );
  }

  /// Builds a user model from AM5 `/auth/customer/me` response.
  factory LivoraUser.fromAm5CustomerProfile(Map<String, dynamic> json) {
    return LivoraUser(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      fullName: (json['full_name'] as String?) ?? 'Customer',
      status: 'active',
      roles: const ['customer'],
      isEmailVerified: json['email'] != null,
      isPhoneVerified: json['phone'] != null,
      preferredLocale: 'en',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'phone': phone,
        'full_name': fullName,
        'status': status,
        'roles': roles,
        'is_email_verified': isEmailVerified,
        'is_phone_verified': isPhoneVerified,
        'preferred_locale': preferredLocale,
      };

  @override
  List<Object?> get props => [id, email, phone, fullName, status, roles];
}
