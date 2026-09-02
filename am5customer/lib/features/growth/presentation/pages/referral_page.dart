import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5_ui/am5_ui.dart';

import '../../../../core/customer_brand.dart';
import '../../../../core/design_system/am5_colors.dart';

class ReferralPage extends StatefulWidget {
  const ReferralPage({super.key});

  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  bool _loading = true;
  String? _error;
  ReferralInfo? _info;

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
      final info = await context.read<GrowthApi>().referralInfo();
      if (mounted) {
        setState(() {
          _info = info;
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

  Future<void> _copyCode(LivoraStrings s) async {
    final code = _info?.code;
    if (code == null || code.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.referralCopied)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Am5Colors.background,
      appBar: AppBar(
        title: Text(s.referral),
        backgroundColor: Am5Colors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: _loading
          ? LivoraLoading(message: s.loading)
          : _error != null
              ? Padding(
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
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: LivoraSpacing.lg),
                      LivoraButton(label: s.retry, onPressed: _load),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: theme.colorScheme.primary,
                  onRefresh: _load,
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
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius:
                              BorderRadius.circular(LivoraSpacing.radii.xl),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: CustomerBrand.badgeBg(context),
                                borderRadius: BorderRadius.circular(
                                  LivoraSpacing.radii.full,
                                ),
                              ),
                              child: Text(
                                s.referralEyebrow,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: CustomerBrand.badgeFg(context),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: LivoraSpacing.md),
                            Text(
                              s.referralHeroTitle,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: LivoraSpacing.xs),
                            Text(
                              s.referralHeroSubtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.82),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: LivoraSpacing.lg),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(LivoraSpacing.lg),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius:
                              BorderRadius.circular(LivoraSpacing.radii.xl),
                        ),
                        child: Column(
                          children: [
                            Text(
                              s.referralYourCode,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: LivoraSpacing.sm),
                            SelectableText(
                              _info!.code,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: LivoraSpacing.md),
                            Text(
                              _info!.shareMessage,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: LivoraSpacing.lg),
                            SizedBox(
                              width: double.infinity,
                              child: LivoraButton(
                                label: s.copyCode,
                                icon: Icons.copy_rounded,
                                onPressed: () => _copyCode(s),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: LivoraSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: s.referralYouEarn,
                              value:
                                  '₹${_info!.referrerBonus.toStringAsFixed(0)}',
                            ),
                          ),
                          const SizedBox(width: LivoraSpacing.sm),
                          Expanded(
                            child: _StatCard(
                              label: s.referralFriendEarns,
                              value:
                                  '₹${_info!.refereeBonus.toStringAsFixed(0)}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: LivoraSpacing.sm),
                      _StatCard(
                        label: s.referralRedeemed,
                        value: '${_info!.redemptionsCount}',
                        fullWidth: true,
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.fullWidth = false,
  });

  final String label;
  final String value;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(LivoraSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(LivoraSpacing.radii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
