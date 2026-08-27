import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/admin_repository.dart';

class UpdateVendorStatusParams extends Equatable {
  final int vendorId;
  final String status;

  const UpdateVendorStatusParams({required this.vendorId, required this.status});

  @override
  List<Object?> get props => [vendorId, status];
}

class UpdateVendorStatus implements UseCase<void, UpdateVendorStatusParams> {
  final AdminRepository repository;

  UpdateVendorStatus(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateVendorStatusParams params) async {
    return await repository.updateVendorStatus(params.vendorId, params.status);
  }
}
