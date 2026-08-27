import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/admin_repository.dart';

class CreateService {
  final AdminRepository repository;

  CreateService(this.repository);

  Future<Either<Failure, void>> call(String name, int mainCategoryId, int subCategoryId, String imagePath) async {
    return await repository.createService(name, mainCategoryId, subCategoryId, imagePath);
  }
}
