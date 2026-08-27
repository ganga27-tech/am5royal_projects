import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<Either<Failure, WalletDetailsEntity>> getWalletDetails();
  Future<Either<Failure, TopupResponseEntity>> topupWallet(double amount);
  Future<Either<Failure, double>> verifyTopup({
    required String paymentId,
    required String orderId,
    required String signature,
    required double amount,
  });
}
