import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/product.dart';

part 'product_state.freezed.dart';

@freezed
class ProductState with _$ProductState {
  const factory ProductState.initial() = Initial;
  
  const factory ProductState.loading() = Loading;
  
  const factory ProductState.loaded({
    required List<Product> products,
    String? search,
  }) = Loaded;
  
  const factory ProductState.error(String message) = ProductError;
  
  // Specific states for write mutations (Create, Update, Delete) to allow easy listeners
  const factory ProductState.actionInProgress() = ActionInProgress;
  
  const factory ProductState.actionSuccess({
    required String message,
    Product? product,
  }) = ActionSuccess;
  
  const factory ProductState.actionFailure(String message) = ActionFailure;
}
