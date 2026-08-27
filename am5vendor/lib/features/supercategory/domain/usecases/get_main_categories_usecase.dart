import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/main_category.dart';
import '../repositories/main_category_repository.dart';

class GetMainCategoriesUseCase {
  final MainCategoryRepository repository;

  GetMainCategoriesUseCase(this.repository);

  Future<Either<Failure, List<MainCategory>>> call() async {
    return await repository.getMainCategories();
  }
}
