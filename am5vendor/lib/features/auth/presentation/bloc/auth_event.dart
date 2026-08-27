import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_event.freezed.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.verifyAndLogin({
    required String contact,
    required String otp,
  }) = VerifyAndLogin;

  const factory AuthEvent.loginWithGoogle() = LoginWithGoogleEvent;

  const factory AuthEvent.checkSession() = CheckSessionEvent;

  const factory AuthEvent.logout() = LogoutEvent;

  const factory AuthEvent.deleteAccount() = DeleteAccountEvent;

  const factory AuthEvent.loginEmployee({
    required String email,
    required String password,
  }) = LoginEmployee;
}
