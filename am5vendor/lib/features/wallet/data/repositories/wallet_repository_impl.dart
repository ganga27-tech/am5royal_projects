import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_data_source.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;

  WalletRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, WalletDetailsEntity>> getWalletDetails() async {
    try {
      final remoteWallet = await remoteDataSource.getWalletDetails();
      
      final List<WalletTransactionEntity> transactions = remoteWallet.transactions
          .map((e) => WalletTransactionEntity(
                id: e.id,
                walletId: e.walletId,
                transactionType: e.transactionType,
                amount: e.amount,
                rewardPoints: e.rewardPoints,
                description: e.description,
                createdAt: e.createdAt,
              ))
          .toList();

      return Right(WalletDetailsEntity(
        balance: remoteWallet.balance,
        rewardPoints: remoteWallet.rewardPoints,
        totalEarned: remoteWallet.totalEarned,
        transactions: transactions,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TopupResponseEntity>> topupWallet(double amount) async {
    try {
      final response = await remoteDataSource.topUpWallet(amount);
      return Right(TopupResponseEntity(
        orderId: response['order_id'],
        amount: double.parse(response['amount'].toString()),
        currency: response['currency'] ?? 'INR',
        key: response['key'],
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> verifyTopup({
    required String paymentId,
    required String orderId,
    required String signature,
    required double amount,
  }) async {
    try {
      final newBalance = await remoteDataSource.verifyTopup(
        paymentId,
        orderId,
        signature,
        amount,
      );
      return Right(newBalance);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
