import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/subscription_plan_entity.dart';
import '../entities/my_subscription_entity.dart';

abstract class SubscriptionRepository {
  Future<Either<Failure, List<SubscriptionPlanEntity>>> getSubscriptionPlans();
  Future<Either<Failure, List<MySubscriptionEntity>>> getMySubscriptions();
  Future<Either<Failure, Map<String, dynamic>>> purchasePlan(int planId);
  Future<Either<Failure, Map<String, dynamic>>> verifyPayment({
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
    required int planId,
  });
  Future<Either<Failure, Map<String, dynamic>>> recoverPayment({
    required String razorpayOrderId,
    required int planId,
  });
}
