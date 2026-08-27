import '../../domain/entities/my_subscription_entity.dart';
import 'subscription_plan_model.dart';

class MySubscriptionModel extends MySubscriptionEntity {
  const MySubscriptionModel({
    required super.id,
    required super.vendorId,
    required super.subscriptionPlanId,
    required super.startDate,
    required super.endDate,
    required super.status,
    super.plan,
  });

  factory MySubscriptionModel.fromJson(Map<String, dynamic> json) {
    return MySubscriptionModel(
      id: json['id'],
      vendorId: json['vendor_id'],
      subscriptionPlanId: json['subscription_plan_id'],
      startDate: json['start_date'] != null 
          ? DateTime.parse(json['start_date']) 
          : DateTime.now(),
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date']) 
          : DateTime.now(),
      status: json['status'],
      plan: json['plan'] != null 
          ? SubscriptionPlanModel.fromJson(json['plan']) 
          : null,
    );
  }
}
