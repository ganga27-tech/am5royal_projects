import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/dio_factory.dart';
import '../../../../core/network/auth_interceptor.dart';
import '../../../../core/services/auth_storage_service.dart';
import '../../data/datasources/auth_api_service.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/register_vendor_usecase.dart';
import '../bloc/send_otp_bloc.dart';
import '../bloc/verify_otp_bloc.dart';
import '../bloc/register_vendor_bloc.dart';

// Provide Auth Storage Service
final authStorageServiceProvider = Provider<AuthStorageService>((ref) {
  final sharedPrefs = GetIt.instance<SharedPreferences>();
  return AuthStorageService(sharedPrefs);
});

// Provide Dio
final dioProvider = Provider<Dio>((ref) {
  return createConfiguredDio(
    authInterceptor: AuthInterceptor(ref.watch(authStorageServiceProvider)),
  );
});

// Provide ApiClient (using Dio)
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});

// Provide API service
final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService(ref.watch(dioProvider));
});

// Provide Remote Data Source
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    ref.watch(apiClientProvider),
    ref.watch(authApiServiceProvider),
  );
});

// Provide Local Data Source
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final sharedPrefs = GetIt.instance<SharedPreferences>();
  return AuthLocalDataSourceImpl(sharedPreferences: sharedPrefs);
});

// Provide Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
    authStorageService: ref.watch(authStorageServiceProvider),
  );
});

// Provide SendOtpUseCase
final sendOtpUseCaseProvider = Provider<SendOtpUseCase>((ref) {
  return SendOtpUseCase(ref.watch(authRepositoryProvider));
});

// Provide SendOtpBloc
final sendOtpBlocProvider = Provider.autoDispose<SendOtpBloc>((ref) {
  final bloc = SendOtpBloc(sendOtpUseCase: ref.watch(sendOtpUseCaseProvider));
  ref.onDispose(() => bloc.close());
  return bloc;
});

// Provide VerifyOtpUseCase
final verifyOtpUseCaseProvider = Provider<VerifyOtpUseCase>((ref) {
  return VerifyOtpUseCase(ref.watch(authRepositoryProvider));
});

// Provide VerifyOtpBloc
final verifyOtpBlocProvider = Provider.autoDispose<VerifyOtpBloc>((ref) {
  final bloc = VerifyOtpBloc(verifyOtpUseCase: ref.watch(verifyOtpUseCaseProvider));
  ref.onDispose(() => bloc.close());
  return bloc;
});

// Provide RegisterVendorUseCase
final registerVendorUseCaseProvider = Provider<RegisterVendorUseCase>((ref) {
  return RegisterVendorUseCase(ref.watch(authRepositoryProvider));
});

// Provide RegisterVendorBloc
final registerVendorBlocProvider = Provider.autoDispose<RegisterVendorBloc>((ref) {
  final bloc = RegisterVendorBloc(registerVendorUseCase: ref.watch(registerVendorUseCaseProvider));
  ref.onDispose(() => bloc.close());
  return bloc;
});
