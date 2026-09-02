import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../address/presentation/cubit/address_cubit.dart';
import '../../../comms/presentation/cubit/notifications_cubit.dart';
import '../../../catalog/presentation/cubit/home_catalog_cubit.dart';
import '../../../../core/booking_routes.dart';
import '../../../../core/design_system/am5_colors.dart';
import '../../../../core/design_system/am5_decorations.dart';
import '../../../../core/design_system/am5_spacing.dart';
import '../../../../shared/widgets/app_primitives.dart';
import '../../../../shared/widgets/search_and_header.dart';
import '../../../../shared/widgets/service_widgets.dart';
import '../../../../shared/widgets/vendor_card.dart';

/// Premium AM5 Royal home — discovery-first with trust & conversion focus.
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

class _PremiumHomeView extends StatelessWidget {
  const _PremiumHomeView();

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
                              onLocationTap: () => context.push('/profile/addresses'),
                              onNotifications: () => context.push('/notifications'),
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
                      padding: const EdgeInsets.symmetric(horizontal: Am5Spacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_greeting()}, $firstName',
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'What would you like help with today?',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: Am5Spacing.lg),
                          SearchBarWidget(
                            large: true,
                            readOnly: true,
                            onTap: () => context.go('/search'),
                            onMicTap: () => context.go('/assistant'),
                          ),
                          const SizedBox(height: Am5Spacing.xxl),
                        ],
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
                      SliverToBoxAdapter(
                        child: SectionHeader(
                          title: 'Categories',
                          actionLabel: 'View all',
                          onAction: () => context.go('/search'),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 108,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: Am5Spacing.lg),
                            itemCount: state.categories.length + 1,
                            separatorBuilder: (_, _) => const SizedBox(width: Am5Spacing.sm),
                            itemBuilder: (context, i) {
                              if (i == state.categories.length) {
                                return CategoryCard(
                                  label: 'More',
                                  icon: Icons.apps_rounded,
                                  onTap: () => context.go('/search'),
                                );
                              }
                              final cat = state.categories[i];
                              return CategoryCard(
                                label: cat.name,
                                icon: categoryIconFor(cat.slug),
                                onTap: () => context.push('/categories/${cat.id}'),
                              );
                            },
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: Am5Spacing.xl)),
                    ],
                    if (state.banners.isNotEmpty)
                      SliverToBoxAdapter(child: _PromoBanner(banner: state.banners.first)),
                    if (state.nearbyVendors.isNotEmpty) ...[
                      const SliverToBoxAdapter(child: SizedBox(height: Am5Spacing.xl)),
                      SliverToBoxAdapter(
                        child: SectionHeader(
                          title: 'Nearby Verified Vendors',
                          actionLabel: 'View all',
                          onAction: () => context.push('/professionals'),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: Am5Spacing.lg),
                        sliver: SliverList.separated(
                          itemCount: state.nearbyVendors.take(5).length,
                          separatorBuilder: (_, _) => const SizedBox(height: Am5Spacing.md),
                          itemBuilder: (context, i) {
                            final vendor = state.nearbyVendors[i];
                            return VendorCard(vendor: vendor);
                          },
                        ),
                      ),
                    ],
                    if (state.featured.isNotEmpty) ...[
                      const SliverToBoxAdapter(child: SizedBox(height: Am5Spacing.xl)),
                      SliverToBoxAdapter(
                        child: SectionHeader(title: 'Popular Services'),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: Am5Spacing.lg),
                        sliver: SliverList.separated(
                          itemCount: state.featured.take(3).length,
                          separatorBuilder: (_, _) => const SizedBox(height: Am5Spacing.md),
                          itemBuilder: (context, i) {
                            final svc = state.featured[i];
                            return ServiceCard(
                              service: svc,
                              badge: 'Popular',
                              onTap: () => context.push('/services/${svc.id}'),
                              onBook: () => openServiceBooking(context, svc),
                            );
                          },
                        ),
                      ),
                    ],
                    if (state.trending.isNotEmpty) ...[
                      const SliverToBoxAdapter(child: SizedBox(height: Am5Spacing.xl)),
                      SliverToBoxAdapter(child: SectionHeader(title: 'Featured Services')),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 280,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: Am5Spacing.lg),
                            itemCount: state.trending.length,
                            separatorBuilder: (_, _) => const SizedBox(width: Am5Spacing.md),
                            itemBuilder: (context, i) {
                              final svc = state.trending[i];
                              return SizedBox(
                                width: 260,
                                child: ServiceCard(
                                  service: svc,
                                  badge: svc.isFeatured ? 'Bestseller' : null,
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
                      const SliverToBoxAdapter(child: SizedBox(height: Am5Spacing.xl)),
                      SliverToBoxAdapter(child: SectionHeader(title: 'Recently viewed')),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          Am5Spacing.lg,
                          0,
                          Am5Spacing.lg,
                          Am5Spacing.xxxl,
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
                    ] else
                      const SliverToBoxAdapter(child: SizedBox(height: Am5Spacing.xxxl)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          Am5Spacing.lg,
                          0,
                          Am5Spacing.lg,
                          Am5Spacing.lg,
                        ),
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/shop'),
                          icon: const Icon(Icons.shopping_bag_outlined),
                          label: const Text('Browse service packages'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
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

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.banner});

  final CatalogBanner banner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Am5Spacing.lg,
        Am5Spacing.md,
        Am5Spacing.lg,
        Am5Spacing.xl,
      ),
      child: Container(
        height: 160,
        decoration: Am5Decorations.brandGradient(),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (banner.imageUrl.isNotEmpty)
              Image.network(banner.imageUrl, fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(0.35)),
            Padding(
              padding: const EdgeInsets.all(Am5Spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    banner.title,
                    style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  if (banner.subtitle != null)
                    Text(banner.subtitle!, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => context.go('/search'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: theme.colorScheme.primary,
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
