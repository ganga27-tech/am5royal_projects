import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit(this._api) : super(const CartState());

  final MarketplaceApi _api;

  Future<void> load() async {
    emit(state.copyWith(status: CartStatus.loading));
    try {
      final cart = await _api.getCart();
      emit(state.copyWith(status: CartStatus.ready, cart: cart));
    } catch (e) {
      emit(state.copyWith(status: CartStatus.error, message: e.toString()));
    }
  }

  Future<void> add(String productId, {int quantity = 1}) async {
    emit(state.copyWith(status: CartStatus.updating));
    try {
      final cart = await _api.upsertCartItem(productId: productId, quantity: quantity);
      emit(state.copyWith(status: CartStatus.ready, cart: cart));
    } catch (e) {
      emit(state.copyWith(status: CartStatus.error, message: e.toString()));
    }
  }

  Future<void> updateQty(String productId, int quantity) async {
    if (quantity < 1) return remove(productId);
    await add(productId, quantity: quantity);
  }

  Future<void> remove(String productId) async {
    emit(state.copyWith(status: CartStatus.updating));
    try {
      final cart = await _api.removeCartItem(productId);
      emit(state.copyWith(status: CartStatus.ready, cart: cart));
    } catch (e) {
      emit(state.copyWith(status: CartStatus.error, message: e.toString()));
    }
  }

  Future<ProductOrder?> checkout({double useWalletAmount = 0}) async {
    emit(state.copyWith(status: CartStatus.checkingOut));
    try {
      final order = await _api.checkout(useWalletAmount: useWalletAmount);
      await load();
      return order;
    } catch (e) {
      emit(state.copyWith(status: CartStatus.error, message: e.toString()));
      return null;
    }
  }
}

enum CartStatus { initial, loading, ready, updating, checkingOut, error }

class CartState extends Equatable {
  const CartState({
    this.status = CartStatus.initial,
    this.cart,
    this.message,
  });

  final CartStatus status;
  final ShoppingCart? cart;
  final String? message;

  int get itemCount => cart?.itemCount ?? 0;

  CartState copyWith({
    CartStatus? status,
    ShoppingCart? cart,
    String? message,
  }) {
    return CartState(
      status: status ?? this.status,
      cart: cart ?? this.cart,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, cart, message];
}
