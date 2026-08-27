class SubCategoryEntity {
  final int id;
  final String name;
  final String iconUrl;
  final bool isSelected;

  const SubCategoryEntity({
    required this.id,
    required this.name,
    required this.iconUrl,
    this.isSelected = false,
  });
}
