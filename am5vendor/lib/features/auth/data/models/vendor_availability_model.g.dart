// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_availability_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VendorAvailabilityModelImpl _$$VendorAvailabilityModelImplFromJson(
        Map<String, dynamic> json) =>
    _$VendorAvailabilityModelImpl(
      dayOfWeek: (json['day_of_week'] as num).toInt(),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      isAvailable: json['is_available'] as bool,
    );

Map<String, dynamic> _$$VendorAvailabilityModelImplToJson(
        _$VendorAvailabilityModelImpl instance) =>
    <String, dynamic>{
      'day_of_week': instance.dayOfWeek,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'is_available': instance.isAvailable,
    };
