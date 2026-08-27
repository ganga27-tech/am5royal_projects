import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_otp_event.freezed.dart';

@freezed
class VerifyOtpEvent with _$VerifyOtpEvent {
  const factory VerifyOtpEvent.submit({
    required String contact,
    required String otp,
  }) = SubmitVerifyOtp;
}
