class VendorCatalogMediaModel {
  final String mediaUrl;
  final String mediaType;

  const VendorCatalogMediaModel({
    required this.mediaUrl,
    required this.mediaType,
  });

  factory VendorCatalogMediaModel.fromJson(Map<String, dynamic> json) {
    return VendorCatalogMediaModel(
      mediaUrl: json['media_url']?.toString() ?? '',
      mediaType: json['media_type']?.toString() ?? 'image',
    );
  }

  Map<String, dynamic> toJson() => {
        'media_url': mediaUrl,
        'media_type': mediaType,
      };
}

class VendorCatalogServiceModel {
  final int id;
  final int? catalogServiceId;
  final String title;
  final String? description;
  final double price;
  final double? discountedPrice;
  final bool negotiable;
  final int mainCategoryId;
  final int subCategoryId;
  final String subCategoryName;
  final bool isActive;
  final String? imageUrl;
  final List<VendorCatalogMediaModel> media;

  const VendorCatalogServiceModel({
    required this.id,
    this.catalogServiceId,
    required this.title,
    this.description,
    required this.price,
    this.discountedPrice,
    required this.negotiable,
    required this.mainCategoryId,
    required this.subCategoryId,
    required this.subCategoryName,
    required this.isActive,
    this.imageUrl,
    this.media = const [],
  });

  factory VendorCatalogServiceModel.fromJson(Map<String, dynamic> json) {
    final rawMedia = json['media'];
    return VendorCatalogServiceModel(
      id: json['id'] as int,
      catalogServiceId: json['service_id'] as int?,
      title: json['title']?.toString() ?? 'Service',
      description: json['description']?.toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      discountedPrice: (json['discounted_price'] as num?)?.toDouble(),
      negotiable: json['negotiable'] == true,
      mainCategoryId: json['main_category_id'] as int,
      subCategoryId: json['sub_category_id'] as int,
      subCategoryName: json['sub_category_name']?.toString() ?? 'Unknown',
      isActive: json['is_active'] != false,
      imageUrl: json['image_url']?.toString(),
      media: rawMedia is List
          ? rawMedia
              .map((e) => VendorCatalogMediaModel.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ))
              .toList()
          : const [],
    );
  }
}

class VendorCatalogSubCategoryModel {
  final int subCategoryId;
  final String subCategoryName;
  final int mainCategoryId;
  final List<VendorCatalogServiceModel> services;

  const VendorCatalogSubCategoryModel({
    required this.subCategoryId,
    required this.subCategoryName,
    required this.mainCategoryId,
    this.services = const [],
  });

  factory VendorCatalogSubCategoryModel.fromJson(Map<String, dynamic> json) {
    final rawServices = json['services'];
    return VendorCatalogSubCategoryModel(
      subCategoryId: json['sub_category_id'] as int,
      subCategoryName: json['sub_category_name']?.toString() ?? 'Unknown',
      mainCategoryId: json['main_category_id'] as int,
      services: rawServices is List
          ? rawServices
              .map((e) => VendorCatalogServiceModel.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ))
              .toList()
          : const [],
    );
  }

  List<VendorCatalogServiceModel> get activeServices =>
      services.where((s) => s.isActive).toList();
}

class VendorCatalogMainCategoryModel {
  final int mainCategoryId;
  final String mainCategoryName;
  final String? iconUrl;
  final List<VendorCatalogSubCategoryModel> subCategories;

  const VendorCatalogMainCategoryModel({
    required this.mainCategoryId,
    required this.mainCategoryName,
    this.iconUrl,
    this.subCategories = const [],
  });

  factory VendorCatalogMainCategoryModel.fromJson(Map<String, dynamic> json) {
    final rawSubs = json['sub_categories'];
    return VendorCatalogMainCategoryModel(
      mainCategoryId: json['main_category_id'] as int,
      mainCategoryName: json['main_category_name']?.toString() ?? 'Category',
      iconUrl: json['icon_url']?.toString(),
      subCategories: rawSubs is List
          ? rawSubs
              .map((e) => VendorCatalogSubCategoryModel.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ))
              .toList()
          : const [],
    );
  }
}

class VendorCatalogModel {
  final List<VendorCatalogMainCategoryModel> categories;
  final int totalServices;
  final int totalActiveServices;

  const VendorCatalogModel({
    this.categories = const [],
    this.totalServices = 0,
    this.totalActiveServices = 0,
  });

  factory VendorCatalogModel.fromJson(Map<String, dynamic> json) {
    final rawCategories = json['categories'];
    return VendorCatalogModel(
      categories: rawCategories is List
          ? rawCategories
              .map((e) => VendorCatalogMainCategoryModel.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ))
              .toList()
          : const [],
      totalServices: json['total_services'] as int? ?? 0,
      totalActiveServices: json['total_active_services'] as int? ?? 0,
    );
  }

  bool get hasActiveServices => totalActiveServices > 0;
}
