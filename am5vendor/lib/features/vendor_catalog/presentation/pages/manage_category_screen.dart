import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/widgets/app_network_image.dart';
import '../../../products/data/models/product_model.dart';
import '../../../products/presentation/widgets/categories_dashboard.dart';
import '../../../products/presentation/widgets/dynamic_subcategory_box.dart';
import '../../../supercategory/domain/entities/main_category.dart';
import '../../../supercategory/domain/entities/subcategory_entity.dart';
import '../../data/models/vendor_catalog_models.dart';
import '../../data/repositories/vendor_catalog_repository.dart';
import '../bloc/manage_catalog_bloc.dart';
import '../bloc/manage_catalog_event.dart';
import '../bloc/manage_catalog_state.dart';
import '../widgets/service_edit_sheet.dart';

class ManageCategoryScreen extends StatelessWidget {
  final bool navigateToPaymentOnProceed;

  const ManageCategoryScreen({
    super.key,
    this.navigateToPaymentOnProceed = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ManageCatalogBloc(
        repository: di.sl<VendorCatalogRepository>(),
      )..add(const LoadVendorCatalog()),
      child: _ManageCategoryView(
        navigateToPaymentOnProceed: navigateToPaymentOnProceed,
      ),
    );
  }
}

class _ManageCategoryView extends ConsumerStatefulWidget {
  final bool navigateToPaymentOnProceed;

  const _ManageCategoryView({required this.navigateToPaymentOnProceed});

  @override
  ConsumerState<_ManageCategoryView> createState() =>
      _ManageCategoryViewState();
}

class _ManageCategoryViewState extends ConsumerState<_ManageCategoryView> {
  bool _addingCategory = false;
  bool _hasActiveSubscription = false;
  bool _servicesAdded = false;
  bool _subscriptionLoaded = false;
  final List<SubCategoryItem> _sessionSubCategories = [];

  @override
  void initState() {
    super.initState();
    _loadSubscriptionStatus();
  }

  Future<void> _loadSubscriptionStatus() async {
    try {
      final dio = di.sl<Dio>();
      final response = await dio.get('/vendors/me/onboarding-status');
      if (response.statusCode == 200 && mounted) {
        final data = response.data as Map<String, dynamic>;
        setState(() {
          _hasActiveSubscription = data['subscription'] == true;
          _servicesAdded = data['services_added'] == true;
          _subscriptionLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _subscriptionLoaded = true);
      }
    }
  }

  bool get _canViewCatalog => _subscriptionLoaded && _hasActiveSubscription;

  bool get _goToPlansOnProceed => widget.navigateToPaymentOnProceed;

  Future<void> _openAddCategoryFlow() async {
    if (_addingCategory) return;
    setState(() {
      _addingCategory = true;
      _sessionSubCategories.clear();
    });

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Select Category',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: CategoriesDashboard(
                      onCategoryTap: (category) async {
                        Navigator.pop(ctx);
                        await _pickSubCategoriesAndServices(category);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (mounted) setState(() => _addingCategory = false);
  }

  Future<void> _pickSubCategoriesAndServices(CategoryItem categoryItem) async {
    await _loadSubscriptionStatus();
    if (!mounted) return;

    final hostContext = context;
    final mainCategory = MainCategory(
      id: int.tryParse(categoryItem.id) ?? 0,
      name: categoryItem.title,
      iconUrl: categoryItem.imageUrl,
      hasSubcategories: categoryItem.hasSubcategories,
    );

    if (!mainCategory.hasSubcategories) {
      await _openSelectService(mainCategory, const []);
      return;
    }

    if (!mounted) return;

    DynamicSubCategoryBox.show(
      context,
      categoryId: mainCategory.id,
      superCategoryTitle: mainCategory.name,
      mainCategory: mainCategory,
      isSingleService: false,
      selectionOnly: false,
      requireSelectionToProceed: _goToPlansOnProceed,
      initialSelectedSubCategories: _sessionSubCategories,
      onSubCategoryServicesAdded: (sub) async {
        await _registerSubCategories(
          mainCategory,
          [
            SubCategoryEntity(
              id: int.tryParse(sub.id) ?? 0,
              name: sub.title,
              iconUrl: sub.iconUrl ?? '',
            ),
          ],
        );
        if (mounted) {
          setState(() {
            if (!_sessionSubCategories.any((item) => item.id == sub.id)) {
              _sessionSubCategories.add(sub);
            }
          });
        }
      },
      onSubCategoryRemoved: (sub) async {
        final subId = int.tryParse(sub.id) ?? 0;
        if (subId > 0) {
          await di.sl<VendorCatalogRepository>().removeSubCategory(subId);
        }
        if (mounted) {
          setState(() {
            _sessionSubCategories.removeWhere((item) => item.id == sub.id);
          });
        }
      },
      onSubCategoriesSelected: (selected) async {
        final effectiveSelection = selected.isNotEmpty
            ? selected
            : List<SubCategoryItem>.from(_sessionSubCategories);

        final hasCatalogWork = effectiveSelection.isNotEmpty ||
            _sessionSubCategories.isNotEmpty ||
            _servicesAdded;

        if (_goToPlansOnProceed) {
          if (!hasCatalogWork) {
            if (!hostContext.mounted) return;
            ScaffoldMessenger.of(hostContext).showSnackBar(
              const SnackBar(
                content: Text(
                  'Add services for at least one subcategory before proceeding.',
                ),
              ),
            );
            return;
          }

          if (effectiveSelection.isNotEmpty) {
            await _registerSubCategories(
                mainCategory,
                effectiveSelection
                    .map(
                      (s) => SubCategoryEntity(
                        id: int.tryParse(s.id) ?? 0,
                        name: s.title,
                        iconUrl: s.iconUrl ?? '',
                      ),
                    )
                    .toList());
          }
          if (!hostContext.mounted) return;
          await _proceedToPlans(hostContext);
          return;
        }

        if (effectiveSelection.isEmpty) {
          if (!hostContext.mounted) return;
          ScaffoldMessenger.of(hostContext).showSnackBar(
            const SnackBar(
              content: Text(
                'Add services for at least one subcategory before proceeding.',
              ),
            ),
          );
          return;
        }

        final entities = effectiveSelection
            .map(
              (s) => SubCategoryEntity(
                id: int.tryParse(s.id) ?? 0,
                name: s.title,
                iconUrl: s.iconUrl ?? '',
              ),
            )
            .toList();

        await _registerSubCategories(mainCategory, entities);
        if (!hostContext.mounted) return;

        hostContext.read<ManageCatalogBloc>().add(const LoadVendorCatalog());
        ScaffoldMessenger.of(hostContext).showSnackBar(
          const SnackBar(
            content: Text('Categories and services updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      },
    );
  }

  Future<bool> _registerSubCategories(
    MainCategory mainCategory,
    List<SubCategoryEntity> subCategories,
  ) async {
    if (subCategories.isEmpty) return true;

    final repo = di.sl<VendorCatalogRepository>();
    final result = await repo.addCategories(
      mainCategoryId: mainCategory.id,
      subCategoryIds: subCategories.map((s) => s.id).toList(),
    );

    if (result.isLeft()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.fold((f) => f.message, (_) => 'Failed')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return false;
    }
    return true;
  }

  Future<void> _openSelectService(
    MainCategory mainCategory,
    List<SubCategoryEntity> subCategories,
  ) async {
    if (!mounted) return;
    final hostContext = context;

    final added = await hostContext.push<bool>(
      AppRoutes.selectService,
      extra: {
        'mainCategory': mainCategory,
        'selectedSubCategories': subCategories,
      },
    );

    if (added != true || !hostContext.mounted) return;

    if (_goToPlansOnProceed) {
      if (subCategories.isNotEmpty) {
        await _registerSubCategories(mainCategory, subCategories);
      }
      if (!hostContext.mounted) return;
      await _proceedToPlans(hostContext);
    } else {
      if (subCategories.isNotEmpty) {
        await _registerSubCategories(mainCategory, subCategories);
      }
      if (!hostContext.mounted) return;
      hostContext.read<ManageCatalogBloc>().add(const LoadVendorCatalog());
      ScaffoldMessenger.of(hostContext).showSnackBar(
        const SnackBar(
          content: Text('Services added successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _proceedToPlans(BuildContext navContext) async {
    if (!navContext.mounted) return;

    final repo = di.sl<VendorCatalogRepository>();
    try {
      await repo.proceedToPayment();
    } catch (_) {}

    if (!navContext.mounted) return;

    navContext.push(
      AppRoutes.vendorAvailability,
      extra: {'navigateToSubscriptionOnSave': true},
    );
  }

  Future<void> _confirmDeleteSubCategory(
    VendorCatalogSubCategoryModel sub,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove subcategory?'),
        content: Text(
          'Remove "${sub.subCategoryName}" and deactivate its services?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<ManageCatalogBloc>().add(
            RemoveSubCategoryEvent(sub.subCategoryId),
          );
    }
  }

  Future<void> _confirmDeleteService(VendorCatalogServiceModel service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove service?'),
        content: Text('Remove "${service.title}" from your catalog?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<ManageCatalogBloc>().add(
            DeleteServiceEvent(service.id),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<ManageCatalogBloc, ManageCatalogState>(
      listener: (context, state) {
        if (state is ManageCatalogError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
            ),
          );
          if (state.catalog != null) {
            context.read<ManageCatalogBloc>().add(const LoadVendorCatalog());
          }
        }
      },
      builder: (context, state) {
        final rawCatalog = switch (state) {
          ManageCatalogLoaded(:final catalog) => catalog,
          ManageCatalogActionInProgress(:final catalog) => catalog,
          ManageCatalogError(:final catalog) => catalog,
          _ => null,
        };
        final catalog = _canViewCatalog ? rawCatalog : null;
        final isLoading = state is ManageCatalogLoading;
        final isBusy = state is ManageCatalogActionInProgress;

        return Scaffold(
          backgroundColor:
              isDark ? AppColors.darkBackground : const Color(0xFFF7FBFF),
          appBar: AppBar(
            title: Text(
              'Category Management',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: isDark ? Colors.white : AppColors.primary,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: isBusy || _addingCategory || !_subscriptionLoaded
                ? null
                : _openAddCategoryFlow,
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text(
              'Add Category',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : catalog == null || catalog.categories.isEmpty
                  ? _buildEmptyState(isDark)
                  : Stack(
                      children: [
                        RefreshIndicator(
                          onRefresh: () async {
                            await _loadSubscriptionStatus();
                            if (!context.mounted) return;
                            context
                                .read<ManageCatalogBloc>()
                                .add(const LoadVendorCatalog());
                            await Future.delayed(
                              const Duration(milliseconds: 400),
                            );
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                            itemCount: catalog.categories.length,
                            itemBuilder: (context, index) {
                              return _CategorySection(
                                category: catalog.categories[index],
                                isDark: isDark,
                                onDeleteSubCategory: _confirmDeleteSubCategory,
                                onDeleteService: _confirmDeleteService,
                                onEditService: (service) async {
                                  final bloc =
                                      context.read<ManageCatalogBloc>();
                                  await showServiceEditSheet(
                                    context,
                                    service: service,
                                    onSave: ({
                                      required price,
                                      required description,
                                      required negotiable,
                                      required media,
                                    }) async {
                                      bloc.add(
                                        UpdateServiceEvent(
                                          vendorServiceId: service.id,
                                          price: price,
                                          description: description,
                                          negotiable: negotiable,
                                          media: media,
                                        ),
                                      );
                                      final resultState =
                                          await bloc.stream.firstWhere(
                                        (s) =>
                                            s is ManageCatalogLoaded ||
                                            s is ManageCatalogError,
                                      );
                                      return resultState is! ManageCatalogError;
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        if (isBusy)
                          const Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: LinearProgressIndicator(minHeight: 2),
                          ),
                      ],
                    ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'No categories yet',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _goToPlansOnProceed
                  ? 'Add categories and services, then tap PROCEED on the subcategory screen to choose a plan.'
                  : 'Add a category, pick subcategories, and add your services.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _openAddCategoryFlow,
              icon: const Icon(Icons.add),
              label: const Text('Add Category'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final VendorCatalogMainCategoryModel category;
  final bool isDark;
  final void Function(VendorCatalogSubCategoryModel) onDeleteSubCategory;
  final void Function(VendorCatalogServiceModel) onDeleteService;
  final Future<void> Function(VendorCatalogServiceModel) onEditService;

  const _CategorySection({
    required this.category,
    required this.isDark,
    required this.onDeleteSubCategory,
    required this.onDeleteService,
    required this.onEditService,
  });

  @override
  Widget build(BuildContext context) {
    final visibleSubCategories = category.subCategories
        .where((sub) => sub.activeServices.isNotEmpty)
        .toList();

    if (visibleSubCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(
          category.mainCategoryName,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '${visibleSubCategories.length} subcategories',
          style: GoogleFonts.outfit(
            fontSize: 12,
            color:
                isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        children: visibleSubCategories.map((sub) {
          return _SubCategoryBlock(
            sub: sub,
            isDark: isDark,
            onDeleteSubCategory: () => onDeleteSubCategory(sub),
            onDeleteService: onDeleteService,
            onEditService: onEditService,
          );
        }).toList(),
      ),
    );
  }
}

class _SubCategoryBlock extends StatelessWidget {
  final VendorCatalogSubCategoryModel sub;
  final bool isDark;
  final VoidCallback onDeleteSubCategory;
  final void Function(VendorCatalogServiceModel) onDeleteService;
  final Future<void> Function(VendorCatalogServiceModel) onEditService;

  const _SubCategoryBlock({
    required this.sub,
    required this.isDark,
    required this.onDeleteSubCategory,
    required this.onDeleteService,
    required this.onEditService,
  });

  @override
  Widget build(BuildContext context) {
    final services = sub.activeServices;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  sub.subCategoryName,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Remove subcategory',
                onPressed: onDeleteSubCategory,
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent.withValues(alpha: 0.85),
                  size: 20,
                ),
              ),
            ],
          ),
          if (services.isEmpty)
            const SizedBox.shrink()
          else
            ...services.map(
              (service) => _ServiceTile(
                service: service,
                isDark: isDark,
                onEdit: () => onEditService(service),
                onDelete: () => onDeleteService(service),
              ),
            ),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final VendorCatalogServiceModel service;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ServiceTile({
    required this.service,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5)
            : AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          if (service.imageUrl != null && service.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AppNetworkImage(
                imageUrl: service.imageUrl!,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                placeholder: Container(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.home_repair_service_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
              ),
            )
          else
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.home_repair_service_outlined,
                  color: AppColors.primary, size: 22),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  '₹${service.price.toStringAsFixed(0)}${service.negotiable ? ' · Negotiable' : ''}',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: AppColors.primary,
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 20),
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }
}
