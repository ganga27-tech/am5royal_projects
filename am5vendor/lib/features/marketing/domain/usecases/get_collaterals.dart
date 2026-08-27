import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/marketing_collateral.dart';
import '../repositories/marketing_repository.dart';

class GetCollaterals implements UseCase<List<MarketingCollateral>, NoParams> {
  final MarketingRepository repository;

  GetCollaterals(this.repository);

  @override
  Future<Either<Failure, List<MarketingCollateral>>> call(NoParams params) async {
    return await repository.getCollaterals();
  }
}
