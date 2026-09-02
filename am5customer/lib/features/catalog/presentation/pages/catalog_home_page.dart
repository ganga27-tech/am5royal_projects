import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5_ui/am5_ui.dart';

import '../../../../core/customer_brand.dart';
import '../../../../core/design_system/am5_colors.dart';
import '../../../address/presentation/cubit/address_cubit.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../comms/presentation/cubit/notifications_cubit.dart';
import '../cubit/home_catalog_cubit.dart';

/// Customer home — discovery-first layout matching LIVORA design language.
/// Data via [HomeCatalogCubit]; navigation destinations unchanged.
class CatalogHomePage extends StatelessWidget {
  const CatalogHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddressCubit(context.read<AddressApi>())..load(),
      child: const _CatalogHomeView(),
    );
  }
}

class _CatalogHomeView extends StatelessWidget {
  const _CatalogHomeView();

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    final user = context.watch<AuthBloc>().state.user;
    final theme = Theme.of(context);

    return BlocBuilder<HomeCatalogCubit, HomeCatalogState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: theme.colorScheme.primary,
              onRefresh: () async {
                await Future.wait([
                  context.read<HomeCatalogCubit>().load(),
                  context.read<AddressCubit>().load(),
                  context.read<NotificationsCubit>().load(),
                ]);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _HomeHeader(strings: s)),
                  ..._sliverBody(context, state, s, user?.fullName),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _sliverBody(
    BuildContext context,
    HomeCatalogState state,
    LivoraStrings s,
    String? name,
  ) {
    if (state.status == HomeCatalogStatus.loading ||
        state.status == HomeCatalogStatus.initial) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: LivoraLoading(message: s.loading),
        ),
      ];
    }

    if (state.status == HomeCatalogStatus.error) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(LivoraSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 40,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: LivoraSpacing.md),
                Text(
                  state.message ?? s.offlineHint,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: LivoraSpacing.lg),
                LivoraButton(
                  label: s.retry,
                  onPressed: () => context.read<HomeCatalogCubit>().load(),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    final greetingName =
        (name != null && name.isNotEmpty) ? name : s.navProfile;

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            LivoraSpacing.lg,
            LivoraSpacing.sm,
            LivoraSpacing.lg,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${s.homeGreeting}, $greetingName 👋',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: LivoraSpacing.xs),
              Text(
                s.homePrompt,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: LivoraSpacing.lg),
              _SearchEntry(
                hint: s.searchHint,
                filterTooltip: s.filters,
                onSearch: () => context.go('/search'),
                onFilter: () => context.go('/search'),
              ),
            ],
          ),
        ),
      ),

      if (state.categories.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: LivoraSpacing.md),
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: LivoraSpacing.lg),
                scrollDirection: Axis.horizontal,
                itemCount: state.categories.take(4).length + 1,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final take = state.categories.take(4).toList();
                  if (index == take.length) {
                    return _QuickChip(
                      icon: Icons.apps_rounded,
                      label: s.viewAll,
                      onTap: () => _showAllCategories(context, state.categories, s),
                    );
                  }
                  final cat = take[index];
                  return _QuickChip(
                    icon: _categoryIcon(cat.slug),
                    label: cat.name,
                    onTap: () => context.push('/categories/${cat.id}'),
                  );
                },
              ),
            ),
          ),
        ),

      if (state.banners.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: LivoraSpacing.xl),
            child: _HeroCarousel(
              banners: state.banners,
              eyebrow: s.heroEyebrow,
              fallbackCta: s.bookService,
            ),
          ),
        ),

      SliverToBoxAdapter(
        child: _SectionHeader(
          title: s.categories,
          actionLabel: state.categories.isNotEmpty ? s.viewAll : null,
          onAction: state.categories.isNotEmpty
              ? () => _showAllCategories(context, state.categories, s)
              : null,
          padding: const EdgeInsets.fromLTRB(
            LivoraSpacing.lg,
            LivoraSpacing.xl,
            LivoraSpacing.lg,
            LivoraSpacing.md,
          ),
        ),
      ),
      if (state.categories.isEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: LivoraSpacing.lg),
            child: Text(s.catalogEmpty),
          ),
        )
      else
        SliverToBoxAdapter(
          child: SizedBox(
            height: 132,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: LivoraSpacing.lg),
              scrollDirection: Axis.horizontal,
              itemCount: state.categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final cat = state.categories[index];
                return _CategoryCard(
                  category: cat,
                  subtitle: cat.description?.isNotEmpty == true
                      ? cat.description!
                      : s.exploreCategory,
                  onTap: () => context.push('/categories/${cat.id}'),
                );
              },
            ),
          ),
        ),

      SliverToBoxAdapter(
        child: _SectionHeader(
          title: s.featuredServices,
          actionLabel: state.featured.isNotEmpty ? s.viewAll : null,
          onAction: state.featured.isNotEmpty ? () => context.go('/search') : null,
          padding: const EdgeInsets.fromLTRB(
            LivoraSpacing.lg,
            LivoraSpacing.xl,
            LivoraSpacing.lg,
            LivoraSpacing.md,
          ),
        ),
      ),
      if (state.featured.isEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: LivoraSpacing.lg),
            child: Text(s.catalogEmpty),
          ),
        )
      else
        SliverToBoxAdapter(
          child: SizedBox(
            height: 248,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: LivoraSpacing.lg),
              scrollDirection: Axis.horizontal,
              itemCount: state.featured.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final svc = state.featured[index];
                return _ServiceCard(
                  service: svc,
                  minutesLabel: s.minutes,
                  fromLabel: s.fromPrice,
                  badgeLabel: svc.isFeatured ? s.badgeBestseller : null,
                  badgeGold: true,
                  onTap: () => context.push('/services/${svc.id}'),
                );
              },
            ),
          ),
        ),

      if (state.trending.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: _SectionHeader(
            title: s.trendingServices,
            padding: const EdgeInsets.fromLTRB(
              LivoraSpacing.lg,
              LivoraSpacing.xl,
              LivoraSpacing.lg,
              LivoraSpacing.md,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 248,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: LivoraSpacing.lg),
              scrollDirection: Axis.horizontal,
              itemCount: state.trending.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final svc = state.trending[index];
                return _ServiceCard(
                  service: svc,
                  minutesLabel: s.minutes,
                  fromLabel: s.fromPrice,
                  badgeLabel: index == 0 ? s.badgeTopRated : null,
                  badgeGold: false,
                  onTap: () => context.push('/services/${svc.id}'),
                );
              },
            ),
          ),
        ),
      ],

      if (state.recentlyViewed.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: _SectionHeader(
            title: s.recentlyViewed,
            padding: const EdgeInsets.fromLTRB(
              LivoraSpacing.lg,
              LivoraSpacing.xl,
              LivoraSpacing.lg,
              LivoraSpacing.md,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 96,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: LivoraSpacing.lg),
              scrollDirection: Axis.horizontal,
              itemCount: state.recentlyViewed.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final svc = state.recentlyViewed[index];
                return _RecentServiceChip(
                  service: svc,
                  onTap: () => context.push('/services/${svc.id}'),
                );
              },
            ),
          ),
        ),
      ],

      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            LivoraSpacing.lg,
            LivoraSpacing.xl,
            LivoraSpacing.lg,
            LivoraSpacing.xxl,
          ),
          child: _TrustStrip(
            verified: s.trustVerifiedPros,
            secure: s.trustSecurePayments,
            guarantee: s.trustServiceGuarantee,
          ),
        ),
      ),
    ];
  }

  void _showAllCategories(
    BuildContext context,
    List<CatalogCategory> categories,
    LivoraStrings s,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return ListTile(
                leading: Icon(_categoryIcon(cat.slug), color: Theme.of(context).colorScheme.primary),
                title: Text(cat.name),
                subtitle: cat.description != null ? Text(cat.description!) : null,
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/categories/${cat.id}');
                },
              );
            },
          ),
        );
      },
    );
  }
}

IconData _categoryIcon(String slug) {
  final s = slug.toLowerCase();
  if (s.contains('clean')) return Icons.cleaning_services_outlined;
  if (s.contains('ac') || s.contains('appliance')) return Icons.ac_unit_outlined;
  if (s.contains('plumb')) return Icons.plumbing_outlined;
  if (s.contains('beauty') || s.contains('salon')) return Icons.spa_outlined;
  if (s.contains('electric')) return Icons.electrical_services_outlined;
  if (s.contains('pest')) return Icons.bug_report_outlined;
  if (s.contains('paint')) return Icons.format_paint_outlined;
  if (s.contains('bath')) return Icons.bathtub_outlined;
  return Icons.home_repair_service_outlined;
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.strings});

  final LivoraStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        LivoraSpacing.lg,
        LivoraSpacing.sm,
        LivoraSpacing.md,
        LivoraSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: BlocBuilder<AddressCubit, AddressViewState>(
              builder: (context, addressState) {
                final addr = addressState.addresses
                    .where((a) => a.isDefault)
                    .firstOrNull ??
                    addressState.addresses.firstOrNull;
                final label = addr != null
                    ? '${addr.landmark?.isNotEmpty == true ? addr.landmark! : addr.line1.split(',').first}, ${addr.city}'
                    : strings.homeLocationFallback;

                return InkWell(
                  onTap: () => context.push('/profile/addresses'),
                  borderRadius: BorderRadius.circular(LivoraSpacing.radii.md),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            tooltip: strings.professionals,
            onPressed: () => context.push('/professionals'),
            icon: const Icon(Icons.favorite_border_rounded),
          ),
          _NotificationBell(tooltip: strings.notifications),
          IconButton(
            tooltip: strings.profile,
            onPressed: () => context.go('/profile'),
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
              child: Icon(
                Icons.person_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.tooltip});

  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsViewState>(
      builder: (context, state) {
        final unread = state.items.where((n) => n.isUnread).length;
        return IconButton(
          tooltip: tooltip,
          onPressed: () => context.push('/notifications'),
          icon: Badge(
            isLabelVisible: unread > 0,
            label: Text(unread > 9 ? '9+' : '$unread'),
            child: const Icon(Icons.notifications_none_rounded),
          ),
        );
      },
    );
  }
}

class _SearchEntry extends StatelessWidget {
  const _SearchEntry({
    required this.hint,
    required this.filterTooltip,
    required this.onSearch,
    required this.onFilter,
  });

  final String hint;
  final String filterTooltip;
  final VoidCallback onSearch;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LivoraSpacing.radii.xl),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onSearch,
        borderRadius: BorderRadius.circular(LivoraSpacing.radii.xl),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hint,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Tooltip(
                message: filterTooltip,
                child: Material(
                  color: theme.colorScheme.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onFilter,
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.tune_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LivoraSpacing.radii.full),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LivoraSpacing.radii.full),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              if (label.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(label, style: theme.textTheme.labelLarge),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    this.padding = EdgeInsets.zero,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

class _HeroCarousel extends StatefulWidget {
  const _HeroCarousel({
    required this.banners,
    required this.eyebrow,
    required this.fallbackCta,
  });

  final List<CatalogBanner> banners;
  final String eyebrow;
  final String fallbackCta;

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  late final PageController _controller;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 196,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _HeroBanner(
                banner: widget.banners[index],
                eyebrow: widget.eyebrow,
                fallbackCta: widget.fallbackCta,
              ),
            ),
          ),
        ),
        if (widget.banners.length > 1) ...[
          const SizedBox(height: LivoraSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.banners.length, (i) {
              final active = i == _page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active
                      ? Theme.of(context).colorScheme.primary
                      : Am5Colors.outline,
                  borderRadius: BorderRadius.circular(LivoraSpacing.radii.full),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.banner,
    required this.eyebrow,
    required this.fallbackCta,
  });

  final CatalogBanner banner;
  final String eyebrow;
  final String fallbackCta;

  void _onCta(BuildContext context) {
    final link = banner.ctaDeepLink;
    if (link != null && link.startsWith('/')) {
      context.push(link);
      return;
    }
    context.go('/search');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(LivoraSpacing.radii.xl),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: Theme.of(context).colorScheme.primary),
          Align(
            alignment: Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.55,
              child: Image.network(
                banner.imageUrl,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.92),
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.35, 0.65, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(LivoraSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: CustomerBrand.badgeFg(context),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  banner.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                if (banner.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    banner.subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
                const Spacer(),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: CustomerBrand.badgeFg(context),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(LivoraSpacing.radii.full),
                    ),
                  ),
                  onPressed: () => _onCta(context),
                  child: Text(banner.ctaLabel ?? fallbackCta),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.subtitle,
    required this.onTap,
  });

  final CatalogCategory category;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(LivoraSpacing.radii.lg),
      child: Ink(
        width: 118,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(LivoraSpacing.radii.lg),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (category.iconUrl != null)
              Image.network(
                category.iconUrl!,
                width: 28,
                height: 28,
                errorBuilder: (_, _, _) => Icon(
                  _categoryIcon(category.slug),
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              )
            else
              Icon(
                _categoryIcon(category.slug),
                color: theme.colorScheme.primary,
                size: 28,
              ),
            const Spacer(),
            Text(
              category.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.service,
    required this.minutesLabel,
    required this.fromLabel,
    required this.onTap,
    this.badgeLabel,
    this.badgeGold = false,
  });

  final CatalogServiceItem service;
  final String minutesLabel;
  final String fromLabel;
  final String? badgeLabel;
  final bool badgeGold;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 220,
      child: Material(
        color: theme.colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LivoraSpacing.radii.lg),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 132,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (service.imageUrl != null)
                      Image.network(
                        service.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => ColoredBox(
                          color: Am5Colors.background,
                          child: Icon(
                            Icons.home_repair_service_outlined,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      )
                    else
                      ColoredBox(
                        color: Am5Colors.background,
                        child: Icon(
                          Icons.home_repair_service_outlined,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    if (badgeLabel != null)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: badgeGold
                                ? CustomerBrand.badgeBg(context)
                                : Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(
                              LivoraSpacing.radii.full,
                            ),
                          ),
                          child: Text(
                            badgeLabel!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: badgeGold
                                  ? CustomerBrand.badgeFg(context)
                                  : Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      const Spacer(),
                      Text(
                        '$fromLabel ${service.priceLabel}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        '${service.durationMinutes} $minutesLabel',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentServiceChip extends StatelessWidget {
  const _RecentServiceChip({required this.service, required this.onTap});

  final CatalogServiceItem service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LivoraSpacing.radii.md),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 220,
          child: Row(
            children: [
              SizedBox(
                width: 72,
                height: 96,
                child: service.imageUrl != null
                    ? Image.network(
                        service.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => ColoredBox(
                          color: Am5Colors.background,
                          child: Icon(
                            Icons.home_repair_service_outlined,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      )
                    : ColoredBox(
                        color: Am5Colors.background,
                        child: Icon(
                          Icons.home_repair_service_outlined,
                          color: theme.colorScheme.primary,
                        ),
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        service.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.priceLabel,
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
      ),
    );
  }
}

class _TrustStrip extends StatelessWidget {
  const _TrustStrip({
    required this.verified,
    required this.secure,
    required this.guarantee,
  });

  final String verified;
  final String secure;
  final String guarantee;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: LivoraSpacing.md, horizontal: 8),
      decoration: BoxDecoration(
        color: Am5Colors.background,
        borderRadius: BorderRadius.circular(LivoraSpacing.radii.lg),
      ),
      child: Row(
        children: [
          _TrustItem(icon: Icons.verified_outlined, label: verified),
          _TrustItem(icon: Icons.lock_outline, label: secure),
          _TrustItem(icon: Icons.handshake_outlined, label: guarantee),
        ],
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  const _TrustItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 22, color: theme.colorScheme.primary),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
