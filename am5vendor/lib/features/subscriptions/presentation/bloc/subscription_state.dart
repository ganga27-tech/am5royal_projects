import 'package:equatable/equatable.dart';
import '../../domain/entities/subscription_plan_entity.dart';
import '../../domain/entities/my_subscription_entity.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();
  
  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final List<SubscriptionPlanEntity> plans;
  final MySubscriptionEntity? activeSubscription;

  const SubscriptionLoaded({
    required this.plans,
    this.activeSubscription,
  });

  @override
  List<Object?> get props => [plans, activeSubscription];
}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError({required this.message});

  @override
  List<Object?> get props => [message];
}

class PurchaseInitiateSuccess extends SubscriptionState {
  final Map<String, dynamic> orderData;

  const PurchaseInitiateSuccess({required this.orderData});

  @override
  List<Object?> get props => [orderData];
}

class PaymentVerificationSuccess extends SubscriptionState {
  final String message;

  const PaymentVerificationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
