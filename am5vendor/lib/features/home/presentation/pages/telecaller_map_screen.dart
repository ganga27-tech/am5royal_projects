import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../products/data/models/product_model.dart';
import '../../data/models/telecaller_vendor_onboard_request_model.dart';
import '../../../supercategory/domain/entities/main_category.dart';
import '../../../products/presentation/widgets/categories_dashboard.dart';
import '../../../products/presentation/widgets/dynamic_subcategory_box.dart';
import '../../data/datasources/employee_api_service.dart';
import '../../../../core/di/injection_container.dart' as di;

class TelecallerMapScreen extends ConsumerStatefulWidget {
  final String mobile;
  final TelecallerVendorOnboardRequestModel request;

  const TelecallerMapScreen({
    super.key,
    required this.mobile,
    required this.request,
  });

  @override
  ConsumerState<TelecallerMapScreen> createState() => _TelecallerMapScreenState();
}

class _TelecallerMapScreenState extends ConsumerState<TelecallerMapScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final PageController _pageController = PageController();
  late TelecallerVendorOnboardRequestModel _request;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _request = widget.request;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _navigateToServiceSelection({
    required MainCategory mainCategory,
    required TelecallerCategoryRequest pendingCategory,
    required List<SubCategoryItem> selectedSubCategories,
  }) async {
    final result = await context.push<TelecallerVendorOnboardRequestModel>(
      '/telecaller/select-service',
      extra: {
        'mobile': widget.mobile,
        'request': _request,
        'mainCategory': mainCategory,
        'selectedSubCategories': selectedSubCategories,
        'pendingCategory': pendingCategory,
      },
    );

    if (result != null && mounted) {
      setState(() => _request = result);
    }
  }

  void _handleCategoryTap(CategoryItem category) {
    final mainCategory = MainCategory(
      id: int.tryParse(category.id) ?? 0,
      name: category.name,
      iconUrl: category.imageUrl,
      hasSubcategories: category.hasSubcategories,
    );

    if (category.hasSubcategories) {
      final categoryId = int.tryParse(category.id) ?? 0;
      final existingCat = _request.categories
          .where((c) => c.mainCategoryId == category.id)
          .firstOrNull;
      final initialSelected = existingCat != null
          ? existingCat.subCategoryIds
              .map((id) => SubCategoryItem(
                    id: id,
                    title: '',
                    icon: Icons.category_rounded,
                    color: Colors.blue,
                  ))
              .toList()
          : const <SubCategoryItem>[];

      DynamicSubCategoryBox.show(
        context,
        categoryId: categoryId,
        superCategoryTitle: category.title,
        mainCategory: mainCategory,
        isSingleService: false,
        selectionOnly: true,
        initialSelectedSubCategories: initialSelected,
        onSubCategoriesSelected: (selectedList) async {
          if (selectedList.isEmpty) return;

          final pendingCategory = TelecallerCategoryRequest(
            mainCategoryId: category.id,
            subCategoryIds: selectedList.map((s) => s.id).toList(),
          );

          await _navigateToServiceSelection(
            mainCategory: mainCategory,
            pendingCategory: pendingCategory,
            selectedSubCategories: selectedList,
          );
        },
      );
    } else {
      final pendingCategory = TelecallerCategoryRequest(
        mainCategoryId: category.id,
        subCategoryIds: [],
      );

      _navigateToServiceSelection(
        mainCategory: mainCategory,
        pendingCategory: pendingCategory,
        selectedSubCategories: const [],
      );
    }
  }

  Future<void> _completeOnboarding() async {
    if (_request.categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one category with services before continuing.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isCompleting = true);

    try {
      final response = await di.sl<EmployeeApiService>().telecallerCompleteOnboarding(widget.mobile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Vendor registration completed'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/telecaller-dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCompleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.sizeOf(context).width > 900;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Categories',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: isDark ? Colors.white : const Color(0xFF0F172A)),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            ),
          ),
          Positioned(
            top: -100,
            left: -100,
            child: IgnorePointer(
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF2563EB).withValues(alpha: isDark ? 0.12 : 0.06),
                      const Color(0xFF2563EB).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -50,
            child: IgnorePointer(
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.1 : 0.05),
                      const Color(0xFF8B5CF6).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 16, 28, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vendor Onboarding'.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Choose Core Categories',
                        style: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select categories and configure services. You can add multiple categories, then tap Continue when done.',
                        style: GoogleFonts.outfit(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                          height: 1.4,
                        ),
                      ),
                      if (_request.categories.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          '${_request.categories.length} categor${_request.categories.length == 1 ? 'y' : 'ies'} added · ${_request.services.length} service${_request.services.length == 1 ? '' : 's'}',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _searchQuery = value),
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search categories...',
                        hintStyle: GoogleFonts.outfit(
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          fontSize: 15,
                        ),
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: CategoriesDashboard(
                    pageController: _pageController,
                    onCategoryTap: _handleCategoryTap,
                    searchQuery: _searchQuery,
                    childAspectRatio: isDesktop ? 2.0 : 1.1,
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: ElevatedButton(
                      onPressed: _isCompleting ? null : _completeOnboarding,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isCompleting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'Continue (Finish Registration)',
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
