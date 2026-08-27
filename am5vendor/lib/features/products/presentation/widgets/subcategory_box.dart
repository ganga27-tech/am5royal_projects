import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../../../core/constants/colors.dart';

class SubCategoryBox extends StatefulWidget {
  final String superCategoryTitle;
  final List<SubCategoryItem> subcategories;
  final List<SubCategoryItem> initialSelectedSubCategories;
  final Function(List<SubCategoryItem> selectedSubCategories)
      onSubCategoriesSelected;

  const SubCategoryBox({
    super.key,
    required this.superCategoryTitle,
    required this.subcategories,
    required this.initialSelectedSubCategories,
    required this.onSubCategoriesSelected,
  });

  static void show(
    BuildContext context, {
    required String superCategoryTitle,
    required List<SubCategoryItem> subcategories,
    required List<SubCategoryItem> initialSelectedSubCategories,
    required Function(List<SubCategoryItem> selectedSubCategories)
        onSubCategoriesSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SubCategoryBox(
        superCategoryTitle: superCategoryTitle,
        subcategories: subcategories,
        initialSelectedSubCategories: initialSelectedSubCategories,
        onSubCategoriesSelected: onSubCategoriesSelected,
      ),
    );
  }

  @override
  State<SubCategoryBox> createState() => _SubCategoryBoxState();
}

class _SubCategoryBoxState extends State<SubCategoryBox> {
  final List<SubCategoryItem> _selectedItems = [];

  bool _isItemMatch(SubCategoryItem a, SubCategoryItem b) {
    if (a.id == b.id) return true;
    if (a.title.isNotEmpty && b.title.isNotEmpty) {
      return a.title.trim().toLowerCase() == b.title.trim().toLowerCase();
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _selectedItems.addAll(widget.initialSelectedSubCategories);
  }

  void _toggleSelection(SubCategoryItem item) {
    setState(() {
      final isSelected = _selectedItems.any((i) => _isItemMatch(i, item));
      if (isSelected) {
        _selectedItems.removeWhere((i) => _isItemMatch(i, item));
      } else {
        _selectedItems.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.superCategoryTitle.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select Service Sub Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              isDark ? Colors.white : const Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 24),

          // 4-Column Grid of subcategories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 20,
                childAspectRatio: 0.75,
              ),
              itemCount: widget.subcategories.length,
              itemBuilder: (context, index) {
                final sub = widget.subcategories[index];
                final isSelected = _selectedItems.any((i) => _isItemMatch(i, sub));

                return GestureDetector(
                  onTap: () => _toggleSelection(sub),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Circular Card with Gradient Border
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: isSelected
                                    ? [
                                        const Color(0xFF00C6FF),
                                        const Color(0xFF0072FF)
                                      ]
                                    : [
                                        Colors.grey.shade300,
                                        Colors.grey.shade400
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? const Color(0xFF0072FF)
                                          .withValues(alpha: 0.25)
                                      : Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding:
                                const EdgeInsets.all(3), // Border thickness
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? AppColors.darkSurface : Colors.white,
                              ),
                              child: Center(
                                child: Icon(
                                  sub.icon,
                                  color: isSelected
                                      ? (isDark ? const Color(0xFF00C6FF) : const Color(0xFF0072FF))
                                      : (isDark ? Colors.white : Colors.grey.shade600),
                                  size: 24,
                                ),
                              ),
                            ),
                          ),

                          // Circular checkmark selection badge overlay
                          if (isSelected)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0072FF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Label
                      Text(
                        sub.title.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight:
                              isSelected ? FontWeight.w900 : FontWeight.w600,
                          color: isSelected
                              ? (isDark ? const Color(0xFF00C6FF) : const Color(0xFF0F4C81))
                              : (isDark ? Colors.white70 : Colors.grey.shade600),
                          height: 1.2,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Bottom Proceed Button inside SafeArea
          SafeArea(
            top: false,
            child: Padding(
              padding:
                  EdgeInsets.fromLTRB(24, 0, 24, bottomPadding == 0 ? 16 : 8),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0072FF).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onSubCategoriesSelected(_selectedItems);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _selectedItems.isEmpty
                        ? 'PROCEED'
                        : 'PROCEED (${_selectedItems.length} SELECTED)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
