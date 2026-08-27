import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../supercategory/presentation/providers/main_category_providers.dart';
import '../../../supercategory/presentation/providers/service_providers.dart';
import '../../../supercategory/presentation/bloc/subcategory_bloc.dart';
import '../../../supercategory/presentation/bloc/subcategory_event.dart';
import '../../../supercategory/presentation/bloc/subcategory_state.dart';
import '../../../supercategory/domain/entities/subcategory_entity.dart';
import '../../../supercategory/domain/entities/main_category.dart';
import '../../data/models/product_model.dart';

class DynamicSubCategoryBox extends ConsumerStatefulWidget {
  final int categoryId;
  final String superCategoryTitle;
  final MainCategory mainCategory;
  final bool isSingleService;
  final bool selectionOnly;
  final bool requireSelectionToProceed;
  final List<SubCategoryItem> initialSelectedSubCategories;
  final Future<void> Function(SubCategoryItem subCategory)?
      onSubCategoryServicesAdded;
  final Future<void> Function(SubCategoryItem subCategory)?
      onSubCategoryRemoved;
  final Future<void> Function(List<SubCategoryItem> selectedSubCategories)
      onSubCategoriesSelected;

  const DynamicSubCategoryBox({
    super.key,
    required this.categoryId,
    required this.superCategoryTitle,
    required this.mainCategory,
    required this.isSingleService,
    this.selectionOnly = false,
    this.requireSelectionToProceed = false,
    required this.initialSelectedSubCategories,
    this.onSubCategoryServicesAdded,
    this.onSubCategoryRemoved,
    required this.onSubCategoriesSelected,
  });

  static void show(
    BuildContext context, {
    required int categoryId,
    required String superCategoryTitle,
    required MainCategory mainCategory,
    required bool isSingleService,
    bool selectionOnly = false,
    bool requireSelectionToProceed = false,
    required List<SubCategoryItem> initialSelectedSubCategories,
    Future<void> Function(SubCategoryItem subCategory)?
        onSubCategoryServicesAdded,
    Future<void> Function(SubCategoryItem subCategory)? onSubCategoryRemoved,
    required Future<void> Function(List<SubCategoryItem> selectedSubCategories)
        onSubCategoriesSelected,
  }) {
    final isDesktop = MediaQuery.sizeOf(context).width > 900;
    if (isDesktop) {
      showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.45),
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 540,
              maxHeight: MediaQuery.sizeOf(context).height * 0.85,
            ),
            child: DynamicSubCategoryBox(
              categoryId: categoryId,
              superCategoryTitle: superCategoryTitle,
              mainCategory: mainCategory,
              isSingleService: isSingleService,
              selectionOnly: selectionOnly,
              requireSelectionToProceed: requireSelectionToProceed,
              initialSelectedSubCategories: initialSelectedSubCategories,
              onSubCategoryServicesAdded: onSubCategoryServicesAdded,
              onSubCategoryRemoved: onSubCategoryRemoved,
              onSubCategoriesSelected: onSubCategoriesSelected,
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DynamicSubCategoryBox(
          categoryId: categoryId,
          superCategoryTitle: superCategoryTitle,
          mainCategory: mainCategory,
          isSingleService: isSingleService,
          selectionOnly: selectionOnly,
          requireSelectionToProceed: requireSelectionToProceed,
          initialSelectedSubCategories: initialSelectedSubCategories,
          onSubCategoryServicesAdded: onSubCategoryServicesAdded,
          onSubCategoryRemoved: onSubCategoryRemoved,
          onSubCategoriesSelected: onSubCategoriesSelected,
        ),
      );
    }
  }

  @override
  ConsumerState<DynamicSubCategoryBox> createState() =>
      _DynamicSubCategoryBoxState();
}

class _DynamicSubCategoryBoxState extends ConsumerState<DynamicSubCategoryBox> {
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
    ref
        .read(subCategoryBlocProvider)
        .add(FetchSubCategories(widget.categoryId));
  }

  @override
  void didUpdateWidget(covariant DynamicSubCategoryBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSelectedSubCategories !=
        widget.initialSelectedSubCategories) {
      for (final item in widget.initialSelectedSubCategories) {
        if (!_selectedItems.any((i) => _isItemMatch(i, item))) {
          _selectedItems.add(item);
        }
      }
    }
  }

  Future<void> _onSubcategoryTapped(SubCategoryItem item) async {
    final isAlreadySelected = _selectedItems.any((i) => _isItemMatch(i, item));

    if (widget.selectionOnly) {
      setState(() {
        if (isAlreadySelected) {
          _selectedItems.removeWhere((i) => _isItemMatch(i, item));
        } else {
          if (widget.isSingleService) {
            _selectedItems.clear();
          }
          _selectedItems.add(item);
        }
      });
      if (isAlreadySelected && widget.onSubCategoryRemoved != null) {
        await widget.onSubCategoryRemoved!(item);
      }
      return;
    }

    if (!isAlreadySelected && widget.isSingleService && _selectedItems.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Individual accounts can select only 1 sub-category. Please unselect the current sub-category first.'),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (isAlreadySelected) {
      setState(() {
        _selectedItems.removeWhere((i) => _isItemMatch(i, item));
      });
      widget.onSubCategoriesSelected(_selectedItems);
      final subId = int.tryParse(item.id) ?? 0;
      if (subId > 0) {
        final repo = ref.read(serviceRepositoryProvider);
        await repo.removeSubCategory(subId);
      }
      if (widget.onSubCategoryRemoved != null) {
        await widget.onSubCategoryRemoved!(item);
      }
      return;
    }

    final subCategoryEntity = SubCategoryEntity(
      id: int.tryParse(item.id) ?? 0,
      name: item.title,
      iconUrl: item.iconUrl ?? '',
    );

    final result = await context.push<bool>(
      '/select-service',
      extra: {
        'mainCategory': widget.mainCategory,
        'selectedSubCategories': [subCategoryEntity],
      },
    );

    if (result == true) {
      if (mounted) {
        if (widget.onSubCategoryServicesAdded != null) {
          await widget.onSubCategoryServicesAdded!(item);
        }
        setState(() {
          final isSelected = _selectedItems.any((i) => _isItemMatch(i, item));
          if (!isSelected) {
            if (widget.isSingleService) {
              _selectedItems.clear();
            }
            _selectedItems.add(item);
          }
        });
        widget.onSubCategoriesSelected(_selectedItems);
      }
    }
  }

  SubCategoryItem _mapEntityToItem(SubCategoryEntity entity) {
    SubCategoryItem? matchedItem;
    for (final cat in ProductModel.categories) {
      final subs = ProductModel.getSubCategoriesFor(cat.title);
      for (final sub in subs) {
        if (sub.title.toLowerCase() == entity.name.toLowerCase()) {
          matchedItem = sub;
          break;
        }
      }
      if (matchedItem != null) break;
    }

    if (matchedItem != null) {
      return SubCategoryItem(
        id: entity.id.toString(),
        title: entity.name,
        icon: matchedItem.icon,
        color: matchedItem.color,
        iconUrl: entity.iconUrl,
      );
    }

    final name = entity.name.toLowerCase();
    IconData icon = Icons.category_rounded;
    Color color = const Color(0xFF0C3D98);

    if (name.contains('ac') || name.contains('air condition')) {
      icon = Icons.ac_unit_rounded;
      color = const Color(0xFF2196F3);
    } else if (name.contains('repair') ||
        name.contains('fix') ||
        name.contains('compressor') ||
        name.contains('motor')) {
      icon = Icons.build_rounded;
      color = const Color(0xFFFF9800);
    } else if (name.contains('electric') ||
        name.contains('wire') ||
        name.contains('power') ||
        name.contains('light')) {
      icon = Icons.bolt_rounded;
      color = const Color(0xFFFFC107);
    } else if (name.contains('plumb') ||
        name.contains('water') ||
        name.contains('leak') ||
        name.contains('pipe')) {
      icon = Icons.plumbing_rounded;
      color = const Color(0xFF03A9F4);
    } else if (name.contains('pest') ||
        name.contains('bug') ||
        name.contains('termite') ||
        name.contains('rodent') ||
        name.contains('ant') ||
        name.contains('cockroach')) {
      icon = Icons.bug_report_rounded;
      color = const Color(0xFFE91E63);
    } else if (name.contains('clean') ||
        name.contains('wash') ||
        name.contains('sanitize') ||
        name.contains('dust')) {
      icon = Icons.clean_hands_rounded;
      color = const Color(0xFF00BCD4);
    } else if (name.contains('paint') || name.contains('decor')) {
      icon = Icons.format_paint_rounded;
      color = const Color(0xFF9C27B0);
    } else if (name.contains('security') ||
        name.contains('guard') ||
        name.contains('safe') ||
        name.contains('cctv')) {
      icon = Icons.security_rounded;
      color = const Color(0xFF3F51B5);
    } else if (name.contains('health') ||
        name.contains('medical') ||
        name.contains('doctor') ||
        name.contains('hospital') ||
        name.contains('clinic')) {
      icon = Icons.medical_services_rounded;
      color = const Color(0xFFE53935);
    } else if (name.contains('edu') ||
        name.contains('class') ||
        name.contains('teach') ||
        name.contains('learn') ||
        name.contains('school') ||
        name.contains('train')) {
      icon = Icons.school_rounded;
      color = const Color(0xFF4CAF50);
    }

    return SubCategoryItem(
      id: entity.id.toString(),
      title: entity.name,
      icon: icon,
      color: color,
      iconUrl: entity.iconUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final bloc = ref.watch(subCategoryBlocProvider);
    final isDesktop = MediaQuery.sizeOf(context).width > 900;

    return Container(
      height: isDesktop ? null : screenHeight * 0.7,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: isDesktop
            ? BorderRadius.circular(28)
            : const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: isDesktop ? const Offset(0, 10) : const Offset(0, -4),
          ),
        ],
        border: isDesktop
            ? Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFE4E4E7),
                width: 1.5,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isDesktop) ...[
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
          ] else
            const SizedBox(height: 24),

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
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Select Service Sub Categories',
                        style: GoogleFonts.outfit(
                          fontSize: isDesktop ? 20 : 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimary,
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
          Divider(
            height: 1,
            thickness: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE4E4E7),
          ),
          const SizedBox(height: 24),

          // Bloc builder handling states
          Flexible(
            fit: FlexFit.loose,
            child: BlocBuilder<SubCategoryBloc, SubCategoryState>(
              bloc: bloc,
              builder: (context, state) {
                if (state is SubCategoryLoading ||
                    state is SubCategoryInitial) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading subcategories...',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is SubCategoryError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: Colors.redAccent,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              bloc.add(FetchSubCategories(widget.categoryId));
                            },
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Try Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (state is SubCategoryEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          color: Colors.grey,
                          size: 48,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No subcategories found.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is SubCategorySuccess) {
                  final mappedItems = state.subcategories
                      .map((entity) => _mapEntityToItem(entity))
                      .toList();

                  final double horizontalPadding = isDesktop ? 24 : 20;

                  return Column(
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: GridView.builder(
                          shrinkWrap: true,
                          clipBehavior: Clip.hardEdge,
                          padding: EdgeInsets.only(
                            left: horizontalPadding,
                            right: horizontalPadding,
                            top: 8,
                            bottom: 16,
                          ),
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 2.2,
                          ),
                          itemCount: mappedItems.length,
                          itemBuilder: (context, index) {
                            final sub = mappedItems[index];
                            final isSelected =
                                _selectedItems.any((i) => _isItemMatch(i, sub));

                            return SubCategoryCard(
                              sub: sub,
                              isSelected: isSelected,
                              isDark: isDark,
                              onTap: () => _onSubcategoryTapped(sub),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Builder(
                        builder: (context) {
                          final canProceed =
                              !widget.requireSelectionToProceed ||
                                  _selectedItems.isNotEmpty;
                          final proceedBtn = Padding(
                            padding: EdgeInsets.fromLTRB(
                              24,
                              0,
                              24,
                              isDesktop ? 24 : (bottomPadding == 0 ? 16 : 8),
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                gradient: canProceed
                                    ? AppColors.primaryGradient
                                    : null,
                                color: canProceed
                                    ? null
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.black.withValues(alpha: 0.05)),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: canProceed
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.25),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: ElevatedButton(
                                onPressed: !canProceed
                                    ? null
                                    : () async {
                                        final selected =
                                            List<SubCategoryItem>.from(
                                          _selectedItems,
                                        );
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                        await Future<void>.delayed(
                                          Duration.zero,
                                        );
                                        await widget.onSubCategoriesSelected(
                                          selected,
                                        );
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _selectedItems.isEmpty
                                          ? 'PROCEED'
                                          : 'PROCEED (${_selectedItems.length} SELECTED)',
                                      style: GoogleFonts.outfit(
                                        color: canProceed
                                            ? Colors.white
                                            : (isDark
                                                ? Colors.white38
                                                : Colors.black38),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );

                          if (isDesktop) {
                            return proceedBtn;
                          } else {
                            return SafeArea(
                              top: false,
                              child: proceedBtn,
                            );
                          }
                        },
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SubCategoryCard extends StatefulWidget {
  final SubCategoryItem sub;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const SubCategoryCard({
    super.key,
    required this.sub,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<SubCategoryCard> createState() => _SubCategoryCardState();
}

class _SubCategoryCardState extends State<SubCategoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final isSelected = widget.isSelected;
    final sub = widget.sub;
    final isDesktop = MediaQuery.sizeOf(context).width > 900;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF1B2A4A) : const Color(0xFFEEF6FD))
                : (isDark
                    ? (_isHovered
                        ? const Color(0xFF233250)
                        : AppColors.darkSurface)
                    : (_isHovered ? const Color(0xFFF8FAFC) : Colors.white)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? (isDark ? AppColors.primaryLight : AppColors.primary)
                  : (isDark
                      ? (_isHovered ? Colors.white30 : Colors.white12)
                      : (_isHovered
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFFE2E8F0))),
              width: isSelected ? 2.0 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: _isHovered ? 0.25 : 0.12)
                    : const Color(0xFF18181B)
                        .withValues(alpha: _isHovered ? 0.05 : 0.02),
                blurRadius: _isHovered ? 16 : 8,
                offset: _isHovered ? const Offset(0, 6) : const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(20),
              splashColor: AppColors.primary.withValues(alpha: 0.08),
              highlightColor: AppColors.primary.withValues(alpha: 0.04),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 16, vertical: isDesktop ? 14 : 12),
                child: Row(
                  children: [
                    // Icon Container (Circle)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark
                                ? AppColors.primaryLight.withValues(alpha: 0.25)
                                : AppColors.primary.withValues(alpha: 0.12))
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.12)
                                : sub.color.withValues(alpha: 0.08)),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: sub.iconUrl != null && sub.iconUrl!.isNotEmpty
                            ? SvgPicture.network(
                                sub.iconUrl!,
                                colorFilter: ColorFilter.mode(
                                  isSelected
                                      ? (isDark
                                          ? AppColors.primaryLight
                                          : AppColors.primary)
                                      : (isDark ? Colors.white : sub.color),
                                  BlendMode.srcIn,
                                ),
                                width: 22,
                                height: 22,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    sub.icon,
                                    color: isSelected
                                        ? (isDark
                                            ? AppColors.primaryLight
                                            : AppColors.primary)
                                        : (isDark ? Colors.white : sub.color),
                                    size: 22,
                                  );
                                },
                              )
                            : Icon(
                                sub.icon,
                                color: isSelected
                                    ? (isDark
                                        ? AppColors.primaryLight
                                        : AppColors.primary)
                                    : (isDark ? Colors.white : sub.color),
                                size: 22,
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Title
                    Expanded(
                      child: Text(
                        sub.title,
                        style: GoogleFonts.outfit(
                          fontSize: isDesktop ? 13.5 : 12.0,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : (isSelected
                                  ? AppColors.primary
                                  : const Color(0xFF18181B)),
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Checkbox indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? (isDark
                                ? AppColors.primaryLight
                                : AppColors.primary)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? (isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary)
                              : (isDark
                                  ? Colors.white38
                                  : const Color(0xFFCBD5E1)),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 14,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
