import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/admin_repository.dart';

class UpdateEmployeeParams extends Equatable {
  final int id;
  final Map<String, dynamic> data;

  const UpdateEmployeeParams({required this.id, required this.data});

  @override
  List<Object?> get props => [id, data];
}

class UpdateEmployee implements UseCase<void, UpdateEmployeeParams> {
  final AdminRepository repository;

  UpdateEmployee(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateEmployeeParams params) async {
    return await repository.updateEmployee(params.id, params.data);
  }
}
