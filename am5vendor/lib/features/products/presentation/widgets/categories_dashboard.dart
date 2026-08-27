import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/product_model.dart';
import '../../../supercategory/presentation/providers/main_category_providers.dart';
import '../../../supercategory/presentation/bloc/main_category_bloc.dart';
import '../../../supercategory/presentation/bloc/main_category_state.dart';
import '../../../supercategory/presentation/bloc/main_category_event.dart';
import '../../../supercategory/domain/entities/main_category.dart';
import 'category_card.dart';
import 'scroll_indicator.dart';

class CategoriesDashboard extends ConsumerWidget {
  final PageController? pageController;
  final Function(CategoryItem category) onCategoryTap;
  final bool isBottomSheet;
  final bool isBottomContainer;
  final ScrollController? scrollController;
  final String searchQuery;
  final int? crossAxisCount;
  final double? childAspectRatio;

  const CategoriesDashboard({
    super.key,
    this.pageController,
    required this.onCategoryTap,
    this.isBottomSheet = false,
    this.isBottomContainer = false,
    this.scrollController,
    this.searchQuery = '',
    this.crossAxisCount,
    this.childAspectRatio,
  });

  CategoryItem _toCategoryItem(MainCategory mainCategory, int index) {
    // Find match by name
    final match = ProductModel.categories.firstWhere(
      (c) => c.title.toLowerCase() == mainCategory.name.toLowerCase(),
      orElse: () => CategoryItem(
        number: (index + 1).toString().padLeft(2, '0'),
        title: mainCategory.name,
        icon: Icons.category_rounded,
        color: const Color(0xFF0072FF),
        id: mainCategory.id.toString(),
        name: mainCategory.name,
        description: 'Explore ${mainCategory.name} services',
        price: 0,
        stock: 0,
        imageUrl: mainCategory.iconUrl,
        category: mainCategory.name,
        hasSubcategories: mainCategory.hasSubcategories,
      ),
    );

    final numberStr = (index + 1).toString().padLeft(2, '0');

    return CategoryItem(
      number: match.title.isNotEmpty ? match.number : numberStr,
      title: mainCategory.name,
      icon: match.title.isNotEmpty ? match.icon : Icons.category_rounded,
      color: match.title.isNotEmpty ? match.color : const Color(0xFF0072FF),
      id: mainCategory.id.toString(),
      name: match.title.isNotEmpty ? match.name : mainCategory.name,
      description: match.title.isNotEmpty
          ? match.description
          : 'Explore ${mainCategory.name} services',
      price: match.price,
      stock: match.stock,
      imageUrl: match.title.isNotEmpty ? match.imageUrl : mainCategory.iconUrl,
      category: match.title.isNotEmpty ? match.category : mainCategory.name,
      hasSubcategories: mainCategory.hasSubcategories,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.sizeOf(context).width > 900;
    final bloc = ref.watch(mainCategoryBlocProvider);

    return BlocBuilder<MainCategoryBloc, GetMainCategoriesState>(
      bloc: bloc,
      builder: (context, blocState) {
        return Container(
          color: isBottomSheet || isBottomContainer
              ? Colors.transparent
              : (isDesktop
                  ? (isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB))
                  : (isDark ? AppColors.darkBackground : AppColors.background)),
          child: Stack(
            children: [
              if (!isBottomSheet && !isBottomContainer && !isDesktop)
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/water.png',
                    fit: BoxFit.cover,
                    opacity: AlwaysStoppedAnimation(isDark ? 0.05 : 0.4),
                  ),
                ),
              SafeArea(
                top: !isBottomSheet && !isBottomContainer,
                bottom: !isBottomSheet && !isBottomContainer,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isBottomContainer ? 16.0 : 24.0,
                    vertical:
                        isBottomContainer ? 8.0 : (isBottomSheet ? 8.0 : 24.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isBottomSheet &&
                          !isBottomContainer &&
                          pageController != null) ...[
                        Center(
                          child: ScrollIndicator(
                            icon: Icons.keyboard_double_arrow_up_rounded,
                            label: 'Scroll up for Map',
                            isUp: true,
                            onTap: () {
                              pageController!.animateToPage(
                                0,
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeInOutCubic,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (!isBottomContainer) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'MAIN CATEGORIES',
                              style: GoogleFonts.outfit(
                                fontSize: isDesktop ? 13.5 : 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : const Color(0xFF71717A),
                              ),
                            ),
                            if (blocState is GetMainCategoriesError)
                              IconButton(
                                icon:
                                    const Icon(Icons.refresh_rounded, size: 18),
                                onPressed: () {
                                  ref
                                      .read(mainCategoryBlocProvider)
                                      .add(const FetchMainCategories());
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Categories Grid View
                      if (isBottomContainer)
                        _buildBody(context, ref, blocState)
                      else
                        Expanded(
                          child: _buildBody(context, ref, blocState),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(
      BuildContext context, WidgetRef ref, GetMainCategoriesState state) {
    if (state is GetMainCategoriesLoading ||
        state is GetMainCategoriesInitial) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    } else if (state is GetMainCategoriesError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(mainCategoryBlocProvider)
                    .add(const FetchMainCategories());
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (state is GetMainCategoriesSuccess) {
      final categoriesList = state.categories.where((cat) {
        return cat.name.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();

      if (categoriesList.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.category_outlined, color: Colors.grey, size: 48),
              SizedBox(height: 16),
              Text(
                'No categories available.',
                style:
                    TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          final double gridWidth = constraints.maxWidth;
          final bool isDesktop = MediaQuery.sizeOf(context).width > 900;

          int finalCols;
          double finalRatio;

          if (isDesktop) {
            // Dynamically choose columns based on grid width
            int cols = 4;
            if (gridWidth < 380) {
              cols = 2;
            } else if (gridWidth < 550) {
              cols = 3;
            } else {
              cols = 4;
            }
            finalCols = crossAxisCount ?? cols;

            // Calculate card width
            final double totalSpacing = (finalCols - 1) * 16;
            final double cardWidth = (gridWidth - totalSpacing) / finalCols;

            // Target height around 120.0 for a modern sleek horizontal card layout on desktop
            const double targetHeight = 120.0;
            double ratio = cardWidth / targetHeight;

            // Limit ratio to fit elegantly
            if (ratio < 0.8) ratio = 0.8;
            if (ratio > 2.2) ratio = 2.2;

            finalRatio = childAspectRatio ?? ratio;
          } else {
            // Mobile defaults: 2 items per row
            finalCols = crossAxisCount ?? 2;
            finalRatio = childAspectRatio ?? 0.95;
          }

          return GridView.builder(
            clipBehavior: Clip.none,
            controller: isBottomContainer ? null : scrollController,
            shrinkWrap: isBottomContainer,
            physics: isBottomContainer
                ? const NeverScrollableScrollPhysics()
                : (isBottomSheet || isBottomContainer
                    ? const AlwaysScrollableScrollPhysics()
                    : const BouncingScrollPhysics()),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: finalCols,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: finalRatio,
            ),
            itemCount: categoriesList.length,
            itemBuilder: (context, index) {
              final mainCategory = categoriesList[index];
              final categoryItem = _toCategoryItem(mainCategory, index);
              return CategoryCard(
                category: categoryItem,
                onTap: () => onCategoryTap(categoryItem),
              );
            },
          );
        },
      );
    }

    return const SizedBox.shrink();
  }
}
