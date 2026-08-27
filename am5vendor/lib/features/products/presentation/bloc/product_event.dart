import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_event.freezed.dart';

@freezed
class ProductEvent with _$ProductEvent {
  const factory ProductEvent.loadProducts({String? search}) = LoadProducts;
  
  const factory ProductEvent.loadProductDetail(String id) = LoadProductDetail;
  
  const factory ProductEvent.createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required String imageUrl,
    required String category,
  }) = CreateProductEvent;
  
  const factory ProductEvent.updateProduct({
    required String id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? imageUrl,
    String? category,
  }) = UpdateProductEvent;
  
  const factory ProductEvent.deleteProduct(String id) = DeleteProductEvent;
}
