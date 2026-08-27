import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/get_product.dart';
import '../../domain/usecases/create_product.dart';
import '../../domain/usecases/update_product.dart';
import '../../domain/usecases/delete_product.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts getProducts;
  final GetProduct getProduct;
  final CreateProduct createProduct;
  final UpdateProduct updateProduct;
  final DeleteProduct deleteProduct;

  ProductBloc({
    required this.getProducts,
    required this.getProduct,
    required this.createProduct,
    required this.updateProduct,
    required this.deleteProduct,
  }) : super(const ProductState.initial()) {
    on<LoadProducts>(_onLoadProducts);
    on<CreateProductEvent>(_onCreateProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
  }

  Future<void> _onLoadProducts(LoadProducts event, Emitter<ProductState> emit) async {
    emit(const ProductState.loading());
    final result = await getProducts(event.search);
    result.fold(
      (failure) => emit(ProductState.error(failure.message)),
      (products) => emit(ProductState.loaded(products: products, search: event.search)),
    );
  }

  Future<void> _onCreateProduct(CreateProductEvent event, Emitter<ProductState> emit) async {
    emit(const ProductState.actionInProgress());
    final result = await createProduct(CreateProductParams(
      name: event.name,
      description: event.description,
      price: event.price,
      stock: event.stock,
      imageUrl: event.imageUrl,
      category: event.category,
    ));
    result.fold(
      (failure) => emit(ProductState.actionFailure(failure.message)),
      (product) => emit(ProductState.actionSuccess(
        message: 'Product "${product.name}" created successfully.',
        product: product,
      )),
    );
  }

  Future<void> _onUpdateProduct(UpdateProductEvent event, Emitter<ProductState> emit) async {
    emit(const ProductState.actionInProgress());
    final result = await updateProduct(UpdateProductParams(
      id: event.id,
      name: event.name,
      description: event.description,
      price: event.price,
      stock: event.stock,
      imageUrl: event.imageUrl,
      category: event.category,
    ));
    result.fold(
      (failure) => emit(ProductState.actionFailure(failure.message)),
      (product) => emit(ProductState.actionSuccess(
        message: 'Product "${product.name}" updated successfully.',
        product: product,
      )),
    );
  }

  Future<void> _onDeleteProduct(DeleteProductEvent event, Emitter<ProductState> emit) async {
    emit(const ProductState.actionInProgress());
    final result = await deleteProduct(event.id);
    result.fold(
      (failure) => emit(ProductState.actionFailure(failure.message)),
      (product) => emit(ProductState.actionSuccess(
        message: 'Product "${product.name}" deleted successfully.',
        product: product,
      )),
    );
  }
}
