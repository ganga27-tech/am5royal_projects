import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/auth.dart';
import '../entities/verify_otp_response.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase implements UseCase<VerifyOtpResponse, VerifyOtpParams> {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  @override
  Future<Either<Failure, VerifyOtpResponse>> call(VerifyOtpParams params) {
    final contact = params.contact.trim();
    final otp = params.otp.trim();

    if (contact.isEmpty) {
      return Future.value(const Left(
        ValidationFailure('Please enter a mobile number or email address.'),
      ));
    }
    if (!AuthValidator.isValidContact(contact)) {
      return Future.value(const Left(
        ValidationFailure('Please enter a valid mobile number or email address.'),
      ));
    }
    if (!AuthValidator.isValidOtp(otp)) {
      return Future.value(const Left(
        ValidationFailure('Please enter a valid 5-digit OTP.'),
      ));
    }

    return repository.verifyOtp(contact: contact, otp: otp);
  }
}

class VerifyOtpParams extends Equatable {
  final String contact;
  final String otp;

  const VerifyOtpParams({
    required this.contact,
    required this.otp,
  });

  @override
  List<Object?> get props => [contact, otp];
}
