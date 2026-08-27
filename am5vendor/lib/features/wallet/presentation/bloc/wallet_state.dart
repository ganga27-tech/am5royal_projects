import 'package:equatable/equatable.dart';
import '../../domain/entities/wallet_entity.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final WalletDetailsEntity walletDetails;
  const WalletLoaded({required this.walletDetails});

  @override
  List<Object> get props => [walletDetails];
}

class WalletTopupInitiated extends WalletState {
  final TopupResponseEntity topupResponse;
  const WalletTopupInitiated({required this.topupResponse});

  @override
  List<Object> get props => [topupResponse];
}

class WalletTopupSuccess extends WalletState {
  final double newBalance;
  const WalletTopupSuccess({required this.newBalance});

  @override
  List<Object> get props => [newBalance];
}

class WalletError extends WalletState {
  final String message;
  const WalletError({required this.message});

  @override
  List<Object> get props => [message];
}
