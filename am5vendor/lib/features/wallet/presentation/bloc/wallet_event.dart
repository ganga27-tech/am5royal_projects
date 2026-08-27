import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object> get props => [];
}

class FetchWalletDetailsEvent extends WalletEvent {}

class TopupWalletEvent extends WalletEvent {
  final double amount;
  const TopupWalletEvent({required this.amount});

  @override
  List<Object> get props => [amount];
}

class VerifyTopupEvent extends WalletEvent {
  final String paymentId;
  final String orderId;
  final String signature;
  final double amount;

  const VerifyTopupEvent({
    required this.paymentId,
    required this.orderId,
    required this.signature,
    required this.amount,
  });

  @override
  List<Object> get props => [paymentId, orderId, signature, amount];
}
