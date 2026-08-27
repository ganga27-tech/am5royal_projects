import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/login_with_otp.dart';
import '../../domain/usecases/login_with_google.dart';
import '../../domain/usecases/check_session.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/delete_account.dart';
import '../../domain/usecases/login_employee.dart' as uc;
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../device_tracking/presentation/bloc/device_tracking_bloc.dart';
import '../../../device_tracking/presentation/bloc/device_tracking_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithOtp loginWithOtp;
  final LoginWithGoogle loginWithGoogle;
  final CheckSession checkSession;
  final Logout logout;
  final DeleteAccount deleteAccount;
  final uc.LoginEmployee loginEmployee;

  AuthBloc({
    required this.loginWithOtp,
    required this.loginWithGoogle,
    required this.checkSession,
    required this.logout,
    required this.deleteAccount,
    required this.loginEmployee,
  }) : super(const AuthState.initial()) {
    on<VerifyAndLogin>(_onVerifyAndLogin);
    on<LoginWithGoogleEvent>(_onLoginWithGoogle);
    on<CheckSessionEvent>(_onCheckSession);
    on<LogoutEvent>(_onLogout);
    on<DeleteAccountEvent>(_onDeleteAccount);
    on<LoginEmployee>(_onLoginEmployee);
  }

  Future<void> _onVerifyAndLogin(VerifyAndLogin event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    final result = await loginWithOtp(LoginWithOtpParams(
      contact: event.contact,
      otp: event.otp,
    ));
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (auth) {
        PushNotificationService().getToken(); // Sync token on success
        di.sl<DeviceTrackingBloc>().add(SyncDeviceEvent()); // Link device to user
        emit(AuthState.success(
          message: 'Login Successful! Welcome to AM5 Royal.',
          auth: auth,
        ));
      },
    );
  }

  Future<void> _onLoginWithGoogle(LoginWithGoogleEvent event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    final result = await loginWithGoogle(const NoParams());
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (auth) => emit(AuthState.success(
        message: 'Google Sign-In Successful! Welcome to AM5 Royal.',
        auth: auth,
      )),
    );
  }

  Future<void> _onCheckSession(CheckSessionEvent event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    final result = await checkSession(const NoParams());
    result.fold(
      (failure) => emit(const AuthState.initial()),
      (auth) => emit(AuthState.success(
        message: 'Welcome back!',
        auth: auth,
      )),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    final result = await logout(const NoParams());
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (_) => emit(const AuthState.initial()),
    );
  }

  Future<void> _onDeleteAccount(DeleteAccountEvent event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    final result = await deleteAccount(const NoParams());
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (_) => emit(const AuthState.initial()), // Go back to login screen
    );
  }

  Future<void> _onLoginEmployee(LoginEmployee event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    final result = await loginEmployee(uc.LoginEmployeeParams(
      identifier: event.email,
      password: event.password,
    ));
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (auth) {
        PushNotificationService().getToken(); // Sync token on success
        di.sl<DeviceTrackingBloc>().add(SyncDeviceEvent()); // Link device to user
        emit(AuthState.success(
          message: 'Employee Login Successful! Welcome to AM5 Royal.',
          auth: auth,
        ));
      },
    );
  }
}
