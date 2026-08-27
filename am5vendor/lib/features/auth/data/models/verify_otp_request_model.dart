import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_otp_request_model.freezed.dart';
part 'verify_otp_request_model.g.dart';

@freezed
class VerifyOtpRequestModel with _$VerifyOtpRequestModel {
  const factory VerifyOtpRequestModel({
    required String mobile,
    required String email,
    required String otp,
    @Default('mobile') String platform,
  }) = _VerifyOtpRequestModel;

  factory VerifyOtpRequestModel.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpRequestModelFromJson(json);
}
