import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/orders_repository.dart';

class StartServiceUseCase {
  final OrdersRepository repository;

  StartServiceUseCase(this.repository);

  Future<Either<Failure, void>> call(String orderId, String startOtp) {
    return repository.startService(orderId, startOtp);
  }
}
