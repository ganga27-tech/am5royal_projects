import 'package:freezed_annotation/freezed_annotation.dart';

part 'vendor_registration_request_model.freezed.dart';
part 'vendor_registration_request_model.g.dart';

@freezed
class ServiceCategorySelection with _$ServiceCategorySelection {
  const factory ServiceCategorySelection({
    @JsonKey(name: 'main_category_id') required int mainCategoryId,
    @JsonKey(name: 'sub_category_ids') required List<int> subCategoryIds,
  }) = _ServiceCategorySelection;

  factory ServiceCategorySelection.fromJson(Map<String, dynamic> json) =>
      _$ServiceCategorySelectionFromJson(json);
}

@freezed
class VendorRegistrationRequestModel with _$VendorRegistrationRequestModel {
  const factory VendorRegistrationRequestModel({
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'father_name') String? fatherName,
    String? email,
    @JsonKey(name: 'mobile') String? mobile,
    @JsonKey(name: 'alternative_number') String? altMobile,
    @JsonKey(name: 'business_name') required String businessName,
    @JsonKey(name: 'aadhaar_number') required String aadhaarNumber,
    required String address,
    String? street,
    required String city,
    String? district,
    required String state,
    required String pincode,
    required double? latitude,
    required double? longitude,
    @JsonKey(name: 'service_radius_km') @Default(10) int? serviceRadiusKm,
    @JsonKey(name: 'profile_image') String? profileImage,
    required List<ServiceCategorySelection> categories,
  }) = _VendorRegistrationRequestModel;

  factory VendorRegistrationRequestModel.fromJson(Map<String, dynamic> json) =>
      _$VendorRegistrationRequestModelFromJson(json);
}
