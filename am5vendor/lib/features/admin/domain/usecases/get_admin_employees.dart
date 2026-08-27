import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/admin_employee.dart';
import '../repositories/admin_repository.dart';

class GetAdminEmployees implements UseCase<List<AdminEmployee>, NoParams> {
  final AdminRepository repository;

  GetAdminEmployees(this.repository);

  @override
  Future<Either<Failure, List<AdminEmployee>>> call(NoParams params) async {
    return await repository.getEmployees();
  }
}
