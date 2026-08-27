import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/admin_repository.dart';

class DeleteVendor implements UseCase<void, DeleteVendorParams> {
  final AdminRepository repository;

  DeleteVendor(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteVendorParams params) async {
    return await repository.deleteVendor(params.id);
  }
}

class DeleteVendorParams extends Equatable {
  final int id;

  const DeleteVendorParams({required this.id});

  @override
  List<Object> get props => [id];
}
