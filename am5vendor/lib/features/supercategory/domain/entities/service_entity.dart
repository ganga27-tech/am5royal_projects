class ServiceEntity {
  final int id;
  final int mainCategoryId;
  final int? subCategoryId;
  final String name;
  final String? imageUrl;
  final bool isActive;

  const ServiceEntity({
    required this.id,
    required this.mainCategoryId,
    this.subCategoryId,
    required this.name,
    this.imageUrl,
    required this.isActive,
  });
}
