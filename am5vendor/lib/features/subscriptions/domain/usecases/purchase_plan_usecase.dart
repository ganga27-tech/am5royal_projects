import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/subscription_repository.dart';

class PurchasePlanUseCase implements UseCase<Map<String, dynamic>, PurchasePlanParams> {
  final SubscriptionRepository repository;

  PurchasePlanUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(PurchasePlanParams params) async {
    return await repository.purchasePlan(params.planId);
  }
}

class PurchasePlanParams {
  final int planId;
  PurchasePlanParams({required this.planId});
}
