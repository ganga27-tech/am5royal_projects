import 'package:equatable/equatable.dart';

class ProfessionalSkill extends Equatable {
  const ProfessionalSkill({required this.serviceId, this.serviceName});

  final String serviceId;
  final String? serviceName;

  factory ProfessionalSkill.fromJson(Map<String, dynamic> json) {
    return ProfessionalSkill(
      serviceId: json['service_id'] as String,
      serviceName: json['service_name'] as String?,
    );
  }

  @override
  List<Object?> get props => [serviceId, serviceName];
}

class Professional extends Equatable {
  const Professional({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.country,
    required this.yearsExperience,
    required this.isVerified,
    required this.isActive,
    required this.isAvailable,
    required this.ratingAvg,
    required this.ratingCount,
    required this.jobsCompleted,
    this.headline,
    this.bio,
    this.avatarUrl,
    this.bannerUrl,
    this.city,
    this.state,
    this.servicePrice,
    this.distanceKm,
    this.kycStatus = 'unsubmitted',
    this.kycRejectionReason,
    this.skills = const [],
  });

  final String id;
  final String userId;
  final String displayName;
  final String? headline;
  final String? bio;
  final String? avatarUrl;
  final String? bannerUrl;
  final String? city;
  final String? state;
  final String country;
  final int yearsExperience;
  final bool isVerified;
  final bool isActive;
  final bool isAvailable;
  final String kycStatus;
  final String? kycRejectionReason;
  final double ratingAvg;
  final int ratingCount;
  final int jobsCompleted;
  final double? servicePrice;
  final double? distanceKm;
  final List<ProfessionalSkill> skills;

  String get ratingLabel => ratingCount == 0 ? 'New' : '${ratingAvg.toStringAsFixed(1)} ($ratingCount)';
  String get priceLabel => servicePrice != null && servicePrice! > 0 ? '₹${servicePrice!.toStringAsFixed(0)}' : '';
  String get distanceLabel => distanceKm != null && distanceKm! > 0 ? '${distanceKm!.toStringAsFixed(1)} km' : '';

  factory Professional.fromJson(Map<String, dynamic> json) {
    final avg = json['rating_avg'] ?? json['avg_rating'];
    final price = json['service_price'] ?? json['starting_price'] ?? json['price'];
    final dist = json['distance_km'];
    return Professional(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? json['id']?.toString() ?? '',
      displayName: json['display_name'] as String? ?? json['business_name'] as String? ?? 'Professional',
      headline: json['headline'] as String?,
      bio: json['bio'] as String? ?? json['business_description'] as String?,
      avatarUrl: json['avatar_url'] as String? ?? json['photo_url'] as String?,
      bannerUrl: json['banner_url'] as String? ?? json['background_banner'] as String?,
      city: json['city'] as String? ?? json['operating_city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String? ?? 'IN',
      yearsExperience: json['years_experience'] as int? ?? json['years_of_experience'] as int? ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      isAvailable: json['is_available'] as bool? ?? true,
      kycStatus: json['kyc_status'] as String? ?? 'unsubmitted',
      kycRejectionReason: json['kyc_rejection_reason'] as String?,
      ratingAvg: avg is num ? avg.toDouble() : double.tryParse('$avg') ?? 0,
      ratingCount: json['rating_count'] as int? ?? json['total_reviews'] as int? ?? 0,
      jobsCompleted: json['jobs_completed'] as int? ?? 0,
      servicePrice: price is num ? price.toDouble() : double.tryParse('$price'),
      distanceKm: dist is num ? dist.toDouble() : double.tryParse('$dist'),
      skills: (json['skills'] as List<dynamic>? ?? [])
          .map((e) => ProfessionalSkill.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory Professional.fromAm5Vendor(Map<String, dynamic> json) {
    return Professional.fromJson(json);
  }

  @override
  List<Object?> get props => [id, displayName, ratingAvg, ratingCount, servicePrice, distanceKm];
}

class ProfessionalReview extends Equatable {
  const ProfessionalReview({
    required this.id,
    required this.professionalId,
    required this.reviewerUserId,
    required this.rating,
    required this.isVisible,
    required this.createdAt,
    this.reviewerName,
    this.serviceId,
    this.serviceName,
    this.title,
    this.body,
  });

  final String id;
  final String professionalId;
  final String reviewerUserId;
  final String? reviewerName;
  final String? serviceId;
  final String? serviceName;
  final int rating;
  final String? title;
  final String? body;
  final bool isVisible;
  final String createdAt;

  factory ProfessionalReview.fromJson(Map<String, dynamic> json) {
    return ProfessionalReview(
      id: json['id'] as String,
      professionalId: json['professional_id'] as String,
      reviewerUserId: json['reviewer_user_id'] as String,
      reviewerName: json['reviewer_name'] as String?,
      serviceId: json['service_id'] as String?,
      serviceName: json['service_name'] as String?,
      rating: json['rating'] as int? ?? 0,
      title: json['title'] as String?,
      body: json['body'] as String?,
      isVisible: json['is_visible'] as bool? ?? true,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, rating, professionalId];
}
