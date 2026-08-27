import '../../domain/entities/wallet_entity.dart';

class WalletTransactionModel extends WalletTransactionEntity {
  const WalletTransactionModel({
    required super.id,
    required super.walletId,
    required super.transactionType,
    required super.amount,
    required super.rewardPoints,
    super.description,
    required super.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id'],
      walletId: json['wallet_id'],
      transactionType: json['transaction_type'],
      amount: json['amount'] is String
          ? (double.tryParse(json['amount']) ?? 0.0)
          : (json['amount'] as num?)?.toDouble() ?? 0.0,
      rewardPoints: json['reward_points'] ?? 0,
      description: json['description'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}

class WalletModel extends WalletDetailsEntity {
  const WalletModel({
    required super.balance,
    required super.rewardPoints,
    required super.totalEarned,
    required super.transactions,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      balance: json['balance'] is String
          ? (double.tryParse(json['balance']) ?? 0.0)
          : (json['balance'] as num?)?.toDouble() ?? 0.0,
      rewardPoints: json['reward_points'] ?? 0,
      totalEarned: json['total_earned'] is String
          ? (double.tryParse(json['total_earned']) ?? 0.0)
          : (json['total_earned'] as num?)?.toDouble() ?? 0.0,
      transactions: (json['transactions'] as List?)
              ?.map((e) => WalletTransactionModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
