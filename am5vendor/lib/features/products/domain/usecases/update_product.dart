import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class UpdateProduct implements UseCase<Product, UpdateProductParams> {
  final ProductRepository repository;

  UpdateProduct(this.repository);

  @override
  Future<Either<Failure, Product>> call(UpdateProductParams params) {
    return repository.updateProduct(
      id: params.id,
      name: params.name,
      description: params.description,
      price: params.price,
      stock: params.stock,
      imageUrl: params.imageUrl,
      category: params.category,
    );
  }
}

class UpdateProductParams extends Equatable {
  final String id;
  final String? name;
  final String? description;
  final double? price;
  final int? stock;
  final String? imageUrl;
  final String? category;

  const UpdateProductParams({
    required this.id,
    this.name,
    this.description,
    this.price,
    this.stock,
    this.imageUrl,
    this.category,
  });

  @override
  List<Object?> get props => [id, name, description, price, stock, imageUrl, category];
}
