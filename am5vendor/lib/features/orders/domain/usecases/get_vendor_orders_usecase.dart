import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

class GetVendorOrdersUseCase {
  final OrdersRepository repository;

  GetVendorOrdersUseCase(this.repository);

  Future<Either<Failure, List<OrderEntity>>> call({String? statusFilter}) {
    return repository.getVendorOrders(statusFilter: statusFilter);
  }
}
