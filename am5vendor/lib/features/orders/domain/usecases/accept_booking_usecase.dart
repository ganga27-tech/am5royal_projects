import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/orders_repository.dart';

class AcceptBookingUseCase {
  final OrdersRepository repository;

  AcceptBookingUseCase(this.repository);

  Future<Either<Failure, void>> call(String orderId) {
    return repository.acceptBooking(orderId);
  }
}
