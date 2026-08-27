import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/earnings_entity.dart';
import '../repositories/earnings_repository.dart';

class GetMyEarningsUseCase implements UseCase<EarningsEntity, NoParams> {
  final EarningsRepository repository;

  GetMyEarningsUseCase(this.repository);

  @override
  Future<Either<Failure, EarningsEntity>> call(NoParams params) async {
    return await repository.getMyEarnings();
  }
}
