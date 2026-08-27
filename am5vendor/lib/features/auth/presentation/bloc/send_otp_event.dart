import 'package:freezed_annotation/freezed_annotation.dart';

part 'send_otp_event.freezed.dart';

@freezed
class SendOtpEvent with _$SendOtpEvent {
  const factory SendOtpEvent.submit(String contact) = Submit;
}
