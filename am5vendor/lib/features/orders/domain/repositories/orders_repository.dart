import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/order_entity.dart';

abstract class OrdersRepository {
  Future<Either<Failure, void>> startService(String orderId, String startOtp);
  Future<Either<Failure, void>> completeService(String orderId, String endOtp);
  Future<Either<Failure, List<OrderEntity>>> getVendorOrders({String? statusFilter});
}
