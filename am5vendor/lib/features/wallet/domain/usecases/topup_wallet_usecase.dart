import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/wallet_entity.dart';
import '../repositories/wallet_repository.dart';

class TopupWalletParams {
  final double amount;
  TopupWalletParams({required this.amount});
}

class TopUpWalletUseCase implements UseCase<TopupResponseEntity, TopupWalletParams> {
  final WalletRepository repository;

  TopUpWalletUseCase(this.repository);

  @override
  Future<Either<Failure, TopupResponseEntity>> call(TopupWalletParams params) async {
    return await repository.topupWallet(params.amount);
  }
}
