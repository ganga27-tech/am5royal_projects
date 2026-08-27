import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/main_category.dart';
import '../../domain/entities/subcategory_entity.dart';
import '../../domain/repositories/main_category_repository.dart';
import '../datasources/main_category_remote_data_source.dart';

class MainCategoryRepositoryImpl implements MainCategoryRepository {
  final MainCategoryRemoteDataSource remoteDataSource;

  MainCategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<MainCategory>>> getMainCategories() async {
    try {
      final models = await remoteDataSource.getMainCategories();
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SubCategoryEntity>>> getSubCategories(int categoryId) async {
    try {
      final models = await remoteDataSource.getSubCategories(categoryId);
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
