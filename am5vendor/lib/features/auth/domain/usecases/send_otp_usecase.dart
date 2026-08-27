import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/auth.dart';
import '../entities/send_otp_response.dart';
import '../repositories/auth_repository.dart';

class SendOtpUseCase implements UseCase<SendOtpResponse, SendOtpParams> {
  final AuthRepository repository;

  SendOtpUseCase(this.repository);

  @override
  Future<Either<Failure, SendOtpResponse>> call(SendOtpParams params) {
    final contact = params.contact.trim();
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
    return repository.sendOtp(contact: contact);
  }
}

class SendOtpParams extends Equatable {
  final String contact;

  const SendOtpParams({required this.contact});

  @override
  List<Object?> get props => [contact];
}
