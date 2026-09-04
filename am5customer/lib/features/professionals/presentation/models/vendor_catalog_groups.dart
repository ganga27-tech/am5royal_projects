import 'package:am5_core/am5_core.dart';

class VendorSubcategoryGroup {
  const VendorSubcategoryGroup({
    required this.id,
    required this.name,
    required this.services,
  });

  final String id;
  final String name;
  final List<VendorServiceOffering> services;
}

class VendorMainCategoryGroup {
  const VendorMainCategoryGroup({
    required this.id,
    required this.name,
    required this.subcategories,
    this.iconUrl,
  });

  final String id;
  final String name;
  final String? iconUrl;
  final List<VendorSubcategoryGroup> subcategories;

  List<VendorServiceOffering> get allServices =>
      subcategories.expand((sub) => sub.services).toList();

  int get serviceCount => allServices.length;

  bool get hasMultipleSubcategories => subcategories.length > 1;
}

class VendorCatalogIndex {
  const VendorCatalogIndex({
    required this.mainCategories,
    required this.catalogCategories,
  });

  final List<VendorMainCategoryGroup> mainCategories;
  final List<CatalogCategory> catalogCategories;

  factory VendorCatalogIndex.fromServices({
    required List<VendorServiceOffering> services,
    required List<CatalogCategory> catalogCategories,
  }) {
    final mainMap = <String, Map<String, List<VendorServiceOffering>>>{};

    for (final service in services) {
      final mainId = service.mainCategoryId.isNotEmpty ? service.mainCategoryId : 'other';
      final subId = service.subCategoryId.isNotEmpty ? service.subCategoryId : 'other';
      mainMap.putIfAbsent(mainId, () => {});
      mainMap[mainId]!.putIfAbsent(subId, () => []).add(service);
    }

    String mainName(String mainId) {
      if (mainId == 'other') return 'Other services';
      return catalogCategories
              .where((c) => c.id == mainId)
              .map((c) => c.name)
              .firstOrNull ??
          services
              .where((s) => s.mainCategoryId == mainId)
              .map((s) => s.subCategoryName)
              .whereType<String>()
              .firstOrNull ??
          'Services';
    }

    String? mainIcon(String mainId) {
      return catalogCategories.where((c) => c.id == mainId).map((c) => c.iconUrl).firstOrNull;
    }

    String subName(String mainId, String subId) {
      if (subId == 'other') return 'General services';
      return services
              .where((s) => s.subCategoryId == subId)
              .map((s) => s.subCategoryName)
              .whereType<String>()
              .firstOrNull ??
          'Services';
    }

    final mains = mainMap.entries.map((mainEntry) {
      final subs = mainEntry.value.entries
          .map(
            (subEntry) => VendorSubcategoryGroup(
              id: subEntry.key,
              name: subName(mainEntry.key, subEntry.key),
              services: subEntry.value,
            ),
          )
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

      return VendorMainCategoryGroup(
        id: mainEntry.key,
        name: mainName(mainEntry.key),
        iconUrl: mainIcon(mainEntry.key),
        subcategories: subs,
      );
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return VendorCatalogIndex(
      mainCategories: mains,
      catalogCategories: catalogCategories,
    );
  }

  VendorMainCategoryGroup? categoryById(String? id) {
    if (id == null) return null;
    return mainCategories.where((c) => c.id == id).firstOrNull;
  }
}
