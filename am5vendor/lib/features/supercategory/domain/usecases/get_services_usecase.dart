import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/service_entity.dart';
import '../repositories/service_repository.dart';

class GetServicesUseCase {
  final ServiceRepository repository;

  GetServicesUseCase(this.repository);

  Future<Either<Failure, List<ServiceEntity>>> call({
    required int mainCategoryId,
    int? subCategoryId,
  }) async {
    return await repository.getServices(
      mainCategoryId: mainCategoryId,
      subCategoryId: subCategoryId,
    );
  }
}
