import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../../../core/constants/colors.dart';

class ServiceTypesBox extends StatefulWidget {
  final String subCategoryTitle;
  final List<SubSubCategoryItem> serviceTypes;
  final List<SubSubCategoryItem> initialSelectedServiceTypes;
  final Function(List<SubSubCategoryItem> selectedServiceTypes) onServiceTypesSelected;

  const ServiceTypesBox({
    super.key,
    required this.subCategoryTitle,
    required this.serviceTypes,
    required this.initialSelectedServiceTypes,
    required this.onServiceTypesSelected,
  });

  static void show(
    BuildContext context, {
    required String subCategoryTitle,
    required List<SubSubCategoryItem> serviceTypes,
    required List<SubSubCategoryItem> initialSelectedServiceTypes,
    required Function(List<SubSubCategoryItem> selectedServiceTypes) onServiceTypesSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceTypesBox(
        subCategoryTitle: subCategoryTitle,
        serviceTypes: serviceTypes,
        initialSelectedServiceTypes: initialSelectedServiceTypes,
        onServiceTypesSelected: onServiceTypesSelected,
      ),
    );
  }

  @override
  State<ServiceTypesBox> createState() => _ServiceTypesBoxState();
}

class _ServiceTypesBoxState extends State<ServiceTypesBox> {
  final List<SubSubCategoryItem> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _selectedItems.addAll(widget.initialSelectedServiceTypes);
  }

  void _toggleSelection(SubSubCategoryItem item) {
    setState(() {
      final isSelected = _selectedItems.any((i) => i.id == item.id);
      if (isSelected) {
        _selectedItems.removeWhere((i) => i.id == item.id);
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
                        widget.subCategoryTitle.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select Service Types',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF2C3E50),
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

          // 4-Column Grid of sub-subcategories (Service Types)
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
              itemCount: widget.serviceTypes.length,
              itemBuilder: (context, index) {
                final subSub = widget.serviceTypes[index];
                final isSelected = _selectedItems.any((i) => i.id == subSub.id);

                return GestureDetector(
                  onTap: () => _toggleSelection(subSub),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Circular Card with Gradient Border (Thick Green border matching page 4 of the PDF)
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: isSelected
                                    ? [const Color(0xFF00B0FF), const Color(0xFF00E5FF)]
                                    : [Colors.grey.shade300, Colors.grey.shade400],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? const Color(0xFF00E5FF).withValues(alpha: 0.25)
                                      : Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(3), // Border thickness
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? AppColors.darkSurface : Colors.white,
                              ),
                              child: Center(
                                child: Icon(
                                  subSub.icon,
                                  color: isSelected
                                      ? (isDark ? const Color(0xFF00E5FF) : const Color(0xFF00B0FF))
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
                                  color: Color(0xFF00B0FF),
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
                        subSub.title.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                          color: isSelected
                              ? (isDark ? const Color(0xFF00E5FF) : const Color(0xFF0F4C81))
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
              padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding == 0 ? 16 : 8),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00B0FF), Color(0xFF00E5FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onServiceTypesSelected(_selectedItems);
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
                        : 'PROCEED TO REGISTRATION (${_selectedItems.length} SELECTED)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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
