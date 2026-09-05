import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../address/presentation/cubit/address_cubit.dart';
import '../../../comms/presentation/cubit/notifications_cubit.dart';
import '../../../catalog/presentation/cubit/home_catalog_cubit.dart';
import '../../../../core/auth/login_guard.dart';
import '../../../../core/booking_routes.dart';
import '../../../../core/design_system/am5_colors.dart';
import '../../../../core/design_system/am5_decorations.dart';
import '../../../../core/design_system/am5_spacing.dart';
import '../../../../core/voice/voice_search_launcher.dart';
import '../../../../shared/widgets/app_primitives.dart';
import '../../../../shared/widgets/search_and_header.dart';
import '../../../../shared/widgets/service_widgets.dart';
import '../../../../shared/widgets/vendor_card.dart';

/// Premium AM5 Royal home — Zomato-inspired discovery feed.
class PremiumHomePage extends StatelessWidget {
  const PremiumHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddressCubit(context.read<AddressApi>())..load(),
      child: const _PremiumHomeView(),
    );
  }
}

class _PremiumHomeView extends StatefulWidget {
  const _PremiumHomeView();

  @override
  State<_PremiumHomeView> createState() => _PremiumHomeViewState();
}

class _PremiumHomeViewState extends State<_PremiumHomeView> {
  int _selectedCategory = 0;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthBloc>().state.user;
    final firstName = (user?.fullName ?? 'there').split(' ').first;

    return BlocBuilder<HomeCatalogCubit, HomeCatalogState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Am5Colors.background,
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
                  SliverToBoxAdapter(
                    child: BlocBuilder<AddressCubit, AddressViewState>(
                      builder: (context, addressState) {
                        final addr = addressState.addresses
                                .where((a) => a.isDefault)
                                .firstOrNull ??
                            addressState.addresses.firstOrNull;
                        final city = addr?.city ?? 'Select location';
                        return BlocBuilder<NotificationsCubit, NotificationsViewState>(
                          builder: (context, notif) {
                            final unread = notif.items.where((n) => n.isUnread).length;
                            return LocationHeader(
                              locationLabel: city,
                              onLocationTap: () => LoginGuard.runProtected(
                                context,
                                () => context.push('/profile/addresses'),
                                message: 'Sign in to manage your addresses.',
                                redirectTo: '/profile/addresses',
                              ),
                              onNotifications: () => LoginGuard.runProtected(
                                context,
                                () => context.push('/notifications'),
                                message: 'Sign in to view notifications.',
                                redirectTo: '/notifications',
                              ),
                              onProfile: () => context.go('/profile'),
                              notificationCount: unread,
                              avatarInitial: user?.fullName,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Am5Spacing.lg,
                        0,
                        Am5Spacing.lg,
                        Am5Spacing.md,
                      ),
                      child: SearchBarWidget(
                        large: true,
                        readOnly: true,
                        hint: 'Search services, vendors, categories…',
                        onTap: () => context.go('/search'),
                        onMicTap: () => VoiceSearchLauncher.openSearch(context),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Am5Spacing.lg),
                      child: Text(
                        '${_greeting()}, $firstName',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  if (state.status == HomeCatalogStatus.loading ||
                      state.status == HomeCatalogStatus.initial)
                    const SliverFillRemaining(child: LoadingSkeleton(lines: 4))
                  else if (state.status == HomeCatalogStatus.error)
                    SliverFillRemaining(
                      child: EmptyState(
                        message: state.message ?? 'Could not load home',
                        onAction: () => context.read<HomeCatalogCubit>().load(),
                        actionLabel: 'Retry',
                      ),
                    )
                  else ...[
                    if (state.categories.isNotEmpty) ...[
                      const SliverToBoxAdapter(child: SizedBox(height: Am5Spacing.lg)),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 108,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: Am5Spacing.lg),
                            itemCount: state.categories.length + 1,
                            separatorBuilder: (_, _) => const SizedBox(width: Am5Spacing.md),
                            itemBuilder: (context, i) {
                              if (i == 0) {
                                return CategoryCard(
                                  label: 'All',
                                  icon: Icons.apps_rounded,
                                  circular: true,
                                  selected: _selectedCategory == 0,
                                  onTap: () => setState(() => _selectedCategory = 0),
                                );
                              }
                              final cat = state.categories[i - 1];
                              return CategoryCard(
                                label: cat.name,
                                icon: categoryIconFor(cat.slug),
                                imageUrl: cat.iconUrl ?? cat.imageUrl,
                                circular: true,
                                selected: _selectedCategory == i,
                                onTap: () {
                                  setState(() => _selectedCategory = i);
                                  context.push('/categories/${cat.id}');
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                    if (state.banners.isNotEmpty) ...[
                      const SliverToBoxAdapter(child: SizedBox(height: Am5Spacing.lg)),
                      SliverToBoxAdapter(child: _PromoBannerCarousel(banners: state.banners)),
                    ],
                    if (state.nearbyVendors.isNotEmpty) ...[
                      const SliverToBoxAdapter(child: SizedBox(height: Am5Spacing.xl)),
                      SliverToBoxAdapter(
                        child: _FeedSectionHeader(
                          count: state.nearbyVendors.length,
                          label: 'VERIFIED VENDORS NEAR YOU',
                          badge: 'Featured',
                          onViewAll: () => context.push('/professionals'),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          Am5Spacing.lg,
                          Am5Spacing.md,
                          Am5Spacing.lg,
                          0,
                        ),
                        sliver: SliverList.separated(
                          itemCount: state.nearbyVendors.take(8).length,
                          separatorBuilder: (_, _) => const SizedBox(height: Am5Spacing.lg),
                          itemBuilder: (context, i) {
                            final vendor = state.nearbyVendors[i];
                            return VendorCard(vendor: vendor, style: VendorCardStyle.feed);
                          },
                        ),
                      ),
                    ],
                    if (state.featured.isNotEmpty || state.trending.isNotEmpty) ...[
                      const SliverToBoxAdapter(child: SizedBox(height: Am5Spacing.xxl)),
                      SliverToBoxAdapter(
                        child: _FeedSectionHeader(
                          count: state.trending.isNotEmpty
                              ? state.trending.length
                              : state.featured.length,
                          label: 'POPULAR SERVICES',
                          badge: 'Trending',
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 268,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.fromLTRB(
                              Am5Spacing.lg,
                              Am5Spacing.md,
                              Am5Spacing.lg,
                              0,
                            ),
                            itemCount: (state.trending.isNotEmpty ? state.trending : state.featured)
                                .take(6)
                                .length,
                            separatorBuilder: (_, _) => const SizedBox(width: Am5Spacing.md),
                            itemBuilder: (context, i) {
                              final services =
                                  state.trending.isNotEmpty ? state.trending : state.featured;
                              final svc = services[i];
                              return SizedBox(
                                width: 240,
                                child: ServiceCard(
                                  service: svc,
                                  badge: svc.isFeatured ? 'Popular' : 'Trending',
                                  onTap: () => context.push('/services/${svc.id}'),
                                  onBook: () => openServiceBooking(context, svc),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                    if (state.recentlyViewed.isNotEmpty) ...[
                      const SliverToBoxAdapter(child: SizedBox(height: Am5Spacing.xxl)),
                      SliverToBoxAdapter(
                        child: SectionHeader(title: 'Recently viewed'),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          Am5Spacing.lg,
                          Am5Spacing.md,
                          Am5Spacing.lg,
                          0,
                        ),
                        sliver: SliverList.separated(
                          itemCount: state.recentlyViewed.take(3).length,
                          separatorBuilder: (_, _) => const SizedBox(height: Am5Spacing.md),
                          itemBuilder: (context, i) {
                            final svc = state.recentlyViewed[i];
                            return ServiceCard(
                              service: svc,
                              compact: true,
                              onTap: () => context.push('/services/${svc.id}'),
                            );
                          },
                        ),
                      ),
                    ],
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          Am5Spacing.lg,
                          Am5Spacing.xxl,
                          Am5Spacing.lg,
                          Am5Spacing.lg,
                        ),
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/shop'),
                          icon: const Icon(Icons.shopping_bag_outlined),
                          label: const Text('Browse service packages'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          Am5Spacing.lg,
                          0,
                          Am5Spacing.lg,
                          Am5Spacing.xxxl,
                        ),
                        child: _TrustStrip(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FeedSectionHeader extends StatelessWidget {
  const _FeedSectionHeader({
    required this.count,
    required this.label,
    this.badge,
    this.onViewAll,
  });

  final int count;
  final String label;
  final String? badge;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Am5Spacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count $label',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Am5Colors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    badge!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              child: const Text('View all'),
            ),
        ],
      ),
    );
  }
}

class _PromoBannerCarousel extends StatefulWidget {
  const _PromoBannerCarousel({required this.banners});

  final List<CatalogBanner> banners;

  @override
  State<_PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<_PromoBannerCarousel> {
  late final PageController _controller;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final banners = widget.banners;

    return Column(
      children: [
        SizedBox(
          height: 148,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _page = i),
            itemCount: banners.length,
            itemBuilder: (context, i) {
              final banner = banners[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: Am5Spacing.lg),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Am5Colors.brandRed, Am5Colors.deepRed],
                    ),
                    borderRadius: BorderRadius.circular(Am5Spacing.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: Am5Colors.brandRed.withValues(alpha: 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (banner.imageUrl.isNotEmpty)
                        Image.network(
                          banner.imageUrl,
                          fit: BoxFit.cover,
                          opacity: const AlwaysStoppedAnimation(0.35),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(Am5Spacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              banner.title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (banner.subtitle != null)
                              Text(
                                banner.subtitle!,
                                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                              ),
                            const Spacer(),
                            FilledButton(
                              onPressed: () => context.go('/search'),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: theme.colorScheme.primary,
                                minimumSize: const Size(0, 40),
                              ),
                              child: Text(banner.ctaLabel ?? 'Book now'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (banners.length > 1) ...[
          const SizedBox(height: Am5Spacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              banners.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _page == i ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _page == i ? Am5Colors.brandRed : Am5Colors.outline,
                  borderRadius: BorderRadius.circular(Am5Spacing.radiusFull),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _TrustStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(Am5Spacing.lg),
      decoration: Am5Decorations.softRedGradient(),
      child: Row(
        children: [
          _trustItem(Icons.verified_user_rounded, 'Verified pros', theme),
          _trustItem(Icons.lock_rounded, 'Secure booking', theme),
          _trustItem(Icons.support_agent_rounded, '24/7 support', theme),
        ],
      ),
    );
  }

  Widget _trustItem(IconData icon, String label, ThemeData theme) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 22),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}
