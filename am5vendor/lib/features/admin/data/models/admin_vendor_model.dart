import '../../domain/entities/admin_vendor.dart';

class AdminVendorModel extends AdminVendor {
  AdminVendorModel({
    required super.id,
    required super.name,
    super.email,
    super.phoneNumber,
    super.fssaiLicenseNumber,
    super.panCardNumber,
    super.gstNumber,
    super.aadhaarNumber,
    super.city,
    super.businessName,
    super.firstName,
    super.lastName,
    required super.status,
    required super.createdAt,
    required super.employeeId,
    super.onboardedByEmployeeName,
    super.documentsUploaded = false,
    super.hasPayment = false,
  });

  factory AdminVendorModel.fromJson(Map<String, dynamic> json) {
    // Robustly derive name from business_name or first_name + last_name
    String name = 'Unknown Vendor';
    if (json['business_name'] != null && json['business_name'].toString().trim().isNotEmpty) {
      name = json['business_name'].toString().trim();
    } else if (json['first_name'] != null || json['last_name'] != null) {
      final first = json['first_name']?.toString().trim() ?? '';
      final last = json['last_name']?.toString().trim() ?? '';
      name = '$first $last'.trim();
      if (name.isEmpty) name = 'Unknown Vendor';
    } else if (json['name'] != null && json['name'].toString().trim().isNotEmpty) {
      name = json['name'].toString().trim();
    }

    return AdminVendorModel(
      id: json['id'],
      name: name,
      email: json['email'],
      phoneNumber: json['phone_number'] ?? json['mobile'],
      fssaiLicenseNumber: json['fssai_license_number'],
      panCardNumber: json['pan_card_number'] ?? json['pan_number'],
      gstNumber: json['gst_number'],
      aadhaarNumber: json['aadhaar_number'],
      city: json['city'],
      businessName: json['business_name'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      employeeId: json['onboarded_by_employee_id'] ?? json['employee_id'] ?? 0,
      onboardedByEmployeeName: json['onboarded_by_employee_name'],
      documentsUploaded: json['documents_uploaded'] ?? false,
      hasPayment: json['has_payment'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'fssai_license_number': fssaiLicenseNumber,
      'pan_card_number': panCardNumber,
      'gst_number': gstNumber,
      'aadhaar_number': aadhaarNumber,
      'city': city,
      'business_name': businessName,
      'first_name': firstName,
      'last_name': lastName,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'onboarded_by_employee_id': employeeId,
      'onboarded_by_employee_name': onboardedByEmployeeName,
      'documents_uploaded': documentsUploaded,
      'has_payment': hasPayment,
    };
  }
}
