import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/orders_repository.dart';

class RejectBookingUseCase {
  final OrdersRepository repository;

  RejectBookingUseCase(this.repository);

  Future<Either<Failure, void>> call(String orderId, {String? reason}) {
    return repository.rejectBooking(orderId, reason: reason);
  }
}
