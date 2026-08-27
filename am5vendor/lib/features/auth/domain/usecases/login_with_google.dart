import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/auth.dart';
import '../repositories/auth_repository.dart';

class LoginWithGoogle implements UseCase<Auth, NoParams> {
  final AuthRepository repository;

  LoginWithGoogle(this.repository);

  @override
  Future<Either<Failure, Auth>> call(NoParams params) {
    return repository.loginWithGoogle();
  }
}
