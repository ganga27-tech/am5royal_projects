import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/subscription_repository.dart';

class RecoverPaymentUseCase
    implements UseCase<Map<String, dynamic>, RecoverPaymentParams> {
  final SubscriptionRepository repository;

  RecoverPaymentUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    RecoverPaymentParams params,
  ) async {
    return repository.recoverPayment(
      razorpayOrderId: params.razorpayOrderId,
      planId: params.planId,
    );
  }
}

class RecoverPaymentParams {
  final String razorpayOrderId;
  final int planId;

  RecoverPaymentParams({
    required this.razorpayOrderId,
    required this.planId,
  });
}
