// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_registration_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ServiceCategorySelectionImpl _$$ServiceCategorySelectionImplFromJson(
        Map<String, dynamic> json) =>
    _$ServiceCategorySelectionImpl(
      mainCategoryId: (json['main_category_id'] as num).toInt(),
      subCategoryIds: (json['sub_category_ids'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$$ServiceCategorySelectionImplToJson(
        _$ServiceCategorySelectionImpl instance) =>
    <String, dynamic>{
      'main_category_id': instance.mainCategoryId,
      'sub_category_ids': instance.subCategoryIds,
    };

_$VendorRegistrationRequestModelImpl
    _$$VendorRegistrationRequestModelImplFromJson(Map<String, dynamic> json) =>
        _$VendorRegistrationRequestModelImpl(
          firstName: json['first_name'] as String,
          lastName: json['last_name'] as String?,
          fatherName: json['father_name'] as String?,
          email: json['email'] as String?,
          mobile: json['mobile'] as String?,
          altMobile: json['alternative_number'] as String?,
          businessName: json['business_name'] as String,
          aadhaarNumber: json['aadhaar_number'] as String,
          address: json['address'] as String,
          street: json['street'] as String?,
          city: json['city'] as String,
          district: json['district'] as String?,
          state: json['state'] as String,
          pincode: json['pincode'] as String,
          latitude: (json['latitude'] as num?)?.toDouble(),
          longitude: (json['longitude'] as num?)?.toDouble(),
          serviceRadiusKm: (json['service_radius_km'] as num?)?.toInt() ?? 10,
          profileImage: json['profile_image'] as String?,
          categories: (json['categories'] as List<dynamic>)
              .map((e) =>
                  ServiceCategorySelection.fromJson(e as Map<String, dynamic>))
              .toList(),
        );

Map<String, dynamic> _$$VendorRegistrationRequestModelImplToJson(
        _$VendorRegistrationRequestModelImpl instance) =>
    <String, dynamic>{
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'father_name': instance.fatherName,
      'email': instance.email,
      'mobile': instance.mobile,
      'alternative_number': instance.altMobile,
      'business_name': instance.businessName,
      'aadhaar_number': instance.aadhaarNumber,
      'address': instance.address,
      'street': instance.street,
      'city': instance.city,
      'district': instance.district,
      'state': instance.state,
      'pincode': instance.pincode,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'service_radius_km': instance.serviceRadiusKm,
      'profile_image': instance.profileImage,
      'categories': instance.categories,
    };
