import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/send_otp_response.dart';

part 'send_otp_state.freezed.dart';

@freezed
class SendOtpState with _$SendOtpState {
  const factory SendOtpState.initial() = SendOtpInitial;
  const factory SendOtpState.loading() = SendOtpLoading;
  const factory SendOtpState.success(SendOtpResponse response) = SendOtpSuccess;
  const factory SendOtpState.error(String message) = SendOtpError;
}
