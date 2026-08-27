import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Product>>> getProducts({String? search}) async {
    try {
      final remoteProducts = await remoteDataSource.getProducts(search: search);
      final products = remoteProducts.map((model) => model.toEntity()).toList();
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> getProduct(String id) async {
    try {
      final remoteProduct = await remoteDataSource.getProduct(id);
      return Right(remoteProduct.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required String imageUrl,
    required String category,
  }) async {
    try {
      final remoteProduct = await remoteDataSource.createProduct(
        name: name,
        description: description,
        price: price,
        stock: stock,
        imageUrl: imageUrl,
        category: category,
      );
      return Right(remoteProduct.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> updateProduct({
    required String id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? imageUrl,
    String? category,
  }) async {
    try {
      final remoteProduct = await remoteDataSource.updateProduct(
        id: id,
        name: name,
        description: description,
        price: price,
        stock: stock,
        imageUrl: imageUrl,
        category: category,
      );
      return Right(remoteProduct.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> deleteProduct(String id) async {
    try {
      final remoteProduct = await remoteDataSource.deleteProduct(id);
      return Right(remoteProduct.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
