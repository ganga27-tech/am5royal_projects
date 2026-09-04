import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5_ui/am5_ui.dart';

import '../../../../core/booking_routes.dart';
import '../../../../core/customer_brand.dart';
import '../../../../core/design_system/am5_colors.dart';
import '../../../../core/design_system/am5_spacing.dart';
import '../../../../shared/widgets/service_widgets.dart';
import '../models/vendor_catalog_groups.dart';
import '../widgets/vendor_category_menu.dart';

class VendorDetailPage extends StatefulWidget {
  const VendorDetailPage({super.key, required this.vendorId});

  final String vendorId;

  @override
  State<VendorDetailPage> createState() => _VendorDetailPageState();
}

class _VendorDetailPageState extends State<VendorDetailPage> {
  late Future<_VendorPageData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_VendorPageData> _load() async {
    final catalogApi = context.read<CatalogApi>();
    final professionalsApi = context.read<ProfessionalsApi>();

    final results = await Future.wait([
      professionalsApi.getProfessional(widget.vendorId),
      catalogApi.listVendorServices(widget.vendorId),
      catalogApi.listCategories(),
    ]);

    final services = results[1] as List<VendorServiceOffering>;
    final categories = results[2] as List<CatalogCategory>;

    return _VendorPageData(
      vendor: results[0] as Professional,
      services: services,
      catalog: VendorCatalogIndex.fromServices(
        services: services,
        catalogCategories: categories,
      ),
    );
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);

    return FutureBuilder<_VendorPageData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            backgroundColor: Am5Colors.background,
            appBar: AppBar(title: const Text('Vendor')),
            body: LivoraLoading(message: s.loading),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            backgroundColor: Am5Colors.background,
            appBar: AppBar(title: const Text('Vendor')),
            body: Padding(
              padding: const EdgeInsets.all(Am5Spacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    snapshot.error is Failure
                        ? (snapshot.error! as Failure).message
                        : s.offlineHint,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Am5Spacing.lg),
                  LivoraButton(label: s.retry, onPressed: _reload),
                ],
              ),
            ),
          );
        }

        return _VendorDetailBody(
          data: snapshot.data!,
          onRefresh: () async {
            final next = _load();
            setState(() => _future = next);
            await next;
          },
        );
      },
    );
  }
}

class _VendorPageData {
  const _VendorPageData({
    required this.vendor,
    required this.services,
    required this.catalog,
  });

  final Professional vendor;
  final List<VendorServiceOffering> services;
  final VendorCatalogIndex catalog;
}

class _VendorDetailBody extends StatefulWidget {
  const _VendorDetailBody({required this.data, required this.onRefresh});

  final _VendorPageData data;
  final Future<void> Function() onRefresh;

  @override
  State<_VendorDetailBody> createState() => _VendorDetailBodyState();
}

class _VendorDetailBodyState extends State<_VendorDetailBody> {
  String? _selectedMainCategoryId;
  String? _selectedSubCategoryId;
  final _scrollController = ScrollController();

  VendorCatalogIndex get _catalog => widget.data.catalog;
  List<VendorMainCategoryGroup> get _mainCategories => _catalog.mainCategories;

  VendorMainCategoryGroup? get _selectedMain =>
      _catalog.categoryById(_selectedMainCategoryId);

  List<VendorSubcategoryGroup> get _subcategories =>
      _selectedMain?.subcategories ?? const [];

  bool get _showSubcategoryStrip => _subcategories.length > 1;

  bool get _showCategoryFab => _mainCategories.length > 1;

  double get _servicesHeaderHeight => _showSubcategoryStrip ? 80 : 52;

  @override
  void initState() {
    super.initState();
    _initSelection();
  }

  void _initSelection() {
    if (_mainCategories.isEmpty) return;
    _selectedMainCategoryId = _mainCategories.first.id;
    _syncSubcategorySelection();
  }

  void _syncSubcategorySelection() {
    final subs = _subcategories;
    if (subs.isEmpty) {
      _selectedSubCategoryId = null;
      return;
    }
    if (subs.length == 1) {
      _selectedSubCategoryId = subs.first.id;
      return;
    }
    final stillValid = subs.any((s) => s.id == _selectedSubCategoryId);
    _selectedSubCategoryId = stillValid ? _selectedSubCategoryId : subs.first.id;
  }

  void _selectMainCategory(VendorMainCategoryGroup category) {
    setState(() {
      _selectedMainCategoryId = category.id;
      _syncSubcategorySelection();
    });
    _scrollToServices();
  }

  void _selectSubcategory(String id) {
    if (_selectedSubCategoryId == id) return;
    setState(() => _selectedSubCategoryId = id);
  }

  void _scrollToServices() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      160,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  List<VendorServiceOffering> get _visibleServices {
    final main = _selectedMain;
    if (main == null) return const [];

    if (_showSubcategoryStrip) {
      final subId = _selectedSubCategoryId;
      if (subId == null) return const [];
      return _subcategories
          .where((s) => s.id == subId)
          .expand((s) => s.services)
          .toList();
    }

    return main.allServices;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vendor = widget.data.vendor;
    final visibleServices = _visibleServices;
    final selectedMain = _selectedMain;

    return Scaffold(
      backgroundColor: Am5Colors.background,
      body: Stack(
        children: [
          RefreshIndicator(
            color: theme.colorScheme.primary,
            onRefresh: widget.onRefresh,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  elevation: 0,
                  scrolledUnderElevation: 1,
                  backgroundColor: Am5Colors.background,
                  surfaceTintColor: Colors.transparent,
                  title: Text(
                    vendor.displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Am5Colors.textPrimary,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Am5Spacing.lg,
                      Am5Spacing.xs,
                      Am5Spacing.lg,
                      Am5Spacing.sm,
                    ),
                    child: _VendorHero(vendor: vendor),
                  ),
                ),
                if (_mainCategories.isNotEmpty)
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _ServicesHeaderDelegate(
                      mainCategoryName: selectedMain?.name,
                      subcategories: _showSubcategoryStrip ? _subcategories : const [],
                      selectedSubId: _selectedSubCategoryId,
                      onSubcategorySelected: _selectSubcategory,
                      height: _servicesHeaderHeight,
                    ),
                  ),
                if (_mainCategories.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(Am5Spacing.xl),
                        child: Text(
                          'No services listed yet.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  )
                else if (visibleServices.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'No services in this category.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      Am5Spacing.lg,
                      Am5Spacing.xs,
                      Am5Spacing.lg,
                      _showCategoryFab ? 96 : Am5Spacing.xxl,
                    ),
                    sliver: SliverList.separated(
                      itemCount: visibleServices.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: Am5Spacing.sm),
                      itemBuilder: (context, i) {
                        final service = visibleServices[i];
                        return _VendorServiceTile(
                          service: service,
                          onBook: () => openVendorServiceBooking(
                            context,
                            vendorId: vendor.id,
                            vendorName: vendor.displayName,
                            service: service,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          if (_showCategoryFab)
            Positioned.fill(
              child: VendorCategoryFab(
                categories: _mainCategories,
                selectedId: _selectedMainCategoryId,
                onSelected: _selectMainCategory,
              ),
            ),
        ],
      ),
    );
  }
}

class _ServicesHeaderDelegate extends SliverPersistentHeaderDelegate {
  _ServicesHeaderDelegate({
    required this.mainCategoryName,
    required this.subcategories,
    required this.selectedSubId,
    required this.onSubcategorySelected,
    required this.height,
  });

  final String? mainCategoryName;
  final List<VendorSubcategoryGroup> subcategories;
  final String? selectedSubId;
  final ValueChanged<String> onSubcategorySelected;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    final showSubs = subcategories.length > 1;

    return Material(
      color: Am5Colors.background,
      elevation: overlapsContent ? 2 : 0,
      shadowColor: Am5Colors.shadow,
      child: Container(
        decoration: BoxDecoration(
          color: Am5Colors.background,
          border: Border(
            bottom: BorderSide(color: Am5Colors.outline.withValues(alpha: 0.6)),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Am5Spacing.lg),
              child: Row(
                children: [
                  Text(
                    'Services offered',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Am5Colors.textPrimary,
                    ),
                  ),
                  if (mainCategoryName != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.circle,
                        size: 5,
                        color: Am5Colors.textSecondary.withValues(alpha: 0.6),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        mainCategoryName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showSubs)
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: Am5Spacing.lg),
                  itemCount: subcategories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: Am5Spacing.sm),
                  itemBuilder: (context, i) {
                    final sub = subcategories[i];
                    final selected = sub.id == selectedSubId;
                    return _SubcategoryChip(
                      label: sub.name,
                      count: sub.services.length,
                      selected: selected,
                      onTap: () => onSubcategorySelected(sub.id),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _ServicesHeaderDelegate oldDelegate) {
    return oldDelegate.selectedSubId != selectedSubId ||
        oldDelegate.subcategories != subcategories ||
        oldDelegate.mainCategoryName != mainCategoryName ||
        oldDelegate.height != height;
  }
}

class _SubcategoryChip extends StatelessWidget {
  const _SubcategoryChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Am5Spacing.radiusFull),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(Am5Spacing.radiusFull),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : Am5Colors.outline,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: selected ? Colors.white : Am5Colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.2)
                    : Am5Colors.lightRed,
                borderRadius: BorderRadius.circular(Am5Spacing.radiusFull),
              ),
              child: Text(
                '$count',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: selected ? Colors.white : theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VendorHero extends StatelessWidget {
  const _VendorHero({required this.vendor});

  final Professional vendor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: Am5Spacing.lg,
        vertical: Am5Spacing.md,
      ),
      decoration: CustomerBrand.heroCard(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            backgroundImage:
                vendor.hasAvatar ? NetworkImage(vendor.avatarUrl!) : null,
            child: !vendor.hasAvatar
                ? Text(
                    vendor.displayName.isNotEmpty
                        ? vendor.displayName.substring(0, 1).toUpperCase()
                        : 'V',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: Am5Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        vendor.displayName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (vendor.isVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified, color: Colors.white, size: 20),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                RatingWidget(
                  rating: vendor.ratingAvg,
                  reviewCount:
                      vendor.ratingCount > 0 ? vendor.ratingCount : null,
                ),
                const SizedBox(height: 4),
                Text(
                  '${vendor.city ?? 'Hyderabad'} · ${vendor.yearsExperience} yrs exp · ${vendor.jobsCompleted} jobs',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
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

class _VendorServiceTile extends StatelessWidget {
  const _VendorServiceTile({required this.service, required this.onBook});

  final VendorServiceOffering service;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = service.imageUrl;

    return Container(
      padding: const EdgeInsets.all(Am5Spacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(Am5Spacing.radiusLg),
        border: Border.all(color: Am5Colors.outline.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Am5Colors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl != null && imageUrl.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(Am5Spacing.radiusMd),
              child: Image.network(
                imageUrl,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _servicePlaceholder(theme),
              ),
            ),
            const SizedBox(width: Am5Spacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (service.description != null &&
                    service.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    service.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      service.priceLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (service.negotiable) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Am5Colors.lightRed,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Negotiable',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: Am5Spacing.sm),
          FilledButton(
            onPressed: onBook,
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            child: const Text('Book'),
          ),
        ],
      ),
    );
  }

  Widget _servicePlaceholder(ThemeData theme) {
    return Container(
      width: 72,
      height: 72,
      color: Am5Colors.lightRed,
      child: Icon(
        Icons.home_repair_service_rounded,
        color: theme.colorScheme.primary,
      ),
    );
  }
}
