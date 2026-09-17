import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthApi authApi,
    required DeviceInfo device,
  })  : _authApi = authApi,
        _device = device,
        super(const AuthState.unknown()) {
    on<AuthStarted>(_onStarted);
    on<AuthPhoneOtpRequested>(_onPhoneOtp);
    on<AuthOtpVerified>(_onOtpVerify);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthSessionExpired>(_onSessionExpired);
    on<AuthSessionRefreshed>(_onSessionRefreshed);
    on<AuthMessageCleared>(_onClearMessage);
  }

  final AuthApi _authApi;
  final DeviceInfo _device;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, clearMessage: true));
    try {
      final hasSession = await _authApi.hasSavedSession();
      if (!hasSession) {
        emit(const AuthState.unauthenticated());
        return;
      }
      final user = await _authApi.me().timeout(const Duration(seconds: 8));
      emit(AuthState.authenticated(user));
    } catch (_) {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onPhoneOtp(AuthPhoneOtpRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, clearMessage: true, clearOtpDestination: true));
    try {
      await _authApi.requestOtp(
        identifier: event.phone,
        platform: _device.platform ?? 'mobile',
      );
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          otpDestination: event.phone,
          message: 'OTP sent successfully',
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, message: f.message));
    }
  }

  Future<void> _onOtpVerify(AuthOtpVerified event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, clearMessage: true));
    try {
      final tokens = await _authApi.verifyOtp(
        destination: event.destination,
        code: event.code,
        device: _device,
      );
      emit(AuthState.authenticated(tokens.user));
    } on Failure catch (f) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, message: f.message));
    }
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _authApi.logout();
    emit(const AuthState.unauthenticated());
  }

  Future<void> _onSessionExpired(AuthSessionExpired event, Emitter<AuthState> emit) async {
    await _authApi.logout();
    emit(
      const AuthState.unauthenticated(
        message: 'Your session expired. Please sign in again.',
      ),
    );
  }

  Future<void> _onSessionRefreshed(AuthSessionRefreshed event, Emitter<AuthState> emit) async {
    try {
      final user = await _authApi.me();
      emit(AuthState.authenticated(user));
    } on Failure catch (f) {
      emit(AuthState.unauthenticated(message: f.message));
    } catch (_) {
      emit(const AuthState.unauthenticated());
    }
  }

  void _onClearMessage(AuthMessageCleared event, Emitter<AuthState> emit) {
    emit(state.copyWith(clearMessage: true));
  }
}
