// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_otp_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VerifyOtpRequestModelImpl _$$VerifyOtpRequestModelImplFromJson(
        Map<String, dynamic> json) =>
    _$VerifyOtpRequestModelImpl(
      mobile: json['mobile'] as String,
      email: json['email'] as String,
      otp: json['otp'] as String,
      platform: json['platform'] as String? ?? 'mobile',
    );

Map<String, dynamic> _$$VerifyOtpRequestModelImplToJson(
        _$VerifyOtpRequestModelImpl instance) =>
    <String, dynamic>{
      'mobile': instance.mobile,
      'email': instance.email,
      'otp': instance.otp,
      'platform': instance.platform,
    };
