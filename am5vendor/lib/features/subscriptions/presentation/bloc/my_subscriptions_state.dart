import 'package:equatable/equatable.dart';
import '../../domain/entities/my_subscription_entity.dart';

abstract class MySubscriptionsState extends Equatable {
  const MySubscriptionsState();

  @override
  List<Object> get props => [];
}

class MySubscriptionsInitial extends MySubscriptionsState {}

class MySubscriptionsLoading extends MySubscriptionsState {}

class MySubscriptionsLoaded extends MySubscriptionsState {
  final List<MySubscriptionEntity> subscriptions;

  const MySubscriptionsLoaded(this.subscriptions);

  @override
  List<Object> get props => [subscriptions];
}

class MySubscriptionsError extends MySubscriptionsState {
  final String message;

  const MySubscriptionsError(this.message);

  @override
  List<Object> get props => [message];
}
