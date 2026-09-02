import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5_ui/am5_ui.dart';

import '../../../../core/customer_brand.dart';
import '../../../../core/design_system/am5_colors.dart';

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage> {
  bool _loading = true;
  String? _error;
  List<MembershipPlan> _plans = const [];
  MembershipStatus? _status;
  String? _subscribingId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<GrowthApi>();
      final plans = await api.listPlans();
      final status = await api.membershipStatus();
      if (mounted) {
        setState(() {
          _plans = plans;
          _status = status;
          _loading = false;
        });
      }
    } on Failure catch (f) {
      if (mounted) {
        setState(() {
          _error = f.message;
          _loading = false;
        });
      }
    }
  }

  Future<void> _subscribe(MembershipPlan plan) async {
    setState(() => _subscribingId = plan.id);
    try {
      await context.read<GrowthApi>().subscribe(plan.id);
      await _load();
    } on Failure catch (f) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(f.message)),
        );
      }
    } finally {
      if (mounted) setState(() => _subscribingId = null);
    }
  }

  String _statusLine(LivoraStrings s) {
    final status = _status;
    if (status?.active == true) {
      return s.membershipActiveUntil
          .replaceAll('{plan}', status!.plan?.name ?? '')
          .replaceAll('{date}', _formatDate(status.endsAt));
    }
    return s.membershipInactive;
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return '${parsed.day}/${parsed.month}/${parsed.year}';
  }

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: _loading
            ? LivoraLoading(message: s.loading)
            : _error != null
                ? _ErrorBody(
                    message: _error!,
                    retryLabel: s.retry,
                    onRetry: _load,
                  )
                : RefreshIndicator(
                    color: theme.colorScheme.primary,
                    onRefresh: _load,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              LivoraSpacing.lg,
                              LivoraSpacing.md,
                              LivoraSpacing.lg,
                              0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back_rounded),
                                      color: theme.colorScheme.primary,
                                      onPressed: () {
                                        if (context.canPop()) {
                                          context.pop();
                                        } else {
                                          context.go('/profile');
                                        }
                                      },
                                    ),
                                    Expanded(
                                      child: Text(
                                        s.membership,
                                        style: theme.textTheme.headlineMedium?.copyWith(
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: LivoraSpacing.md),
                                _StatusBanner(
                                  active: _status?.active == true,
                                  message: _statusLine(s),
                                ),
                                const SizedBox(height: LivoraSpacing.lg),
                                _HeroCard(
                                  title: s.membershipHeroTitle,
                                  subtitle: s.membershipHeroSubtitle,
                                ),
                                const SizedBox(height: LivoraSpacing.xl),
                                Text(
                                  s.membershipChoosePlan,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: LivoraSpacing.md),
                              ],
                            ),
                          ),
                        ),
                        if (_plans.isEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: LivoraSpacing.lg,
                              ),
                              child: Text(s.membershipEmptyPlans),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(
                              LivoraSpacing.lg,
                              0,
                              LivoraSpacing.lg,
                              LivoraSpacing.xxl,
                            ),
                            sliver: SliverList.separated(
                              itemCount: _plans.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: LivoraSpacing.md),
                              itemBuilder: (context, index) {
                                final plan = _plans[index];
                                final isCurrent = _status?.active == true &&
                                    _status?.plan?.id == plan.id;
                                final isFeatured = index == _plans.length - 1;
                                return _PlanCard(
                                  plan: plan,
                                  strings: s,
                                  isCurrent: isCurrent,
                                  isFeatured: isFeatured,
                                  canSubscribe: _status?.active != true,
                                  subscribing: _subscribingId == plan.id,
                                  onSubscribe: () => _subscribe(plan),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
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
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: LivoraSpacing.lg),
            LivoraButton(label: retryLabel, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.active, required this.message});

  final bool active;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = active
        ? LivoraColors.success.withValues(alpha: 0.12)
        : Am5Colors.background;
    final fg = active ? LivoraColors.success : theme.colorScheme.onSurfaceVariant;
    final icon = active ? Icons.verified_rounded : Icons.info_outline_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(LivoraSpacing.radii.lg),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(LivoraSpacing.lg),
      decoration: CustomerBrand.heroCard(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(LivoraSpacing.radii.full),
            ),
            child: Text(
              'AM5 ROYAL',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: LivoraSpacing.md),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              height: 1.25,
            ),
          ),
          const SizedBox(height: LivoraSpacing.xs),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.strings,
    required this.isCurrent,
    required this.isFeatured,
    required this.canSubscribe,
    required this.subscribing,
    required this.onSubscribe,
  });

  final MembershipPlan plan;
  final LivoraStrings strings;
  final bool isCurrent;
  final bool isFeatured;
  final bool canSubscribe;
  final bool subscribing;
  final VoidCallback onSubscribe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = isFeatured || isCurrent
        ? (isFeatured ? CustomerBrand.badgeFg(context) : theme.colorScheme.primary)
        : theme.colorScheme.outlineVariant;

    return Material(
      color: theme.colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LivoraSpacing.radii.xl),
        side: BorderSide(color: borderColor, width: isFeatured || isCurrent ? 1.5 : 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(LivoraSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isCurrent || isFeatured) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? theme.colorScheme.primary
                                : CustomerBrand.badgeBg(context),
                            borderRadius: BorderRadius.circular(
                              LivoraSpacing.radii.full,
                            ),
                          ),
                          child: Text(
                            isCurrent
                                ? strings.membershipCurrentPlan
                                : strings.badgeBestseller,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isCurrent
                                  ? theme.colorScheme.onPrimary
                                  : CustomerBrand.badgeFg(context),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: LivoraSpacing.sm),
                      ],
                      Text(
                        plan.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (plan.description?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          plan.description!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: LivoraSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${plan.priceAmount.toStringAsFixed(0)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      strings.membershipDays.replaceAll(
                        '{n}',
                        '${plan.durationDays}',
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: LivoraSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _BenefitChip(
                    icon: Icons.percent_rounded,
                    label: strings.membershipDiscount.replaceAll(
                      '{n}',
                      plan.discountPercent.toStringAsFixed(
                        plan.discountPercent.truncateToDouble() ==
                                plan.discountPercent
                            ? 0
                            : 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _BenefitChip(
                    icon: Icons.account_balance_wallet_outlined,
                    label: strings.membershipCredit.replaceAll(
                      '{n}',
                      plan.walletCredit.toStringAsFixed(0),
                    ),
                  ),
                ),
              ],
            ),
            if (canSubscribe) ...[
              const SizedBox(height: LivoraSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: LivoraButton(
                  label: strings.subscribe,
                  loading: subscribing,
                  onPressed: subscribing ? null : onSubscribe,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BenefitChip extends StatelessWidget {
  const _BenefitChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Am5Colors.background,
        borderRadius: BorderRadius.circular(LivoraSpacing.radii.md),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
