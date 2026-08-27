class PointDetail {
  final String name;
  final int points;

  PointDetail({required this.name, required this.points});

  factory PointDetail.fromJson(Map<String, dynamic> json) {
    return PointDetail(
      name: json['name'] ?? '',
      points: json['points'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'points': points,
    };
  }
}

class TelecallerDashboardStatsModel {
  final int weeklyOnboardings;
  final int monthlyConversions;
  final int referralPoints;
  final double estimatedReferralPayout;
  final double monthlyPayoutBonus;
  final double withdrawableBalance;
  final double totalWithdrawn;
  final PointDetail? telecallerPoints;
  final PointDetail? companyPoints;
  final List<PointDetail>? freelancerPoints;

  TelecallerDashboardStatsModel({
    required this.weeklyOnboardings,
    required this.monthlyConversions,
    required this.referralPoints,
    required this.estimatedReferralPayout,
    required this.monthlyPayoutBonus,
    required this.withdrawableBalance,
    required this.totalWithdrawn,
    this.telecallerPoints,
    this.companyPoints,
    this.freelancerPoints,
  });

  factory TelecallerDashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return TelecallerDashboardStatsModel(
      weeklyOnboardings: json['weekly_onboardings'] ?? 0,
      monthlyConversions: json['monthly_conversions'] ?? 0,
      referralPoints: json['referral_points'] ?? 0,
      estimatedReferralPayout: (json['estimated_referral_payout'] as num?)?.toDouble() ?? 0.0,
      monthlyPayoutBonus: (json['monthly_payout_bonus'] as num?)?.toDouble() ?? 0.0,
      withdrawableBalance: (json['withdrawable_balance'] as num?)?.toDouble() ?? 0.0,
      totalWithdrawn: (json['total_withdrawn'] as num?)?.toDouble() ?? 0.0,
      telecallerPoints: json['telecaller_points'] != null ? PointDetail.fromJson(json['telecaller_points']) : null,
      companyPoints: json['company_points'] != null ? PointDetail.fromJson(json['company_points']) : null,
      freelancerPoints: json['freelancer_points'] != null 
          ? (json['freelancer_points'] as List).map((i) => PointDetail.fromJson(i)).toList() 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weekly_onboardings': weeklyOnboardings,
      'monthly_conversions': monthlyConversions,
      'referral_points': referralPoints,
      'estimated_referral_payout': estimatedReferralPayout,
      'monthly_payout_bonus': monthlyPayoutBonus,
      'withdrawable_balance': withdrawableBalance,
      'total_withdrawn': totalWithdrawn,
      'telecaller_points': telecallerPoints?.toJson(),
      'company_points': companyPoints?.toJson(),
      'freelancer_points': freelancerPoints?.map((e) => e.toJson()).toList(),
    };
  }
}

