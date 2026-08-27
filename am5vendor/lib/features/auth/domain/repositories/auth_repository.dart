import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth.dart';
import '../entities/send_otp_response.dart';
import '../entities/verify_otp_response.dart';
import '../../data/models/vendor_registration_request_model.dart';
import '../../data/models/vendor_business_details_request_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, Auth>> loginWithOtp({
    required String contact,
    required String otp,
  });

  Future<Either<Failure, Auth>> loginWithGoogle();

  Future<Either<Failure, Auth>> checkSession();

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, SendOtpResponse>> sendOtp({
    required String contact,
  });

  Future<Either<Failure, VerifyOtpResponse>> verifyOtp({
    required String contact,
    required String otp,
  });

  Future<Either<Failure, VerifyOtpResponse>> registerVendor(
    VendorRegistrationRequestModel request,
  );

  Future<Either<Failure, void>> submitBusinessDetails(
    VendorBusinessDetailsRequestModel request,
  );

  Future<Either<Failure, void>> deleteAccount();

  Future<Either<Failure, Auth>> loginEmployee({
    required String email,
    required String password,
  });
}
