import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/auth_storage_service.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../domain/entities/auth.dart';
import '../../domain/entities/send_otp_response.dart';
import '../../domain/entities/verify_otp_response.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/send_otp_request_model.dart';
import '../models/verify_otp_request_model.dart';
import '../models/auth_model.dart';
import '../models/vendor_registration_request_model.dart';
import '../models/vendor_business_details_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final AuthStorageService authStorageService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.authStorageService,
  });

  @override
  Future<Either<Failure, Auth>> loginWithOtp({
    required String contact,
    required String otp,
  }) async {
    try {
      final remoteModel = await remoteDataSource.loginWithOtp(
        contact: contact,
        otp: otp,
      );
      await localDataSource.cacheAuth(remoteModel);
      await authStorageService.saveAccessToken(
        remoteModel.token,
        tokenType: 'Bearer',
      );
      return Right(remoteModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Auth>> loginWithGoogle() async {
    try {
      final remoteModel = await remoteDataSource.loginWithGoogle();
      await localDataSource.cacheAuth(remoteModel);
      await authStorageService.saveAccessToken(
        remoteModel.token,
        tokenType: 'Bearer',
      );
      return Right(remoteModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Auth>> checkSession() async {
    try {
      final token = authStorageService.getAccessToken();
      if (token == null || token.isEmpty) {
        throw CacheException('No access token found.');
      }
      final localModel = await localDataSource.getLastAuth();
      return Right(localModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearAuth();
      await authStorageService.clearAccessToken();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SendOtpResponse>> sendOtp({
    required String contact,
  }) async {
    try {
      final isEmail = AuthValidator.isValidEmail(contact);
      final request = SendOtpRequestModel(
        mobile: isEmail ? '' : contact,
        email: isEmail ? contact : '',
        platform: kIsWeb ? 'web' : 'mobile',
      );
      final responseModel = await remoteDataSource.sendOtp(request);
      return Right(responseModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VerifyOtpResponse>> verifyOtp({
    required String contact,
    required String otp,
  }) async {
    try {
      final isEmail = AuthValidator.isValidEmail(contact);
      final request = VerifyOtpRequestModel(
        mobile: isEmail ? '' : contact,
        email: isEmail ? contact : '',
        otp: otp,
        platform: kIsWeb ? 'web' : 'mobile',
      );
      final responseModel = await remoteDataSource.verifyOtp(request);

      // Save the received access token inside the centralized Auth Storage service
      await authStorageService.saveAccessToken(
        responseModel.accessToken,
        tokenType: responseModel.tokenType,
      );
      await authStorageService.saveLoginContact(contact);
      await localDataSource.cacheAuth(
        AuthModel(
          id: 'vendor',
          contact: contact,
          token: responseModel.accessToken,
        ),
      );

      // Immediately sync FCM token to backend after token is stored
      try {
        await PushNotificationService().getToken();
      } catch (_) {}

      return Right(responseModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VerifyOtpResponse>> registerVendor(
    VendorRegistrationRequestModel request,
  ) async {
    try {
      final responseModel = await remoteDataSource.registerVendor(request);

      // Save the received access token inside the centralized Auth Storage service
      await authStorageService.saveAccessToken(
        responseModel.accessToken,
        tokenType: responseModel.tokenType,
      );

      return Right(VerifyOtpResponse(
        accessToken: responseModel.accessToken,
        tokenType: responseModel.tokenType,
        isNewUser: responseModel.isNewUser,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitBusinessDetails(
    VendorBusinessDetailsRequestModel request,
  ) async {
    try {
      await remoteDataSource.submitBusinessDetails(request);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await remoteDataSource.deleteAccount();
      await localDataSource.clearAuth();
      await authStorageService.clearAccessToken();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Auth>> loginEmployee({
    required String email,
    required String password,
  }) async {
    try {
      final remoteModel = await remoteDataSource.loginEmployee(
        email: email,
        password: password,
      );
      await localDataSource.cacheAuth(remoteModel);
      await authStorageService.saveAccessToken(
        remoteModel.token,
        tokenType: 'Bearer',
      );
      return Right(remoteModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
