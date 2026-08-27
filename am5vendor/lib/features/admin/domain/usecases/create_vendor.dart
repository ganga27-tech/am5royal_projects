import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/admin_repository.dart';

class CreateVendorParams extends Equatable {
  final Map<String, dynamic> data;

  const CreateVendorParams({required this.data});

  @override
  List<Object?> get props => [data];
}

class CreateVendor implements UseCase<void, CreateVendorParams> {
  final AdminRepository repository;

  CreateVendor(this.repository);

  @override
  Future<Either<Failure, void>> call(CreateVendorParams params) async {
    return await repository.createVendor(params.data);
  }
}
