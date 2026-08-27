import '../../../supercategory/data/models/add_service_request_model.dart';

class TelecallerVendorOnboardRequestModel {
  final String firstName;
  final String lastName;
  final String? fatherName;
  final String? email;
  final String? alternativeNumber;
  final String businessName;
  final String aadhaarNumber;

  final String address;
  final String? street;
  final String city;
  final String? district;
  final String state;
  final String pincode;
  final double? latitude;
  final double? longitude;
  final int? serviceRadiusKm;

  final String? profileImage;

  final List<TelecallerCategoryRequest> categories;
  final List<TelecallerServiceRequest> services;

  TelecallerVendorOnboardRequestModel({
    required this.firstName,
    required this.lastName,
    this.fatherName,
    this.email,
    this.alternativeNumber,
    required this.businessName,
    required this.aadhaarNumber,
    required this.address,
    this.street,
    required this.city,
    this.district,
    required this.state,
    required this.pincode,
    this.latitude,
    this.longitude,
    this.serviceRadiusKm = 5,
    this.profileImage,
    required this.categories,
    required this.services,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      if (fatherName != null && fatherName!.isNotEmpty) 'father_name': fatherName,
      if (email != null && email!.isNotEmpty) 'email': email,
      if (alternativeNumber != null && alternativeNumber!.isNotEmpty) 'alternative_number': alternativeNumber,
      'business_name': businessName,
      'aadhaar_number': aadhaarNumber,
      'address': address,
      if (street != null && street!.isNotEmpty) 'street': street,
      'city': city,
      if (district != null && district!.isNotEmpty) 'district': district,
      'state': state,
      'pincode': pincode,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (serviceRadiusKm != null) 'service_radius_km': serviceRadiusKm,
      if (profileImage != null) 'profile_image': profileImage,
      'categories': categories.map((e) => e.toJson()).toList(),
      'services': services.map((e) => e.toJson()).toList(),
    };
  }

  TelecallerVendorOnboardRequestModel copyWith({
    String? firstName,
    String? lastName,
    String? fatherName,
    String? email,
    String? alternativeNumber,
    String? businessName,
    String? aadhaarNumber,
    String? address,
    String? city,
    String? state,
    String? pincode,
    double? latitude,
    double? longitude,
    int? serviceRadiusKm,
    String? profileImage,
    List<TelecallerCategoryRequest>? categories,
    List<TelecallerServiceRequest>? services,
  }) {
    return TelecallerVendorOnboardRequestModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fatherName: fatherName ?? this.fatherName,
      email: email ?? this.email,
      alternativeNumber: alternativeNumber ?? this.alternativeNumber,
      businessName: businessName ?? this.businessName,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      serviceRadiusKm: serviceRadiusKm ?? this.serviceRadiusKm,
      profileImage: profileImage ?? this.profileImage,
      categories: categories ?? this.categories,
      services: services ?? this.services,
    );
  }
}

class TelecallerCategoryRequest {
  final String mainCategoryId;
  final List<String> subCategoryIds;

  TelecallerCategoryRequest({
    required this.mainCategoryId,
    required this.subCategoryIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'main_category_id': int.tryParse(mainCategoryId) ?? mainCategoryId,
      'sub_category_ids': subCategoryIds.map((id) => int.tryParse(id) ?? id).toList(),
    };
  }
}

class TelecallerServiceRequest {
  final String serviceId;
  final double amount;
  final double? discountedAmount;
  final bool isNegotiable;
  final List<MediaItemModel> media;

  TelecallerServiceRequest({
    required this.serviceId,
    required this.amount,
    this.discountedAmount,
    required this.isNegotiable,
    this.media = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'service_id': int.tryParse(serviceId) ?? serviceId,
      'amount': amount,
      if (discountedAmount != null) 'discounted_amount': discountedAmount,
      'is_negotiable': isNegotiable,
      'media': media.map((e) => e.toJson()).toList(),
    };
  }
}
