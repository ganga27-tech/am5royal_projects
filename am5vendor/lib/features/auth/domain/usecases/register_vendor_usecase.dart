import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/vendor_registration_request_model.dart';
import '../entities/verify_otp_response.dart';
import '../repositories/auth_repository.dart';

class RegisterVendorUseCase implements UseCase<VerifyOtpResponse, RegisterVendorParams> {
  final AuthRepository repository;

  RegisterVendorUseCase(this.repository);

  @override
  Future<Either<Failure, VerifyOtpResponse>> call(RegisterVendorParams params) {
    return repository.registerVendor(params.request);
  }
}

class RegisterVendorParams extends Equatable {
  final VendorRegistrationRequestModel request;

  const RegisterVendorParams({required this.request});

  @override
  List<Object?> get props => [request];
}
