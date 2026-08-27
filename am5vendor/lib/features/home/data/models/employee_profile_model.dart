class EmployeeProfileModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String role;
  final String status;
  final int referralPoints;
  final String? bankName;
  final String? bankAccountNumber;
  final String? bankAccountName;
  final String? bankIfscCode;

  EmployeeProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.status,
    required this.referralPoints,
    this.bankName,
    this.bankAccountNumber,
    this.bankAccountName,
    this.bankIfscCode,
  });

  factory EmployeeProfileModel.fromJson(Map<String, dynamic> json) {
    return EmployeeProfileModel(
      id: json['id'] as int,
      firstName: (json['first_name'] as String?) ?? '',
      lastName: (json['last_name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phoneNumber: (json['phone_number'] as String?) ?? '',
      role: (json['role'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      referralPoints: (json['referral_points'] as int?) ?? 0,
      bankName: json['bank_name'] as String?,
      bankAccountNumber: json['bank_account_number'] as String?,
      bankAccountName: json['bank_account_name'] as String?,
      bankIfscCode: json['bank_ifsc_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'role': role,
      'bank_name': bankName,
      'bank_account_number': bankAccountNumber,
      'bank_account_name': bankAccountName,
      'bank_ifsc_code': bankIfscCode,
    };
  }
}
