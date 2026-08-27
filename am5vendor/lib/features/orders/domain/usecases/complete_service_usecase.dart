import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/orders_repository.dart';

class CompleteServiceUseCase {
  final OrdersRepository repository;

  CompleteServiceUseCase(this.repository);

  Future<Either<Failure, void>> call(String orderId, String endOtp) {
    return repository.completeService(orderId, endOtp);
  }
}
