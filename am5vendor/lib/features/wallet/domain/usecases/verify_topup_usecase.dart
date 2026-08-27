import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/wallet_repository.dart';

class VerifyTopupParams {
  final String paymentId;
  final String orderId;
  final String signature;
  final double amount;

  VerifyTopupParams({
    required this.paymentId,
    required this.orderId,
    required this.signature,
    required this.amount,
  });
}

class VerifyTopupUseCase implements UseCase<double, VerifyTopupParams> {
  final WalletRepository repository;

  VerifyTopupUseCase(this.repository);

  @override
  Future<Either<Failure, double>> call(VerifyTopupParams params) async {
    return await repository.verifyTopup(
      paymentId: params.paymentId,
      orderId: params.orderId,
      signature: params.signature,
      amount: params.amount,
    );
  }
}
