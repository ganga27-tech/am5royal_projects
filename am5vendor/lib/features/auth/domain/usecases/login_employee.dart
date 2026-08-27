import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/auth.dart';
import '../repositories/auth_repository.dart';

class LoginEmployee implements UseCase<Auth, LoginEmployeeParams> {
  final AuthRepository repository;

  LoginEmployee(this.repository);

  @override
  Future<Either<Failure, Auth>> call(LoginEmployeeParams params) {
    if (params.identifier.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('Please enter a valid email address or mobile number.')));
    }
    if (params.password.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('Please enter your password.')));
    }
    if (params.password.length < 6) {
      return Future.value(const Left(ValidationFailure('Password must be at least 6 characters.')));
    }

    return repository.loginEmployee(
      email: params.identifier, // we'll pass identifier to repository
      password: params.password,
    );
  }
}

class LoginEmployeeParams extends Equatable {
  final String identifier;
  final String password;

  const LoginEmployeeParams({
    required this.identifier,
    required this.password,
  });

  @override
  List<Object?> get props => [identifier, password];
}
