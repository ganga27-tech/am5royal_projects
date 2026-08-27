import 'package:freezed_annotation/freezed_annotation.dart';

part 'vendor_availability_model.freezed.dart';
part 'vendor_availability_model.g.dart';

@freezed
class VendorAvailabilityModel with _$VendorAvailabilityModel {
  const factory VendorAvailabilityModel({
    @JsonKey(name: 'day_of_week') required int dayOfWeek,
    @JsonKey(name: 'start_time') required String startTime,
    @JsonKey(name: 'end_time') required String endTime,
    @JsonKey(name: 'is_available') required bool isAvailable,
  }) = _VendorAvailabilityModel;

  factory VendorAvailabilityModel.fromJson(Map<String, dynamic> json) =>
      _$VendorAvailabilityModelFromJson(json);
}
