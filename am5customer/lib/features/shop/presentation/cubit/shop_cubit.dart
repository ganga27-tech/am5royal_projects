import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';

class ShopCubit extends Cubit<ShopState> {
  ShopCubit(this._api) : super(const ShopState());

  final MarketplaceApi _api;

  Future<void> load({String? category, String? q}) async {
    emit(state.copyWith(status: ShopStatus.loading, category: category, query: q));
    try {
      final products = await _api.listProducts(category: category, q: q);
      emit(state.copyWith(status: ShopStatus.ready, products: products));
    } catch (e) {
      emit(state.copyWith(status: ShopStatus.error, message: e.toString()));
    }
  }
}

enum ShopStatus { initial, loading, ready, error }

class ShopState extends Equatable {
  const ShopState({
    this.status = ShopStatus.initial,
    this.products = const [],
    this.category,
    this.query,
    this.message,
  });

  final ShopStatus status;
  final List<MarketplaceProduct> products;
  final String? category;
  final String? query;
  final String? message;

  ShopState copyWith({
    ShopStatus? status,
    List<MarketplaceProduct>? products,
    String? category,
    String? query,
    String? message,
  }) {
    return ShopState(
      status: status ?? this.status,
      products: products ?? this.products,
      category: category ?? this.category,
      query: query ?? this.query,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, products, category, query, message];
}
