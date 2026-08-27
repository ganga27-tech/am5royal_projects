import 'package:equatable/equatable.dart';

class SubscriptionPlanEntity extends Equatable {
  final int id;
  final String planType;
  final String name;
  final String? tier;
  final double price;
  final double? originalPrice;
  final String? offerText;
  final double? perLeadCharge;
  final double? commissionPercentage;
  final int freeLeads;
  final int visibilityBoost;
  final int serviceRadiusKm;
  final int leadAssurancePercent;
  final int rewardMultiplier;
  final int validityDays;
  final List<String> features;
  final List<String> disabledFeatures;
  final bool isActive;

  const SubscriptionPlanEntity({
    required this.id,
    required this.planType,
    required this.name,
    this.tier,
    required this.price,
    this.originalPrice,
    this.offerText,
    this.perLeadCharge,
    this.commissionPercentage,
    required this.freeLeads,
    required this.visibilityBoost,
    required this.serviceRadiusKm,
    required this.leadAssurancePercent,
    required this.rewardMultiplier,
    required this.validityDays,
    required this.features,
    this.disabledFeatures = const [],
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        id,
        planType,
        name,
        tier,
        price,
        originalPrice,
        offerText,
        perLeadCharge,
        commissionPercentage,
        freeLeads,
        visibilityBoost,
        serviceRadiusKm,
        leadAssurancePercent,
        rewardMultiplier,
        validityDays,
        features,
        disabledFeatures,
        isActive,
      ];
}
