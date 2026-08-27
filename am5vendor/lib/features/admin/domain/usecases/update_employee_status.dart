import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/admin_repository.dart';

class UpdateEmployeeStatusParams extends Equatable {
  final int employeeId;
  final String status;

  const UpdateEmployeeStatusParams({required this.employeeId, required this.status});

  @override
  List<Object?> get props => [employeeId, status];
}

class UpdateEmployeeStatus implements UseCase<void, UpdateEmployeeStatusParams> {
  final AdminRepository repository;

  UpdateEmployeeStatus(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateEmployeeStatusParams params) async {
    return await repository.updateEmployeeStatus(params.employeeId, params.status);
  }
}
