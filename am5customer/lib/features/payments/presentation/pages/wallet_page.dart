import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_ui/am5_ui.dart';

import '../../../../core/customer_brand.dart';
import '../../../../core/design_system/am5_colors.dart';
import '../cubit/payments_cubit.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WalletCubit(context.read<PaymentsApi>())..load(),
      child: const _WalletView(),
    );
  }
}

class _WalletView extends StatelessWidget {
  const _WalletView();

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    final theme = Theme.of(context);

    return BlocBuilder<WalletCubit, WalletViewState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Am5Colors.background,
          appBar: AppBar(
            title: Text(s.wallet),
            backgroundColor: Am5Colors.background,
            surfaceTintColor: Colors.transparent,
          ),
          body: _body(context, state, s, theme),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    WalletViewState state,
    LivoraStrings s,
    ThemeData theme,
  ) {
    if (state.status == WalletStatus.loading ||
        state.status == WalletStatus.initial) {
      return LivoraLoading(message: s.loading);
    }

    if (state.status == WalletStatus.error) {
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
              state.message ?? s.offlineHint,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: LivoraSpacing.lg),
            LivoraButton(
              label: s.retry,
              onPressed: () => context.read<WalletCubit>().load(),
            ),
          ],
        ),
      );
    }

    final balance = state.wallet?.balanceLabel ?? '₹0';
    final currency = state.wallet?.currency ?? 'INR';

    return RefreshIndicator(
      color: theme.colorScheme.primary,
      onRefresh: () => context.read<WalletCubit>().load(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          LivoraSpacing.lg,
          LivoraSpacing.sm,
          LivoraSpacing.lg,
          LivoraSpacing.xxl,
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(LivoraSpacing.lg),
            decoration: CustomerBrand.heroCard(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(LivoraSpacing.radii.md),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius:
                            BorderRadius.circular(LivoraSpacing.radii.full),
                      ),
                      child: Text(
                        currency,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: LivoraSpacing.lg),
                Text(
                  s.walletBalance,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  balance,
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: LivoraSpacing.md),
                Text(
                  s.walletHint,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: LivoraSpacing.lg),
          Text(
            s.walletHowItWorks,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: LivoraSpacing.md),
          _InfoTile(
            icon: Icons.payments_outlined,
            title: s.walletTipPay,
            subtitle: s.walletTipPayBody,
          ),
          const SizedBox(height: LivoraSpacing.sm),
          _InfoTile(
            icon: Icons.workspace_premium_outlined,
            title: s.walletTipMembership,
            subtitle: s.walletTipMembershipBody,
          ),
          const SizedBox(height: LivoraSpacing.sm),
          _InfoTile(
            icon: Icons.verified_outlined,
            title: s.walletTipSecure,
            subtitle: s.walletTipSecureBody,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(LivoraSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(LivoraSpacing.radii.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: CustomerBrand.iconTileBg(context),
              borderRadius: BorderRadius.circular(LivoraSpacing.radii.md),
            ),
            child: Icon(icon, size: 20, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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

