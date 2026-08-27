import '../../domain/entities/main_category.dart';

class MainCategoryModel extends MainCategory {
  const MainCategoryModel({
    required super.id,
    required super.name,
    required super.iconUrl,
    required super.hasSubcategories,
  });

  factory MainCategoryModel.fromJson(Map<String, dynamic> json) {
    return MainCategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      iconUrl: json['icon_url'] as String,
      hasSubcategories: json['has_subcategories'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_url': iconUrl,
      'has_subcategories': hasSubcategories,
    };
  }
}
