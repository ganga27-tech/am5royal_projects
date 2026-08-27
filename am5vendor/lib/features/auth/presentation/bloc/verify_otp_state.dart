import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/verify_otp_response.dart';

part 'verify_otp_state.freezed.dart';

@freezed
class VerifyOtpState with _$VerifyOtpState {
  const factory VerifyOtpState.initial() = VerifyOtpInitial;
  const factory VerifyOtpState.loading() = VerifyOtpLoading;
  const factory VerifyOtpState.success(VerifyOtpResponse response) = VerifyOtpSuccess;
  const factory VerifyOtpState.error(String message) = VerifyOtpError;
}
