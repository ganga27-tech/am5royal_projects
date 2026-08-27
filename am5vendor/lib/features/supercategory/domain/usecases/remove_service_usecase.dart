import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/service_repository.dart';

class RemoveServiceUseCase {
  final ServiceRepository repository;

  RemoveServiceUseCase(this.repository);

  Future<Either<Failure, void>> call(int serviceId) async {
    return await repository.removeService(serviceId);
  }
}
