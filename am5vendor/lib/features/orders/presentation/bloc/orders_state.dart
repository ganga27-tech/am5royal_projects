import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();
  
  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<OrderEntity> orders;
  const OrdersLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrdersError extends OrdersState {
  final String message;
  const OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderActionLoading extends OrdersState {}

class OrderActionSuccess extends OrdersState {
  final String message;
  const OrderActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderActionError extends OrdersState {
  final String message;
  const OrderActionError(this.message);

  @override
  List<Object?> get props => [message];
}
