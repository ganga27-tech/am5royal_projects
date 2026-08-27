import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_data_source.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource remoteDataSource;

  OrdersRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, void>> startService(String orderId, String startOtp) async {
    try {
      await remoteDataSource.startService(orderId, startOtp);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> completeService(String orderId, String endOtp) async {
    try {
      await remoteDataSource.completeService(orderId, endOtp);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> acceptBooking(String orderId) async {
    try {
      await remoteDataSource.acceptBooking(orderId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rejectBooking(String orderId, {String? reason}) async {
    try {
      await remoteDataSource.rejectBooking(orderId, reason: reason);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getVendorOrders({String? statusFilter}) async {
    try {
      final orders = await remoteDataSource.getVendorOrders(statusFilter: statusFilter);
      return Right(orders.cast<OrderEntity>());
    } on ServerException catch (e) {
      final message = e.message.toLowerCase() == 'not found' ? 'no orders yet' : e.message;
      return Left(ServerFailure(message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
