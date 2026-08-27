import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/subcategory_entity.dart';
import '../repositories/main_category_repository.dart';

class GetSubCategoriesUseCase {
  final MainCategoryRepository repository;

  GetSubCategoriesUseCase(this.repository);

  Future<Either<Failure, List<SubCategoryEntity>>> call(int categoryId) async {
    return await repository.getSubCategories(categoryId);
  }
}
