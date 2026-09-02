part of 'auth_bloc.dart';

enum AuthStatus { unknown, loading, authenticated, unauthenticated }

final class AuthState extends Equatable {
  const AuthState({
    required this.status,
    this.user,
    this.message,
    this.otpDestination,
    this.resetToken,
  });

  const AuthState.unknown() : this(status: AuthStatus.unknown);

  const AuthState.unauthenticated({String? message})
      : this(status: AuthStatus.unauthenticated, message: message);

  factory AuthState.authenticated(LivoraUser user) =>
      AuthState(status: AuthStatus.authenticated, user: user);

  final AuthStatus status;
  final LivoraUser? user;
  final String? message;
  final String? otpDestination;
  final String? resetToken;

  AuthState copyWith({
    AuthStatus? status,
    LivoraUser? user,
    String? message,
    String? otpDestination,
    String? resetToken,
    bool clearMessage = false,
    bool clearOtpDestination = false,
    bool clearResetToken = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      message: clearMessage ? null : (message ?? this.message),
      otpDestination: clearOtpDestination ? null : (otpDestination ?? this.otpDestination),
      resetToken: clearResetToken ? null : (resetToken ?? this.resetToken),
    );
  }

  @override
  List<Object?> get props => [status, user, message, otpDestination, resetToken];
}
