import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/auth.dart';
import '../repositories/auth_repository.dart';

class CheckSession implements UseCase<Auth, NoParams> {
  final AuthRepository repository;

  CheckSession(this.repository);

  @override
  Future<Either<Failure, Auth>> call(NoParams params) {
    return repository.checkSession();
  }
}
