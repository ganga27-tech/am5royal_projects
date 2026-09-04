class TelecallerOnboardedVendorModel {
  final int id;
  final String businessName;
  final String firstName;
  final String lastName;
  final String city;
  final String status;
  final String createdAt;
  final String mobileNumber;
  final String? leadSource;
  final bool hasServices;
  final bool hasRegistration;
  final bool hasSlots;
  final bool hasBusinessReg;
  final bool hasPayment;
  final bool isTempActive;
  final bool isActivated;

  TelecallerOnboardedVendorModel({
    required this.id,
    required this.businessName,
    required this.firstName,
    required this.lastName,
    required this.city,
    required this.status,
    required this.createdAt,
    required this.mobileNumber,
    this.leadSource,
    this.hasServices = false,
    this.hasRegistration = false,
    this.hasSlots = false,
    this.hasBusinessReg = false,
    this.hasPayment = false,
    this.isTempActive = false,
    this.isActivated = false,
  });

  factory TelecallerOnboardedVendorModel.fromJson(Map<String, dynamic> json) {
    return TelecallerOnboardedVendorModel(
      id: json['id'] ?? 0,
      businessName: json['business_name'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      city: json['city'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      leadSource: json['lead_source'],
      hasServices: json['has_services'] ?? false,
      hasRegistration: json['has_registration'] ?? false,
      hasSlots: json['has_slots'] ?? false,
      hasBusinessReg: json['has_business_reg'] ?? false,
      hasPayment: json['has_payment'] ?? false,
      isTempActive: json['is_temp_active'] ?? false,
      isActivated: json['is_activated'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_name': businessName,
      'first_name': firstName,
      'last_name': lastName,
      'city': city,
      'status': status,
      'created_at': createdAt,
      'mobile_number': mobileNumber,
      'lead_source': leadSource,
      'has_services': hasServices,
      'has_registration': hasRegistration,
      'has_slots': hasSlots,
      'has_business_reg': hasBusinessReg,
      'has_payment': hasPayment,
      'is_temp_active': isTempActive,
      'is_activated': isActivated,
    };
  }
}
