import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts({String? search});
  Future<Either<Failure, Product>> getProduct(String id);
  Future<Either<Failure, Product>> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required String imageUrl,
    required String category,
  });
  Future<Either<Failure, Product>> updateProduct({
    required String id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? imageUrl,
    String? category,
  });
  Future<Either<Failure, Product>> deleteProduct(String id);
}
