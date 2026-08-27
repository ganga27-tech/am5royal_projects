class VendorProfileModel {
  final int id;
  final int userId;
  final String? mobile;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? fatherName;
  final String? businessName;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final double? latitude;
  final double? longitude;
  final String? profileImage;
  final String? backgroundBanner;
  final String? businessDescription;
  final List<String>? businessHighlights;
  final String? aboutBusiness;
  final String? additionalBusinessInfo;
  final String? alternativeContactNumber;
  final String? status;

  VendorProfileModel({
    required this.id,
    required this.userId,
    this.mobile,
    this.email,
    this.firstName,
    this.lastName,
    this.fatherName,
    this.businessName,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.latitude,
    this.longitude,
    this.profileImage,
    this.backgroundBanner,
    this.businessDescription,
    this.businessHighlights,
    this.aboutBusiness,
    this.additionalBusinessInfo,
    this.alternativeContactNumber,
    this.status,
  });

  factory VendorProfileModel.fromJson(Map<String, dynamic> json) {
    return VendorProfileModel(
      id: json['id'],
      userId: json['user_id'],
      mobile: json['mobile'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      fatherName: json['father_name'],
      businessName: json['business_name'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      profileImage: json['profile_image'],
      backgroundBanner: json['background_banner'],
      businessDescription: json['business_description'],
      businessHighlights: json['business_highlights'] != null
          ? List<String>.from(json['business_highlights'])
          : null,
      aboutBusiness: json['about_business'],
      additionalBusinessInfo: json['additional_business_info'],
      alternativeContactNumber: json['alternative_contact_number'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'father_name': fatherName,
      'business_name': businessName,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'profile_image': profileImage,
      'background_banner': backgroundBanner,
      'business_description': businessDescription,
      'business_highlights': businessHighlights,
      'about_business': aboutBusiness,
      'additional_business_info': additionalBusinessInfo,
      'alternative_contact_number': alternativeContactNumber,
    };
  }

  VendorProfileModel copyWith({
    String? firstName,
    String? lastName,
    String? fatherName,
    String? businessName,
    String? address,
    String? city,
    String? state,
    String? pincode,
    double? latitude,
    double? longitude,
    String? profileImage,
    String? backgroundBanner,
    String? businessDescription,
    List<String>? businessHighlights,
    String? aboutBusiness,
    String? additionalBusinessInfo,
    String? alternativeContactNumber,
  }) {
    return VendorProfileModel(
      id: id,
      userId: userId,
      mobile: mobile,
      email: email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fatherName: fatherName ?? this.fatherName,
      businessName: businessName ?? this.businessName,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      profileImage: profileImage ?? this.profileImage,
      backgroundBanner: backgroundBanner ?? this.backgroundBanner,
      businessDescription: businessDescription ?? this.businessDescription,
      businessHighlights: businessHighlights ?? this.businessHighlights,
      aboutBusiness: aboutBusiness ?? this.aboutBusiness,
      additionalBusinessInfo: additionalBusinessInfo ?? this.additionalBusinessInfo,
      alternativeContactNumber: alternativeContactNumber ?? this.alternativeContactNumber,
    );
  }
}
