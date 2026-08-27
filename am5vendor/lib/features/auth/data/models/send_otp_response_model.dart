import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/send_otp_response.dart';

part 'send_otp_response_model.freezed.dart';
part 'send_otp_response_model.g.dart';

@freezed
class SendOtpResponseModel with _$SendOtpResponseModel {
  const SendOtpResponseModel._();

  const factory SendOtpResponseModel({
    required String message,
    required String identifier,
  }) = _SendOtpResponseModel;

  factory SendOtpResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SendOtpResponseModelFromJson(json);

  SendOtpResponse toEntity() {
    return SendOtpResponse(
      message: message,
      identifier: identifier,
    );
  }
}
