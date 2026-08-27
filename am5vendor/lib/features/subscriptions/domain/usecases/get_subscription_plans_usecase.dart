import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/subscription_plan_entity.dart';
import '../repositories/subscription_repository.dart';

class GetSubscriptionPlansUseCase implements UseCase<List<SubscriptionPlanEntity>, NoParams> {
  final SubscriptionRepository repository;

  GetSubscriptionPlansUseCase(this.repository);

  @override
  Future<Either<Failure, List<SubscriptionPlanEntity>>> call(NoParams params) async {
    return await repository.getSubscriptionPlans();
  }
}
