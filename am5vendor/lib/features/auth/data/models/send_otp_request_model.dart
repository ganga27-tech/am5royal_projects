import 'package:freezed_annotation/freezed_annotation.dart';

part 'send_otp_request_model.freezed.dart';
part 'send_otp_request_model.g.dart';

@freezed
class SendOtpRequestModel with _$SendOtpRequestModel {
  const factory SendOtpRequestModel({
    required String mobile,
    required String email,
    @Default('mobile') String platform,
  }) = _SendOtpRequestModel;

  factory SendOtpRequestModel.fromJson(Map<String, dynamic> json) =>
      _$SendOtpRequestModelFromJson(json);
}
