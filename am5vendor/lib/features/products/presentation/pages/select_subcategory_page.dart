import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../core/constants/colors.dart';
import '../../../supercategory/data/datasources/main_category_api_service.dart';
import '../../../supercategory/presentation/providers/main_category_providers.dart';
import '../../../supercategory/presentation/providers/service_providers.dart';
import '../../../supercategory/presentation/bloc/subcategory_bloc.dart';
import '../../../supercategory/presentation/bloc/subcategory_event.dart';
import '../../../supercategory/presentation/bloc/subcategory_state.dart';
import '../../../supercategory/domain/entities/subcategory_entity.dart';
import '../../../supercategory/domain/entities/main_category.dart';
import '../../data/models/product_model.dart';
import '../../../../core/services/onboarding_session_guard.dart';
import '../../../../core/di/injection_container.dart' as di;

class SelectSubcategoryPage extends ConsumerStatefulWidget {
  final int categoryId;
  final String superCategoryTitle;
  final MainCategory mainCategory;
  final bool isSingleService;
  final List<SubCategoryItem> initialSelectedSubCategories;

  const SelectSubcategoryPage({
    super.key,
    required this.categoryId,
    required this.superCategoryTitle,
    required this.mainCategory,
    required this.isSingleService,
    required this.initialSelectedSubCategories,
  });

  @override
  ConsumerState<SelectSubcategoryPage> createState() =>
      _SelectSubcategoryPageState();
}

class _SelectSubcategoryPageState extends ConsumerState<SelectSubcategoryPage> {
  final List<SubCategoryItem> _selectedItems = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late stt.SpeechToText _speech;
  bool _isListening = false;

  bool _isItemMatch(SubCategoryItem a, SubCategoryItem b) {
    final aId = int.tryParse(a.id);
    final bId = int.tryParse(b.id);
    if (aId != null && bId != null && aId > 0 && bId > 0) {
      if (aId == bId) return true;
    } else if (a.id.isNotEmpty && b.id.isNotEmpty && a.id == b.id) {
      return true;
    }
    if (a.title.isNotEmpty && b.title.isNotEmpty) {
      return a.title.trim().toLowerCase() == b.title.trim().toLowerCase();
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _selectedItems.addAll(widget.initialSelectedSubCategories);
    _initSpeech();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(subCategoryBlocProvider)
          .add(FetchSubCategories(widget.categoryId));
    });
  }

  Future<void> _initSpeech() async {
    await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (errorNotification) {
        if (mounted) {
          setState(() => _isListening = false);
          final err = errorNotification.errorMsg.toLowerCase();
          if (err.contains('timeout') ||
              err.contains('no_match') ||
              err.contains('no match') ||
              err.contains('client')) {
            return;
          }
        }
      },
    );
  }

  Future<void> _listenVoice() async {
    if (_isListening) {
      setState(() => _isListening = false);
      _speech.stop();
      return;
    }

    if (!_speech.isAvailable) {
      // Try re-initializing if not available yet
      await _initSpeech();
    }

    if (_speech.isAvailable) {
      setState(() {
        _isListening = true;
        _searchController.clear();
        _searchQuery = '';
      });
      _speech.listen(
        onResult: (val) {
          if (mounted && val.recognizedWords.isNotEmpty) {
            setState(() {
              _searchController.text = val.recognizedWords;
              _searchController.selection = TextSelection.fromPosition(
                TextPosition(offset: _searchController.text.length),
              );
              _searchQuery = val.recognizedWords.trim().toLowerCase();
            });
          }
        },
        listenOptions: stt.SpeechListenOptions(
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 4),
          cancelOnError: false,
          partialResults: true,
          localeId: 'en_IN',
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition not available on this device.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSubcategoryTapped(SubCategoryItem item) async {
    final isAlreadySelected = _selectedItems.any((i) => _isItemMatch(i, item));

    if (!isAlreadySelected &&
        widget.isSingleService &&
        _selectedItems.isNotEmpty) {
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
      final subId = int.tryParse(item.id) ?? 0;
      if (subId > 0) {
        final repo = ref.read(serviceRepositoryProvider);
        await repo.removeSubCategory(subId);
      }
      if (mounted) {
        ref
            .read(subCategoryBlocProvider)
            .add(FetchSubCategories(widget.categoryId));
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

    if (mounted) {
      if (result == true) {
        setState(() {
          final isSelected = _selectedItems.any((i) => _isItemMatch(i, item));
          if (!isSelected) {
            if (widget.isSingleService) {
              _selectedItems.clear();
            }
            _selectedItems.add(item);
          }
        });
      }
      // Re-fetch backend subcategories to ensure DB selection state is fresh
      ref
          .read(subCategoryBlocProvider)
          .add(FetchSubCategories(widget.categoryId));
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
        id: entity.id > 0 ? entity.id.toString() : matchedItem.id,
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
        name.contains('compressor')) {
      icon = Icons.build_rounded;
      color = const Color(0xFFFF9800);
    } else if (name.contains('electric') || name.contains('wire')) {
      icon = Icons.bolt_rounded;
      color = const Color(0xFFFFC107);
    } else if (name.contains('plumb') || name.contains('water')) {
      icon = Icons.plumbing_rounded;
      color = const Color(0xFF03A9F4);
    } else if (name.contains('clean') || name.contains('wash')) {
      icon = Icons.clean_hands_rounded;
      color = const Color(0xFF00BCD4);
    }

    return SubCategoryItem(
      id: entity.id.toString(),
      title: entity.name,
      icon: icon,
      color: color,
      iconUrl: entity.iconUrl,
    );
  }

  Future<void> _handleProceed() async {
    if (_selectedItems.isEmpty) return;

    OnboardingSessionGuard.instance.unlockOnForwardProgress();
    try {
      await di.sl<MainCategoryApiService>().completeServiceSelection();
    } catch (_) {}

    if (!mounted) return;
    await context.push(
      '/vendor-registration',
      extra: {
        'mainCategoryId': widget.mainCategory.id,
        'mainCategoryName': widget.mainCategory.name,
        'selectedSubCategories': _selectedItems,
        'selectedServiceTypes': const [],
      },
    );

    // Re-fetch when user comes back from registration screens so
    // vendor_sub_categories DB state is synced (ticks stay selected)
    if (mounted) {
      ref
          .read(subCategoryBlocProvider)
          .add(FetchSubCategories(widget.categoryId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bloc = ref.watch(subCategoryBlocProvider);
    final canProceed = _selectedItems.isNotEmpty;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.superCategoryTitle,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark
                  ? Colors.white10
                  : Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            onPressed: () => context.pop(_selectedItems),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CHOOSE SUB CATEGORY',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color:
                          isDark ? AppColors.primaryLight : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select Service Sub Categories',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.isSingleService
                        ? 'Individual profile: Select 1 sub-category'
                        : 'Business profile: Select one or more sub-categories',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.06),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim().toLowerCase();
                        });
                      },
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search subcategories...',
                        hintStyle: GoogleFonts.outfit(
                          fontSize: 14,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primary,
                          size: 20,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                _isListening
                                    ? Icons.mic_rounded
                                    : Icons.mic_none_rounded,
                                size: 20,
                                color: _isListening
                                    ? Colors.redAccent
                                    : (isDark
                                        ? AppColors.primaryLight
                                        : AppColors.primary),
                              ),
                              onPressed: _listenVoice,
                            ),
                            if (_searchController.text.isNotEmpty)
                              IconButton(
                                icon: Icon(
                                  Icons.clear_rounded,
                                  size: 18,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black45,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              ),
                          ],
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BlocConsumer<SubCategoryBloc, SubCategoryState>(
                bloc: bloc,
                listener: (context, state) {
                  if (state is SubCategorySuccess) {
                    setState(() {
                      for (final entity in state.subcategories) {
                        if (entity.isSelected) {
                          final item = _mapEntityToItem(entity);
                          if (!_selectedItems.any((i) => _isItemMatch(i, item))) {
                            _selectedItems.add(item);
                          }
                        }
                      }
                    });
                  }
                },
                builder: (context, state) {
                  if (state is SubCategoryLoading ||
                      state is SubCategoryInitial) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    );
                  } else if (state is SubCategoryError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: Colors.redAccent, size: 48),
                          const SizedBox(height: 16),
                          Text(state.message,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                bloc.add(FetchSubCategories(widget.categoryId)),
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  } else if (state is SubCategorySuccess) {
                    final allMappedItems = state.subcategories
                        .map((entity) => _mapEntityToItem(entity))
                        .toList();

                    final mappedItems = _searchQuery.isEmpty
                        ? allMappedItems
                        : allMappedItems
                            .where((item) =>
                                item.title.toLowerCase().contains(_searchQuery))
                            .toList();

                    if (mappedItems.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No subcategories found for "$_searchQuery"',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: isDark ? Colors.white60 : Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      physics: const BouncingScrollPhysics(),
                      itemCount: mappedItems.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final sub = mappedItems[index];
                        final isSelected =
                            _selectedItems.any((i) => _isItemMatch(i, sub));

                        return _SubCategoryCardWidget(
                          sub: sub,
                          isSelected: isSelected,
                          isDark: isDark,
                          onTap: () => _onSubcategoryTapped(sub),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            // Bottom Proceed Bar
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: canProceed ? AppColors.primaryGradient : null,
                  color: canProceed
                      ? null
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05)),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: canProceed
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [],
                ),
                child: ElevatedButton(
                  onPressed: canProceed ? _handleProceed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
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
                              : (isDark ? Colors.white38 : Colors.black38),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubCategoryCardWidget extends StatelessWidget {
  final SubCategoryItem sub;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _SubCategoryCardWidget({
    required this.sub,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? const Color(0xFF1B2A4A) : const Color(0xFFEEF6FD))
            : (isDark ? AppColors.darkSurface : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? (isDark ? AppColors.primaryLight : AppColors.primary)
              : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
          width: isSelected ? 2.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.12)
                : const Color(0xFF18181B).withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
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
                            width: 44,
                            height: 44,
                            errorBuilder: (_, __, ___) => Icon(
                              sub.icon,
                              color: isSelected
                                  ? (isDark
                                      ? AppColors.primaryLight
                                      : AppColors.primary)
                                  : (isDark ? Colors.white : sub.color),
                              size: 22,
                            ),
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
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    sub.title,
                    style: GoogleFonts.outfit(
                      fontSize: 13.0,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isDark
                          ? Colors.white
                          : (isSelected
                              ? AppColors.primary
                              : const Color(0xFF18181B)),
                      height: 1.25,
                    ),
                    maxLines: 4,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? (isDark ? AppColors.primaryLight : AppColors.primary)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? (isDark
                              ? AppColors.primaryLight
                              : AppColors.primary)
                          : (isDark ? Colors.white38 : const Color(0xFFCBD5E1)),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded,
                          size: 14, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
