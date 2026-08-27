import 'package:equatable/equatable.dart';
import 'subscription_plan_entity.dart';

class MySubscriptionEntity extends Equatable {
  final int id;
  final int vendorId;
  final int subscriptionPlanId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final SubscriptionPlanEntity? plan;

  const MySubscriptionEntity({
    required this.id,
    required this.vendorId,
    required this.subscriptionPlanId,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.plan,
  });

  @override
  List<Object?> get props => [
        id,
        vendorId,
        subscriptionPlanId,
        startDate,
        endDate,
        status,
        plan,
      ];
}
