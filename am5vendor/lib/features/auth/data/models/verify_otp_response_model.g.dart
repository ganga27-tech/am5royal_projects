// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_otp_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VerifyOtpResponseModelImpl _$$VerifyOtpResponseModelImplFromJson(
        Map<String, dynamic> json) =>
    _$VerifyOtpResponseModelImpl(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      isNewUser: json['is_new_user'] as bool,
    );

Map<String, dynamic> _$$VerifyOtpResponseModelImplToJson(
        _$VerifyOtpResponseModelImpl instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'token_type': instance.tokenType,
      'is_new_user': instance.isNewUser,
    };
