import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/admin_repository.dart';

class UpdateVendor implements UseCase<void, UpdateVendorParams> {
  final AdminRepository repository;

  UpdateVendor(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateVendorParams params) async {
    return await repository.updateVendor(params.id, params.data);
  }
}

class UpdateVendorParams extends Equatable {
  final int id;
  final Map<String, dynamic> data;

  const UpdateVendorParams({required this.id, required this.data});

  @override
  List<Object> get props => [id, data];
}
