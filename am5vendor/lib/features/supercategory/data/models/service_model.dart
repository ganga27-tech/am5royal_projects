import '../../domain/entities/service_entity.dart';

class ServiceModel extends ServiceEntity {
  const ServiceModel({
    required super.id,
    required super.mainCategoryId,
    super.subCategoryId,
    required super.name,
    super.imageUrl,
    required super.isActive,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as int,
      mainCategoryId: json['main_category_id'] as int,
      subCategoryId: json['sub_category_id'] as int?,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'main_category_id': mainCategoryId,
      'sub_category_id': subCategoryId,
      'name': name,
      'image_url': imageUrl,
      'is_active': isActive,
    };
  }
}
