// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_otp_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SendOtpRequestModelImpl _$$SendOtpRequestModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SendOtpRequestModelImpl(
      mobile: json['mobile'] as String,
      email: json['email'] as String,
      platform: json['platform'] as String? ?? 'mobile',
    );

Map<String, dynamic> _$$SendOtpRequestModelImplToJson(
        _$SendOtpRequestModelImpl instance) =>
    <String, dynamic>{
      'mobile': instance.mobile,
      'email': instance.email,
      'platform': instance.platform,
    };
