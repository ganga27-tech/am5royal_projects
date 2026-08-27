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
    };
  }
}
