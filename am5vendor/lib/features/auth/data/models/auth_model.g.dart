// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthModelImpl _$$AuthModelImplFromJson(Map<String, dynamic> json) =>
    _$AuthModelImpl(
      id: json['id'] as String,
      contact: json['contact'] as String,
      token: json['token'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      profilePhoto: json['profile_photo'] as String?,
    );

Map<String, dynamic> _$$AuthModelImplToJson(_$AuthModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contact': instance.contact,
      'token': instance.token,
      'name': instance.name,
      'email': instance.email,
      'profile_photo': instance.profilePhoto,
    };
