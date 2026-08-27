import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/wallet_entity.dart';
import '../repositories/wallet_repository.dart';

class GetWalletDetailsUseCase implements UseCase<WalletDetailsEntity, NoParams> {
  final WalletRepository repository;

  GetWalletDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, WalletDetailsEntity>> call(NoParams params) async {
    return await repository.getWalletDetails();
  }
}
