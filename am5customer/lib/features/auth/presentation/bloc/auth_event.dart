part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthStarted extends AuthEvent {
  const AuthStarted();
}

final class AuthLoginSubmitted extends AuthEvent {
  const AuthLoginSubmitted({required this.email, required this.password});
  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

final class AuthRegisterSubmitted extends AuthEvent {
  const AuthRegisterSubmitted({
    required this.fullName,
    required this.email,
    required this.password,
    this.phone,
  });

  final String fullName;
  final String email;
  final String password;
  final String? phone;

  @override
  List<Object?> get props => [fullName, email, password, phone];
}

final class AuthPhoneOtpRequested extends AuthEvent {
  const AuthPhoneOtpRequested(this.phone);
  final String phone;

  @override
  List<Object?> get props => [phone];
}

final class AuthOtpVerified extends AuthEvent {
  const AuthOtpVerified({required this.destination, required this.code});
  final String destination;
  final String code;

  @override
  List<Object?> get props => [destination, code];
}

final class AuthForgotPasswordSubmitted extends AuthEvent {
  const AuthForgotPasswordSubmitted(this.email);
  final String email;

  @override
  List<Object?> get props => [email];
}

final class AuthResetPasswordSubmitted extends AuthEvent {
  const AuthResetPasswordSubmitted({required this.token, required this.newPassword});
  final String token;
  final String newPassword;

  @override
  List<Object?> get props => [token, newPassword];
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

final class AuthSessionExpired extends AuthEvent {
  const AuthSessionExpired();
}

final class AuthEmailVerified extends AuthEvent {
  const AuthEmailVerified({required this.email, required this.code});
  final String email;
  final String code;

  @override
  List<Object?> get props => [email, code];
}

final class AuthEmailResendRequested extends AuthEvent {
  const AuthEmailResendRequested(this.email);
  final String email;

  @override
  List<Object?> get props => [email];
}

final class AuthMessageCleared extends AuthEvent {
  const AuthMessageCleared();
}
