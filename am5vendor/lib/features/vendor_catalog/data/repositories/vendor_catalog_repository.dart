import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../datasources/vendor_catalog_remote_data_source.dart';
import '../models/vendor_catalog_models.dart';

class VendorCatalogRepository {
  final VendorCatalogRemoteDataSource remoteDataSource;

  VendorCatalogRepository(this.remoteDataSource);

  Future<Either<Failure, VendorCatalogModel>> getCatalog() async {
    try {
      final catalog = await remoteDataSource.fetchCatalog();
      return Right(catalog);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> addCategories({
    required int mainCategoryId,
    required List<int> subCategoryIds,
  }) async {
    try {
      await remoteDataSource.addCategories(
        mainCategoryId: mainCategoryId,
        subCategoryIds: subCategoryIds,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> removeSubCategory(int subCategoryId) async {
    try {
      await remoteDataSource.removeSubCategory(subCategoryId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> updateService({
    required int vendorServiceId,
    required double price,
    String? description,
    required bool negotiable,
    List<Map<String, String>>? media,
  }) async {
    try {
      await remoteDataSource.updateService(
        vendorServiceId: vendorServiceId,
        price: price,
        description: description,
        negotiable: negotiable,
        media: media,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteService(int vendorServiceId) async {
    try {
      await remoteDataSource.deleteService(vendorServiceId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, int>> proceedToPayment() async {
    try {
      final count = await remoteDataSource.proceedToPayment();
      return Right(count);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
