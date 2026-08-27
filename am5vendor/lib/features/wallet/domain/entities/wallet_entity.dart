import 'package:equatable/equatable.dart';

class WalletTransactionEntity extends Equatable {
  final int id;
  final int walletId;
  final String transactionType;
  final double amount;
  final int rewardPoints;
  final String? description;
  final DateTime createdAt;

  const WalletTransactionEntity({
    required this.id,
    required this.walletId,
    required this.transactionType,
    required this.amount,
    required this.rewardPoints,
    this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        walletId,
        transactionType,
        amount,
        rewardPoints,
        description,
        createdAt,
      ];
}

class WalletDetailsEntity extends Equatable {
  final double balance;
  final int rewardPoints;
  final double totalEarned;
  final List<WalletTransactionEntity> transactions;

  const WalletDetailsEntity({
    required this.balance,
    required this.rewardPoints,
    required this.totalEarned,
    required this.transactions,
  });

  @override
  List<Object?> get props => [balance, rewardPoints, totalEarned, transactions];
}

class TopupResponseEntity extends Equatable {
  final String orderId;
  final double amount;
  final String currency;
  final String key;

  const TopupResponseEntity({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.key,
  });

  @override
  List<Object?> get props => [orderId, amount, currency, key];
}
