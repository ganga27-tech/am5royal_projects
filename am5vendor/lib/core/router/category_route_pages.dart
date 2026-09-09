import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/products/data/models/product_model.dart';
import '../../features/products/presentation/pages/select_subcategory_page.dart';
import '../../features/supercategory/data/datasources/main_category_api_service.dart';
import '../../features/supercategory/data/models/main_category_model.dart';
import '../../features/supercategory/data/models/subcategory_model.dart';
import '../../features/supercategory/domain/entities/main_category.dart';
import '../../features/supercategory/domain/entities/subcategory_entity.dart';
import '../../features/supercategory/presentation/pages/select_service_page.dart';
import '../di/injection_container.dart' as di;
import '../router/app_routes.dart';
import '../utils/category_route_utils.dart';

MainCategoryModel? _findCategoryBySlug(
  List<MainCategoryModel> categories,
  String slug,
) {
  for (final category in categories) {
    if (routeSlugMatches(slug, category.name)) {
      return category;
    }
  }
  return null;
}

SubCategoryModel? _findSubcategoryBySlug(
  List<SubCategoryModel> subcategories,
  String slug,
) {
  for (final subcategory in subcategories) {
    if (routeSlugMatches(slug, subcategory.name)) {
      return subcategory;
    }
  }
  return null;
}

class CategoryRoutePage extends StatelessWidget {
  final String categorySlug;
  final Map<String, dynamic>? extra;

  const CategoryRoutePage({
    super.key,
    required this.categorySlug,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    final mainCategory = extra?['mainCategory'] as MainCategory?;
    if (mainCategory != null) {
      return SelectSubcategoryPage(
        categoryId: extra?['categoryId'] as int? ?? mainCategory.id,
        superCategoryTitle:
            extra?['superCategoryTitle'] as String? ?? mainCategory.name,
        mainCategory: mainCategory,
        isSingleService: extra?['isSingleService'] as bool? ?? true,
        initialSelectedSubCategories:
            (extra?['initialSelectedSubCategories'] as List<SubCategoryItem>?) ??
                const [],
      );
    }

    return FutureBuilder<Widget>(
      future: _resolveCategoryPage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return _RouteErrorView(
            message: 'Category not found',
            onBack: () => context.go(AppRoutes.map),
          );
        }
        return snapshot.data!;
      },
    );
  }

  Future<Widget> _resolveCategoryPage() async {
    final api = di.sl<MainCategoryApiService>();
    final categories = await api.getMainCategories();
    final match = _findCategoryBySlug(categories, categorySlug);
    if (match == null) {
      throw StateError('Category not found for slug: $categorySlug');
    }

    return SelectSubcategoryPage(
      categoryId: match.id,
      superCategoryTitle: match.name,
      mainCategory: match,
      isSingleService: extra?['isSingleService'] as bool? ?? true,
      initialSelectedSubCategories:
          (extra?['initialSelectedSubCategories'] as List<SubCategoryItem>?) ??
              const [],
    );
  }
}

class CategorySubcategoryRoutePage extends StatelessWidget {
  final String categorySlug;
  final String subcategorySlug;
  final Map<String, dynamic>? extra;

  const CategorySubcategoryRoutePage({
    super.key,
    required this.categorySlug,
    required this.subcategorySlug,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    final mainCategory = extra?['mainCategory'] as MainCategory?;
    final selectedSubCategories =
        extra?['selectedSubCategories'] as List<SubCategoryEntity>?;
    if (mainCategory != null &&
        selectedSubCategories != null &&
        selectedSubCategories.isNotEmpty) {
      return SelectServicePage(
        mainCategory: mainCategory,
        selectedSubCategories: selectedSubCategories,
        isSingleService: extra?['isSingleService'] as bool? ?? true,
      );
    }

    return FutureBuilder<Widget>(
      future: _resolveSubcategoryPage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return _RouteErrorView(
            message: 'Service category not found',
            onBack: () => context.go(mapCategoryRoutePath(
              extra?['superCategoryTitle'] as String? ?? categorySlug,
            )),
          );
        }
        return snapshot.data!;
      },
    );
  }

  Future<Widget> _resolveSubcategoryPage() async {
    final api = di.sl<MainCategoryApiService>();
    final categories = await api.getMainCategories();
    final mainCategory = _findCategoryBySlug(categories, categorySlug);
    if (mainCategory == null) {
      throw StateError('Category not found for slug: $categorySlug');
    }

    final subcategories = await api.getSubCategories(mainCategory.id);
    final subMatch = _findSubcategoryBySlug(subcategories, subcategorySlug);
    if (subMatch == null) {
      throw StateError(
        'Subcategory not found for slug: $subcategorySlug',
      );
    }

    return SelectServicePage(
      mainCategory: mainCategory,
      selectedSubCategories: [
        SubCategoryEntity(
          id: subMatch.id,
          name: subMatch.name,
          iconUrl: subMatch.iconUrl,
        ),
      ],
      isSingleService: extra?['isSingleService'] as bool? ?? true,
    );
  }
}

class _RouteErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onBack;

  const _RouteErrorView({
    required this.message,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 16),
            TextButton(onPressed: onBack, child: const Text('Go back')),
          ],
        ),
      ),
    );
  }
}
