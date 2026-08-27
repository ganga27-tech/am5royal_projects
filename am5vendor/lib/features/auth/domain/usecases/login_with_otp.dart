import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/auth.dart';
import '../repositories/auth_repository.dart';

class LoginWithOtp implements UseCase<Auth, LoginWithOtpParams> {
  final AuthRepository repository;

  LoginWithOtp(this.repository);

  @override
  Future<Either<Failure, Auth>> call(LoginWithOtpParams params) {
    // Validate inputs at the usecase level
    if (!AuthValidator.isValidContact(params.contact)) {
      return Future.value(const Left(ValidationFailure('Please enter a valid mobile number or email address.')));
    }
    if (!AuthValidator.isValidOtp(params.otp)) {
      return Future.value(const Left(ValidationFailure('Please enter a valid 6-digit OTP.')));
    }

    return repository.loginWithOtp(
      contact: params.contact,
      otp: params.otp,
    );
  }
}

class LoginWithOtpParams extends Equatable {
  final String contact;
  final String otp;

  const LoginWithOtpParams({
    required this.contact,
    required this.otp,
  });

  @override
  List<Object?> get props => [contact, otp];
}
