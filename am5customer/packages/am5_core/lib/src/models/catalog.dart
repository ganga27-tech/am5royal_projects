import 'package:equatable/equatable.dart';

class CatalogCategory extends Equatable {
  const CatalogCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.sortOrder,
    required this.isActive,
    this.description,
    this.iconUrl,
    this.imageUrl,
    this.parentId,
  });

  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? iconUrl;
  final String? imageUrl;
  final String? parentId;
  final int sortOrder;
  final bool isActive;

  factory CatalogCategory.fromJson(Map<String, dynamic> json) {
    return CatalogCategory(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? json['id']?.toString() ?? '',
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
      imageUrl: json['image_url'] as String?,
      parentId: json['parent_id']?.toString(),
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [id, slug, name];
}

class CatalogServiceItem extends Equatable {
  const CatalogServiceItem({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.slug,
    required this.basePrice,
    required this.currency,
    required this.durationMinutes,
    required this.isActive,
    required this.isFeatured,
    required this.sortOrder,
    this.categoryName,
    this.shortDescription,
    this.description,
    this.imageUrl,
    this.bannerUrl,
  });

  final String id;
  final String categoryId;
  final String? categoryName;
  final String name;
  final String slug;
  final String? shortDescription;
  final String? description;
  final String? imageUrl;
  final String? bannerUrl;
  final double basePrice;
  final String currency;
  final int durationMinutes;
  final bool isActive;
  final bool isFeatured;
  final int sortOrder;

  factory CatalogServiceItem.fromJson(Map<String, dynamic> json) {
    final price = json['base_price'] ?? json['price'] ?? 0;
    return CatalogServiceItem(
      id: json['id']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      categoryName: json['category_name'] as String?,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? json['id']?.toString() ?? '',
      shortDescription: json['short_description'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      basePrice: price is num ? price.toDouble() : double.tryParse(price.toString()) ?? 0,
      currency: json['currency'] as String? ?? 'INR',
      durationMinutes: json['duration_minutes'] as int? ?? 60,
      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  String get priceLabel => '₹${basePrice.toStringAsFixed(0)}';

  @override
  List<Object?> get props => [id, slug, basePrice];
}

class CatalogBanner extends Equatable {
  const CatalogBanner({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.placement,
    required this.sortOrder,
    required this.isActive,
    required this.audience,
    this.subtitle,
    this.ctaLabel,
    this.ctaDeepLink,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String? ctaLabel;
  final String? ctaDeepLink;
  final String placement;
  final int sortOrder;
  final bool isActive;
  final String audience;

  factory CatalogBanner.fromJson(Map<String, dynamic> json) {
    return CatalogBanner(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      imageUrl: json['image_url'] as String,
      ctaLabel: json['cta_label'] as String?,
      ctaDeepLink: json['cta_deep_link'] as String?,
      placement: json['placement'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      audience: json['audience'] as String? ?? 'all',
    );
  }

  @override
  List<Object?> get props => [id, title, placement];
}

class VendorServiceOffering extends Equatable {
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

  final String id;
  final String? serviceId;
  final String title;
  final String? description;
  final double price;
  final double? discountedPrice;
  final bool negotiable;
  final String mainCategoryId;
  final String subCategoryId;
  final String? subCategoryName;
  final String? imageUrl;

  double get effectivePrice =>
      discountedPrice != null && discountedPrice! > 0 ? discountedPrice! : price;

  String get priceLabel => '₹${effectivePrice.toStringAsFixed(0)}';

  factory VendorServiceOffering.fromJson(Map<String, dynamic> json) {
    double n(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
    return VendorServiceOffering(
      id: json['id']?.toString() ?? '',
      serviceId: json['service_id']?.toString(),
      title: json['title'] as String? ?? 'Service',
      description: json['description'] as String?,
      price: n(json['price']),
      discountedPrice: json['discounted_price'] != null ? n(json['discounted_price']) : null,
      negotiable: json['negotiable'] as bool? ?? false,
      mainCategoryId: json['main_category_id']?.toString() ?? '',
      subCategoryId: json['sub_category_id']?.toString() ?? '',
      subCategoryName: json['sub_category_name'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, title, subCategoryId, price];
}
