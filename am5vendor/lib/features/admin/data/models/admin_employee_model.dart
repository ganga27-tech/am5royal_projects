import '../../domain/entities/admin_employee.dart';

class AdminEmployeeModel extends AdminEmployee {
  AdminEmployeeModel({
    required super.id,
    required super.email,
    super.phoneNumber,
    super.address,
    required super.role,
    required super.status,
    required super.createdAt,
    required super.points,
    super.firstName,
    super.lastName,
  });

  factory AdminEmployeeModel.fromJson(Map<String, dynamic> json) {
    return AdminEmployeeModel(
      id: json['id'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      role: json['role'] ?? 'staff',
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      points: json['referral_points'] ?? json['points'] ?? 0,
      firstName: json['first_name'],
      lastName: json['last_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone_number': phoneNumber,
      'address': address,
      'role': role,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'points': points,
      'first_name': firstName,
      'last_name': lastName,
    };
  }
}
