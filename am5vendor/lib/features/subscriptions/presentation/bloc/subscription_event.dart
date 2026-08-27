import 'package:equatable/equatable.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object> get props => [];
}

class FetchSubscriptionsEvent extends SubscriptionEvent {}

class PurchasePlanEvent extends SubscriptionEvent {
  final int planId;
  const PurchasePlanEvent({required this.planId});

  @override
  List<Object> get props => [planId];
}

class VerifyPaymentEvent extends SubscriptionEvent {
  final String paymentId;
  final String orderId;
  final String signature;
  final int planId;

  const VerifyPaymentEvent({
    required this.paymentId,
    required this.orderId,
    required this.signature,
    required this.planId,
  });

  @override
  List<Object> get props => [paymentId, orderId, signature, planId];
}

class CancelLoadingEvent extends SubscriptionEvent {}

class RecoverPaymentEvent extends SubscriptionEvent {
  final String orderId;
  final int planId;

  const RecoverPaymentEvent({
    required this.orderId,
    required this.planId,
  });

  @override
  List<Object> get props => [orderId, planId];
}

class CheckActiveSubscriptionEvent extends SubscriptionEvent {}
