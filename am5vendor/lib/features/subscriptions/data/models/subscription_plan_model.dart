import '../../domain/entities/subscription_plan_entity.dart';

class SubscriptionPlanModel extends SubscriptionPlanEntity {
  const SubscriptionPlanModel({
    required super.id,
    required super.planType,
    required super.name,
    super.tier,
    required super.price,
    super.originalPrice,
    super.offerText,
    super.perLeadCharge,
    super.commissionPercentage,
    required super.freeLeads,
    required super.visibilityBoost,
    required super.serviceRadiusKm,
    required super.leadAssurancePercent,
    required super.rewardMultiplier,
    required super.validityDays,
    required super.features,
    super.disabledFeatures = const [],
    required super.isActive,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'],
      planType: json['plan_type'],
      name: json['name'],
      tier: json['tier'],
      price: (json['price'] as num).toDouble(),
      originalPrice: json['original_price'] != null ? (json['original_price'] as num).toDouble() : null,
      offerText: json['offer_text'],
      perLeadCharge: json['per_lead_charge'] != null ? (json['per_lead_charge'] as num).toDouble() : null,
      commissionPercentage: json['commission_percentage'] != null ? (json['commission_percentage'] as num).toDouble() : null,
      freeLeads: json['free_leads'],
      visibilityBoost: json['visibility_boost'],
      serviceRadiusKm: json['service_radius_km'],
      leadAssurancePercent: json['lead_assurance_percent'],
      rewardMultiplier: json['reward_multiplier'],
      validityDays: json['validity_days'],
      features: List<String>.from(json['features'] ?? []),
      disabledFeatures: json['disabled_features'] != null ? List<String>.from(json['disabled_features']) : const [],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_type': planType,
      'name': name,
      'tier': tier,
      'price': price,
      'original_price': originalPrice,
      'offer_text': offerText,
      'per_lead_charge': perLeadCharge,
      'commission_percentage': commissionPercentage,
      'free_leads': freeLeads,
      'visibility_boost': visibilityBoost,
      'service_radius_km': serviceRadiusKm,
      'lead_assurance_percent': leadAssurancePercent,
      'reward_multiplier': rewardMultiplier,
      'validity_days': validityDays,
      'features': features,
      'disabled_features': disabledFeatures,
      'is_active': isActive,
    };
  }
}
