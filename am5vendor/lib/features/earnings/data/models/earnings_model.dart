import '../../domain/entities/earnings_entity.dart';
import '../../../../features/wallet/data/models/wallet_model.dart';

class EarningsModel extends EarningsEntity {
  const EarningsModel({
    required super.totalEarnings,
    required super.thisMonthEarnings,
    required super.recentTransactions,
  });

  factory EarningsModel.fromJson(Map<String, dynamic> json) {
    return EarningsModel(
      totalEarnings: json['total_earnings'] is String
          ? (double.tryParse(json['total_earnings']) ?? 0.0)
          : (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      thisMonthEarnings: json['this_month_earnings'] is String
          ? (double.tryParse(json['this_month_earnings']) ?? 0.0)
          : (json['this_month_earnings'] as num?)?.toDouble() ?? 0.0,
      recentTransactions: (json['recent_transactions'] as List?)
              ?.map((e) => WalletTransactionModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
