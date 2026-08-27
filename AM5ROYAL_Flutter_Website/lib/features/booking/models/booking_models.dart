class ServiceCategory {
  const ServiceCategory({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
  });

  final int id;
  final String name;
  final String? description;
  final String? iconUrl;

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
    );
  }
}

class ServiceSubcategory {
  const ServiceSubcategory({
    required this.id,
    required this.name,
    required this.categoryId,
    this.description,
    this.iconUrl,
  });

  final int id;
  final String name;
  final int categoryId;
  final String? description;
  final String? iconUrl;

  factory ServiceSubcategory.fromJson(Map<String, dynamic> json) {
    return ServiceSubcategory(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      categoryId: json['category_id'] as int? ?? 0,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
    );
  }
}

class ServicePackage {
  const ServicePackage({
    required this.id,
    required this.numericId,
    required this.title,
    required this.price,
    required this.subcategoryId,
    this.durationMinutes,
    this.heroImage,
    this.description,
  });

  final String id;
  final int numericId;
  final String title;
  final double price;
  final int subcategoryId;
  final int? durationMinutes;
  final String? heroImage;
  final String? description;

  factory ServicePackage.fromJson(Map<String, dynamic> json) {
    final dynamic rawId = json['id'];
    int numericId = 0;
    if (rawId is int) {
      numericId = rawId;
    }

    return ServicePackage(
      id: rawId?.toString() ?? '',
      numericId: numericId,
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      price: _toDouble(json['price']),
      subcategoryId: json['subcategory_id'] as int? ?? 0,
      durationMinutes: json['durationMinutes'] as int?,
      heroImage: json['heroImage'] as String?,
      description: json['detailInfo'] as String? ?? json['description'] as String?,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }
}

class VendorInfo {
  const VendorInfo({
    required this.id,
    required this.businessName,
    this.description,
    this.yearsOfExperience,
    this.avgRating,
    this.totalReviews,
    this.isVerified = false,
    this.photoUrl,
    this.operatingCity,
    this.approxVisitCharge,
    this.distanceKm,
    this.leadsConsumed,
  });

  final int id;
  final String businessName;
  final String? description;
  final int? yearsOfExperience;
  final double? avgRating;
  final int? totalReviews;
  final bool isVerified;
  final String? photoUrl;
  final String? operatingCity;
  final double? approxVisitCharge;
  final double? distanceKm;
  final int? leadsConsumed;

  factory VendorInfo.fromJson(Map<String, dynamic> json) {
    return VendorInfo(
      id: json['id'] as int,
      businessName: json['business_name'] as String? ?? '',
      description: json['business_description'] as String?,
      yearsOfExperience: json['years_of_experience'] as int?,
      avgRating: (json['avg_rating'] as num?)?.toDouble(),
      totalReviews: json['total_reviews'] as int?,
      isVerified: json['is_verified'] as bool? ?? false,
      photoUrl: json['photo_url'] as String?,
      operatingCity: json['operating_city'] as String?,
      approxVisitCharge: (json['approx_visit_charge'] as num?)?.toDouble(),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      leadsConsumed: json['leads_consumed'] as int?,
    );
  }
}

class VendorServiceOffering {
  const VendorServiceOffering({
    required this.id,
    required this.title,
    required this.price,
    required this.mainCategoryId,
    required this.subCategoryId,
    this.serviceId,
    this.description,
    this.discountedPrice,
    this.negotiable = false,
    this.subCategoryName,
    this.imageUrl,
  });

  final int id;
  final int? serviceId;
  final String title;
  final String? description;
  final double price;
  final double? discountedPrice;
  final bool negotiable;
  final int mainCategoryId;
  final int subCategoryId;
  final String? subCategoryName;
  final String? imageUrl;

  double get effectivePrice => discountedPrice ?? price;

  String get pricingLabel => negotiable ? 'Negotiable' : 'Fixed price';

  factory VendorServiceOffering.fromJson(Map<String, dynamic> json) {
    return VendorServiceOffering(
      id: json['id'] as int,
      serviceId: json['service_id'] as int?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      price: ServicePackage._toDouble(json['price']),
      discountedPrice: json['discounted_price'] != null
          ? ServicePackage._toDouble(json['discounted_price'])
          : null,
      negotiable: json['negotiable'] as bool? ?? false,
      mainCategoryId: json['main_category_id'] as int? ?? 0,
      subCategoryId: json['sub_category_id'] as int? ?? 0,
      subCategoryName: json['sub_category_name'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }
}

class CustomerAddress {
  const CustomerAddress({
    required this.id,
    required this.label,
    required this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.pincode,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  final int id;
  final String label;
  final String addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? pincode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  String get fullAddress {
    final parts = <String>[
      addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2!,
      if (city != null && city!.isNotEmpty) city!,
      if (state != null && state!.isNotEmpty) state!,
      if (pincode != null && pincode!.isNotEmpty) pincode!,
    ];
    return parts.join(', ');
  }

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    return CustomerAddress(
      id: json['id'] as int,
      label: json['label'] as String? ?? 'HOME',
      addressLine1: json['address_line1'] as String? ?? '',
      addressLine2: json['address_line2'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isDefault: json['is_default'] as bool? ?? false,
    );
  }
}

class BookingConfirmation {
  const BookingConfirmation({
    required this.orderId,
    required this.message,
  });

  final String orderId;
  final String message;

  factory BookingConfirmation.fromJson(Map<String, dynamic> json) {
    return BookingConfirmation(
      orderId: json['orderId'] as String? ?? '',
      message: json['message'] as String? ?? 'Booking confirmed',
    );
  }
}
