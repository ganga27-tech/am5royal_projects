import 'package:freezed_annotation/freezed_annotation.dart';

part 'vendor_registration_response_model.freezed.dart';
part 'vendor_registration_response_model.g.dart';

@freezed
class VendorRegistrationResponseModel with _$VendorRegistrationResponseModel {
  const factory VendorRegistrationResponseModel({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'token_type') @Default('bearer') String tokenType,
    @JsonKey(name: 'is_new_user') @Default(false) bool isNewUser,
  }) = _VendorRegistrationResponseModel;

  factory VendorRegistrationResponseModel.fromJson(Map<String, dynamic> json) =>
      _$VendorRegistrationResponseModelFromJson(json);
}
