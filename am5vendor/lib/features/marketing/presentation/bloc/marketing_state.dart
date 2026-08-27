import 'package:equatable/equatable.dart';
import '../../domain/entities/marketing_lead.dart';
import '../../domain/entities/marketing_collateral.dart';

abstract class MarketingState extends Equatable {
  const MarketingState();

  @override
  List<Object?> get props => [];
}

class MarketingInitial extends MarketingState {}

class MarketingLoading extends MarketingState {}

class MarketingLoaded extends MarketingState {
  final List<MarketingLead> leads;
  final List<MarketingCollateral> collaterals;

  const MarketingLoaded({required this.leads, required this.collaterals});

  @override
  List<Object?> get props => [leads, collaterals];
}

class MarketingLeadCreated extends MarketingState {
  final MarketingLead lead;

  const MarketingLeadCreated({required this.lead});

  @override
  List<Object?> get props => [lead];
}

class MarketingError extends MarketingState {
  final String message;

  const MarketingError({required this.message});

  @override
  List<Object?> get props => [message];
}
