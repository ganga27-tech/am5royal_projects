import 'package:equatable/equatable.dart';
import '../../../../features/wallet/domain/entities/wallet_entity.dart';

class EarningsEntity extends Equatable {
  final double totalEarnings;
  final double thisMonthEarnings;
  final List<WalletTransactionEntity> recentTransactions;

  const EarningsEntity({
    required this.totalEarnings,
    required this.thisMonthEarnings,
    required this.recentTransactions,
  });

  @override
  List<Object?> get props => [
        totalEarnings,
        thisMonthEarnings,
        recentTransactions,
      ];
}
