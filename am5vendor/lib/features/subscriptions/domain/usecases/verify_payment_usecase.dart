import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/subscription_repository.dart';

class VerifyPaymentUseCase implements UseCase<Map<String, dynamic>, VerifyPaymentParams> {
  final SubscriptionRepository repository;

  VerifyPaymentUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(VerifyPaymentParams params) async {
    return await repository.verifyPayment(
      razorpayPaymentId: params.razorpayPaymentId,
      razorpayOrderId: params.razorpayOrderId,
      razorpaySignature: params.razorpaySignature,
      planId: params.planId,
    );
  }
}

class VerifyPaymentParams {
  final String razorpayPaymentId;
  final String razorpayOrderId;
  final String razorpaySignature;
  final int planId;

  VerifyPaymentParams({
    required this.razorpayPaymentId,
    required this.razorpayOrderId,
    required this.razorpaySignature,
    required this.planId,
  });
}
