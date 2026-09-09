import '../router/app_routes.dart';

/// Converts an API category/subcategory name into a URL slug.
/// Example: "Home services" -> "homeservices"
String categoryNameToRouteSlug(String name) {
  return name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '').trim();
}

/// Returns true when [slug] matches the slug derived from [name].
bool routeSlugMatches(String slug, String name) {
  return categoryNameToRouteSlug(name) == slug.toLowerCase();
}

/// Builds `/{categorySlug}` shortcut path from a main category name.
String categoryRoutePath(String categoryName) {
  return AppRoutes.categoryShortcut(categoryNameToRouteSlug(categoryName));
}

/// Builds `/{categorySlug}/{subcategorySlug}` shortcut path from names.
String subcategoryRoutePath(String categoryName, String subcategoryName) {
  return AppRoutes.subcategoryShortcut(
    categoryNameToRouteSlug(categoryName),
    categoryNameToRouteSlug(subcategoryName),
  );
}

/// Builds `/map/{categorySlug}` for vendor map onboarding flow.
String mapCategoryRoutePath(String categoryName) {
  return AppRoutes.mapCategory(categoryNameToRouteSlug(categoryName));
}

/// Builds `/map/{categorySlug}/{subcategorySlug}` for vendor map onboarding flow.
String mapSubcategoryRoutePath(String categoryName, String subcategoryName) {
  return AppRoutes.mapSubcategory(
    categoryNameToRouteSlug(categoryName),
    categoryNameToRouteSlug(subcategoryName),
  );
}
