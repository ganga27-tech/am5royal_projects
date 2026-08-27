import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/main_category.dart';
import '../entities/subcategory_entity.dart';

abstract class MainCategoryRepository {
  Future<Either<Failure, List<MainCategory>>> getMainCategories();
  Future<Either<Failure, List<SubCategoryEntity>>> getSubCategories(int categoryId);
}
