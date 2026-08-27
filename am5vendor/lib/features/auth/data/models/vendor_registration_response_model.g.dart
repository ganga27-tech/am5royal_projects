// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_registration_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VendorRegistrationResponseModelImpl
    _$$VendorRegistrationResponseModelImplFromJson(Map<String, dynamic> json) =>
        _$VendorRegistrationResponseModelImpl(
          accessToken: json['access_token'] as String,
          tokenType: json['token_type'] as String? ?? 'bearer',
          isNewUser: json['is_new_user'] as bool? ?? false,
        );

Map<String, dynamic> _$$VendorRegistrationResponseModelImplToJson(
        _$VendorRegistrationResponseModelImpl instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'token_type': instance.tokenType,
      'is_new_user': instance.isNewUser,
    };
