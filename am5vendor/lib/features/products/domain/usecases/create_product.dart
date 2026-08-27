import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class CreateProduct implements UseCase<Product, CreateProductParams> {
  final ProductRepository repository;

  CreateProduct(this.repository);

  @override
  Future<Either<Failure, Product>> call(CreateProductParams params) {
    return repository.createProduct(
      name: params.name,
      description: params.description,
      price: params.price,
      stock: params.stock,
      imageUrl: params.imageUrl,
      category: params.category,
    );
  }
}

class CreateProductParams extends Equatable {
  final String name;
  final String description;
  final double price;
  final int stock;
  final String imageUrl;
  final String category;

  const CreateProductParams({
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.category,
  });

  @override
  List<Object?> get props => [name, description, price, stock, imageUrl, category];
}
