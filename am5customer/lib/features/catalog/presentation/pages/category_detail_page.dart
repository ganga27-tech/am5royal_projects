import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5_ui/am5_ui.dart';

import '../../../../core/customer_brand.dart';
import '../../../../core/design_system/am5_colors.dart';
import '../../../../shared/widgets/service_widgets.dart';
import '../../../../shared/widgets/vendor_card.dart';

class CategoryDetailPage extends StatefulWidget {
  const CategoryDetailPage({super.key, required this.categoryId});

  final String categoryId;

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  late Future<_CategoryPageData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_CategoryPageData> _load() async {
    final api = context.read<CatalogApi>();
    final proApi = context.read<ProfessionalsApi>();

    final results = await Future.wait([
      api.listServices(categoryId: widget.categoryId),
      api.listCategories(),
      proApi.listProfessionals(categoryId: widget.categoryId),
    ]);
    final services = results[0] as List<CatalogServiceItem>;
    final categories = results[1] as List<CatalogCategory>;
    final vendors = results[2] as List<Professional>;
    final category = categories
        .where((c) => c.id == widget.categoryId)
        .firstOrNull;
    return _CategoryPageData(
      category: category,
      services: services,
      vendors: vendors,
    );
  }

  void _reload() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    final theme = Theme.of(context);

    return FutureBuilder<_CategoryPageData>(
      future: _future,
      builder: (context, snapshot) {
        final category = snapshot.data?.category;
        final title = category?.name ?? s.categories;

        return Scaffold(
          backgroundColor: Am5Colors.background,
          appBar: AppBar(
            title: Text(title),
            backgroundColor: Am5Colors.background,
            surfaceTintColor: Colors.transparent,
          ),
          body: _buildBody(context, snapshot, s, theme, category),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncSnapshot<_CategoryPageData> snapshot,
    LivoraStrings s,
    ThemeData theme,
    CatalogCategory? category,
  ) {
    if (snapshot.connectionState != ConnectionState.done) {
      return LivoraLoading(message: s.loading);
    }

    if (snapshot.hasError) {
      return Padding(
        padding: const EdgeInsets.all(LivoraSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: LivoraSpacing.md),
            Text(
              snapshot.error is Failure
                  ? (snapshot.error! as Failure).message
                  : s.offlineHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: LivoraSpacing.lg),
            LivoraButton(label: s.retry, onPressed: _reload),
          ],
        ),
      );
    }

    final data = snapshot.data!;
    final items = data.services;
    final categoryIcon = _categoryIcon(category?.slug ?? '');

    if (items.isEmpty && data.vendors.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/coming_soon_location.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: Am5Colors.lightRed,
                    child: Icon(
                      Icons.location_city_rounded,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Am5Colors.lightRed,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Am5Colors.brandRed.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.near_me_rounded, size: 16, color: Am5Colors.brandRed),
                    const SizedBox(width: 6),
                    Text(
                      'Expanding Soon',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Am5Colors.brandRed,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We are coming soon to your location!',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Am5Colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We are actively onboarding verified professionals in your area for ${category?.name ?? 'this category'}. Stay tuned!',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Explore other categories'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: theme.colorScheme.primary,
      onRefresh: () async {
        final next = _load();
        setState(() => _future = next);
        await next;
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          LivoraSpacing.lg,
          LivoraSpacing.sm,
          LivoraSpacing.lg,
          LivoraSpacing.xxl,
        ),
        children: [
          _CategoryHero(
            category: category,
            serviceCountLabel: data.vendors.isNotEmpty
                ? '${data.vendors.length} Verified Vendors nearby'
                : s.categoryServicesCount.replaceAll('{n}', '${items.length}'),
            icon: categoryIcon,
          ),
          if (data.vendors.isNotEmpty) ...[
            const SizedBox(height: LivoraSpacing.lg),
            Row(
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  size: 18,
                  color: Color(0xFF16A34A),
                ),
                const SizedBox(width: 8),
                Text(
                  'Nearby Verified Providers (${data.vendors.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: LivoraSpacing.md),
            ...data.vendors.map(
              (v) => Padding(
                padding: const EdgeInsets.only(bottom: LivoraSpacing.md),
                child: VendorCard(vendor: v),
              ),
            ),
          ],
          if (items.isNotEmpty) ...[
            const SizedBox(height: LivoraSpacing.lg),
            Row(
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Available Packages (${items.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: LivoraSpacing.md),
            ...items.map(
              (svc) => Padding(
                padding: const EdgeInsets.only(bottom: LivoraSpacing.md),
                child: _ServiceListCard(
                  service: svc,
                  categoryIcon: categoryIcon,
                  fromLabel: s.fromPrice,
                  minutesLabel: s.minutes,
                  featuredLabel: s.badgeBestseller,
                  viewLabel: s.viewDetails,
                  onTap: () => context.push('/services/${svc.id}'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryPageData {
  const _CategoryPageData({
    required this.category,
    required this.services,
    this.vendors = const [],
  });

  final CatalogCategory? category;
  final List<CatalogServiceItem> services;
  final List<Professional> vendors;
}

class _CategoryHero extends StatelessWidget {
  const _CategoryHero({
    required this.category,
    required this.serviceCountLabel,
    required this.icon,
  });

  final CatalogCategory? category;
  final String serviceCountLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = category?.description;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(LivoraSpacing.lg),
      decoration: CustomerBrand.heroCard(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(LivoraSpacing.radii.md),
            ),
            child: category?.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(LivoraSpacing.radii.md),
                    child: Image.network(
                      category!.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          Icon(icon, color: Colors.white),
                    ),
                  )
                : Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: LivoraSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category?.name ?? '',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (description != null && description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                ],
                const SizedBox(height: LivoraSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      LivoraSpacing.radii.full,
                    ),
                  ),
                  child: Text(
                    serviceCountLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
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

class _ServiceListCard extends StatelessWidget {
  const _ServiceListCard({
    required this.service,
    required this.categoryIcon,
    required this.fromLabel,
    required this.minutesLabel,
    required this.featuredLabel,
    required this.viewLabel,
    required this.onTap,
  });

  final CatalogServiceItem service;
  final IconData categoryIcon;
  final String fromLabel;
  final String minutesLabel;
  final String featuredLabel;
  final String viewLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LivoraSpacing.radii.xl),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 148,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (service.imageUrl != null)
                    Image.network(
                      service.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          _imageFallback(theme, categoryIcon),
                    )
                  else
                    _imageFallback(theme, categoryIcon),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.05),
                          Colors.black.withValues(alpha: 0.35),
                        ],
                      ),
                    ),
                  ),
                  if (service.isFeatured)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: CustomerBrand.badgeBg(context),
                          borderRadius: BorderRadius.circular(
                            LivoraSpacing.radii.full,
                          ),
                        ),
                        child: Text(
                          featuredLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: CustomerBrand.badgeFg(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(
                          LivoraSpacing.radii.full,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${service.durationMinutes} $minutesLabel',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (service.shortDescription?.isNotEmpty == true) ...[
                    const SizedBox(height: 6),
                    Text(
                      service.shortDescription!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: LivoraSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(fromLabel, style: theme.textTheme.labelSmall),
                            Text(
                              service.priceLabel,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FilledButton(
                        onPressed: onTap,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: Text(viewLabel),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback(ThemeData theme, IconData icon) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Am5Colors.brandRed, Am5Colors.deepRed],
        ),
      ),
      child: Center(
        child: Icon(icon, size: 44, color: Colors.white.withValues(alpha: 0.9)),
      ),
    );
  }
}

IconData _categoryIcon(String slug) => categoryIconFor(slug);
