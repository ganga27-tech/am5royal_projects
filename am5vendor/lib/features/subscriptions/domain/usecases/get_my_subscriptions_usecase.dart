import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/my_subscription_entity.dart';
import '../repositories/subscription_repository.dart';

class GetMySubscriptionsUseCase implements UseCase<List<MySubscriptionEntity>, NoParams> {
  final SubscriptionRepository repository;

  GetMySubscriptionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<MySubscriptionEntity>>> call(NoParams params) async {
    return await repository.getMySubscriptions();
  }
}
