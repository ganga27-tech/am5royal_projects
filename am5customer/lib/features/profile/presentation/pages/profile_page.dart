import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5_ui/am5_ui.dart';

import '../../../../core/auth/login_guard.dart';
import '../../../../core/customer_brand.dart';
import '../../../../core/design_system/am5_colors.dart';
import '../bloc/profile_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    final theme = Theme.of(context);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState.status != AuthStatus.authenticated) {
          return _GuestProfileView(strings: s, theme: theme);
        }

        return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (p, c) => p.message != c.message || p.status != c.status,
      listener: (context, state) {
        if (state.status == ProfileStatus.deleted) {
          context.go('/welcome');
          return;
        }
        if (state.message != null) {
          final text = switch (state.message) {
            'saved' => s.saved,
            'password_changed' => s.saved,
            'deleted' => s.saved,
            _ => state.message!,
          };
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(text)));
          context.read<ProfileBloc>().add(const ProfileMessageCleared());
        }
      },
      builder: (context, state) {
        if (state.status == ProfileStatus.loading || state.profile == null) {
          return Scaffold(
            backgroundColor: theme.colorScheme.surface,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(title: s.profile),
                  Expanded(child: LivoraLoading(message: s.loading)),
                ],
              ),
            ),
          );
        }

        if (state.status == ProfileStatus.error) {
          return Scaffold(
            backgroundColor: theme.colorScheme.surface,
            body: SafeArea(
              child: Column(
                children: [
                  _Header(title: s.profile),
                  Expanded(
                    child: Padding(
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
                            state.message ?? s.offlineHint,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: LivoraSpacing.lg),
                          LivoraButton(
                            label: s.retry,
                            onPressed: () => context
                                .read<ProfileBloc>()
                                .add(const ProfileStarted()),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final p = state.profile!;
        return Scaffold(
          backgroundColor: Am5Colors.background,
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: theme.colorScheme.primary,
              onRefresh: () async {
                context.read<ProfileBloc>().add(const ProfileStarted());
                await Future<void>.delayed(const Duration(milliseconds: 400));
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _Header(
                      title: s.profile,
                      actionLabel: s.editProfile,
                      onAction: () => context.push('/profile/edit'),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        LivoraSpacing.lg,
                        LivoraSpacing.sm,
                        LivoraSpacing.lg,
                        LivoraSpacing.md,
                      ),
                      child: _ProfileHero(profile: p),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        LivoraSpacing.lg,
                        LivoraSpacing.sm,
                        LivoraSpacing.lg,
                        LivoraSpacing.xxl,
                      ),
                      child: Column(
                        children: [
                          _MenuSection(
                            title: s.account,
                            items: [
                              _MenuItemData(
                                icon: Icons.storefront_outlined,
                                label: 'Shop',
                                onTap: () => context.push('/shop'),
                              ),
                              _MenuItemData(
                                icon: Icons.location_on_outlined,
                                label: s.addresses,
                                onTap: () => LoginGuard.runProtected(
                                  context,
                                  () => context.push('/profile/addresses'),
                                  message: 'Sign in to manage your addresses.',
                                  redirectTo: '/profile/addresses',
                                ),
                              ),
                              _MenuItemData(
                                icon: Icons.event_note_outlined,
                                label: s.myBookings,
                                onTap: () => LoginGuard.runProtected(
                                  context,
                                  () => context.go('/bookings'),
                                  message: 'Sign in to view your bookings.',
                                  redirectTo: '/bookings',
                                ),
                              ),
                              _MenuItemData(
                                icon: Icons.notifications_none_rounded,
                                label: s.notifications,
                                onTap: () => LoginGuard.runProtected(
                                  context,
                                  () => context.push('/notifications'),
                                  message: 'Sign in to view notifications.',
                                  redirectTo: '/notifications',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: LivoraSpacing.md),
                          _MenuSection(
                            title: s.support,
                            items: [
                              _MenuItemData(
                                icon: Icons.support_agent_outlined,
                                label: s.support,
                                onTap: () => context.push('/support'),
                              ),
                              _MenuItemData(
                                icon: Icons.settings_outlined,
                                label: s.settings,
                                onTap: () => context.push('/settings'),
                              ),
                            ],
                          ),
                          const SizedBox(height: LivoraSpacing.md),
                          _SignOutSection(strings: s),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
      },
    );
  }
}

class _GuestProfileView extends StatelessWidget {
  const _GuestProfileView({required this.strings, required this.theme});

  final LivoraStrings strings;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Am5Colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LivoraSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                strings.profile,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: LivoraSpacing.xl),
              Container(
                padding: const EdgeInsets.all(LivoraSpacing.lg),
                decoration: CustomerBrand.heroCard(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sign in to your account',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Access bookings, addresses, and notifications after signing in with OTP.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.push('/login?redirect=${Uri.encodeComponent('/profile')}'),
                child: const Text('Sign in'),
              ),
              const SizedBox(height: LivoraSpacing.sm),
              OutlinedButton(
                onPressed: () => context.push('/shop'),
                child: const Text('Browse shop'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        LivoraSpacing.lg,
        LivoraSpacing.md,
        LivoraSpacing.md,
        LivoraSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial =
        profile.name.isNotEmpty ? profile.name.substring(0, 1).toUpperCase() : '?';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(LivoraSpacing.lg),
      decoration: CustomerBrand.heroCard(context),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            child: Text(
              initial,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: LivoraSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.displayPhone,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
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

class _SignOutSection extends StatelessWidget {
  const _SignOutSection({required this.strings});

  final LivoraStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            strings.security,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(LivoraSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(LivoraSpacing.radii.xl),
          ),
          child: OutlinedButton.icon(
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthLogoutRequested()),
            icon: const Icon(Icons.logout_rounded),
            label: Text(strings.signOut),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuItemData {
  const _MenuItemData({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.title, required this.items});

  final String title;
  final List<_MenuItemData> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(LivoraSpacing.radii.xl),
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                ListTile(
                  onTap: items[i].onTap,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: CustomerBrand.iconTileBg(context),
                      borderRadius:
                          BorderRadius.circular(LivoraSpacing.radii.md),
                    ),
                    child: Icon(
                      items[i].icon,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    items[i].label,
                    style: theme.textTheme.titleSmall,
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (i < items.length - 1)
                  Divider(
                    height: 1,
                    indent: 68,
                    color: theme.colorScheme.outlineVariant,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}


