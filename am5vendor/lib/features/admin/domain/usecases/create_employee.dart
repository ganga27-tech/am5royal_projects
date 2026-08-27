import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/admin_repository.dart';

class CreateEmployeeParams extends Equatable {
  final Map<String, dynamic> data;

  const CreateEmployeeParams({required this.data});

  @override
  List<Object?> get props => [data];
}

class CreateEmployee implements UseCase<void, CreateEmployeeParams> {
  final AdminRepository repository;

  CreateEmployee(this.repository);

  @override
  Future<Either<Failure, void>> call(CreateEmployeeParams params) async {
    return await repository.createEmployee(params.data);
  }
}
