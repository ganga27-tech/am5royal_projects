import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5_ui/am5_ui.dart';

import '../../../../core/customer_brand.dart';
import '../../../../core/design_system/am5_colors.dart';
import '../cubit/address_cubit.dart';

class AddressListPage extends StatelessWidget {
  const AddressListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddressCubit(context.read<AddressApi>())..load(),
      child: const _AddressListView(),
    );
  }
}

class _AddressListView extends StatelessWidget {
  const _AddressListView();

  Future<void> _openNew(BuildContext context) async {
    await context.push('/profile/addresses/new');
    if (context.mounted) await context.read<AddressCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    final theme = Theme.of(context);

    return BlocConsumer<AddressCubit, AddressViewState>(
      listenWhen: (p, c) => p.message != c.message && c.message != null,
      listener: (context, state) {
        final text = switch (state.message) {
          'saved' => s.saved,
          'deleted' => s.addressDeleted,
          _ => state.message!,
        };
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
        context.read<AddressCubit>().clearMessage();
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Am5Colors.background,
          appBar: AppBar(
            title: Text(s.addresses),
            backgroundColor: Am5Colors.background,
            surfaceTintColor: Colors.transparent,
            actions: [
            
            ],
          ),
          floatingActionButton: state.addresses.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () => _openNew(context),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(s.addAddress),
                )
              : null,
          body: _body(context, state, s, theme),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    AddressViewState state,
    LivoraStrings s,
    ThemeData theme,
  ) {
    if (state.status == AddressStatus.loading ||
        state.status == AddressStatus.initial) {
      return LivoraLoading(message: s.loading);
    }

    if (state.status == AddressStatus.error) {
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
              onPressed: () => context.read<AddressCubit>().load(),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: theme.colorScheme.primary,
      onRefresh: () => context.read<AddressCubit>().load(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          LivoraSpacing.lg,
          LivoraSpacing.sm,
          LivoraSpacing.lg,
          LivoraSpacing.xxl + 56,
        ),
        children: [
          if (state.serviceAreas.isNotEmpty) ...[
            Text(
              s.serviceCities,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: LivoraSpacing.sm),
            Text(
              s.serviceCitiesHint,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: LivoraSpacing.md),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.serviceAreas
                  .map(
                    (a) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius:
                            BorderRadius.circular(LivoraSpacing.radii.full),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_city_outlined,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            a.city,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: LivoraSpacing.xl),
          ],
          Text(
            s.savedAddresses,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: LivoraSpacing.md),
          if (state.addresses.isEmpty)
            _EmptyAddresses(
              message: s.addressesEmpty,
              actionLabel: s.addAddress,
              onAdd: () => _openNew(context),
            )
          else
            ...state.addresses.map(
              (addr) => Padding(
                padding: const EdgeInsets.only(bottom: LivoraSpacing.md),
                child: _AddressCard(address: addr),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyAddresses extends StatelessWidget {
  const _EmptyAddresses({
    required this.message,
    required this.actionLabel,
    required this.onAdd,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(LivoraSpacing.xl),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(LivoraSpacing.radii.xl),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: CustomerBrand.iconTileBg(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_location_alt_outlined,
              color: theme.colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: LivoraSpacing.md),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: LivoraSpacing.lg),
          LivoraButton(label: actionLabel, onPressed: onAdd),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address});

  final UserAddress address;

  IconData get _icon {
    if (address.label == 'work') return Icons.work_outline_rounded;
    if (address.label == 'other') return Icons.place_outlined;
    return Icons.home_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(LivoraSpacing.radii.xl),
      child: Padding(
        padding: const EdgeInsets.all(LivoraSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: CustomerBrand.iconTileBg(context),
                    borderRadius: BorderRadius.circular(LivoraSpacing.radii.md),
                  ),
                  child: Icon(_icon, color: theme.colorScheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    address.displayLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: CustomerBrand.badgeBg(context),
                      borderRadius:
                          BorderRadius.circular(LivoraSpacing.radii.full),
                    ),
                    child: Text(
                      s.defaultAddress,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: LivoraColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: LivoraSpacing.md),
            Text(
              address.summaryLine,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (address.landmark != null && address.landmark!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                address.landmark!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: LivoraSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: address.isServiceable
                    ? LivoraColors.success.withValues(alpha: 0.12)
                    : LivoraColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(LivoraSpacing.radii.full),
              ),
              child: Text(
                address.isServiceable ? s.serviceable : s.notServiceable,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: address.isServiceable
                      ? LivoraColors.success
                      : LivoraColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: LivoraSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: LivoraSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (!address.isDefault)
                  OutlinedButton(
                    onPressed: () =>
                        context.read<AddressCubit>().setDefault(address.id),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      minimumSize: const Size(0, 36),
                    ),
                    child: Text(s.setDefault),
                  ),
                OutlinedButton(
                  onPressed: () async {
                    await context.push('/profile/addresses/${address.id}/edit');
                    if (context.mounted) {
                      await context.read<AddressCubit>().load();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    minimumSize: const Size(0, 36),
                  ),
                  child: Text(s.editAddress),
                ),
                OutlinedButton(
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(s.deleteAddress),
                        content: Text(s.confirmDeleteAddress),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(s.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(
                              s.deleteAddress,
                              style: const TextStyle(color: LivoraColors.error),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (ok == true && context.mounted) {
                      await context.read<AddressCubit>().remove(address.id);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: LivoraColors.error,
                    side: BorderSide(
                      color: LivoraColors.error.withValues(alpha: 0.35),
                    ),
                    visualDensity: VisualDensity.compact,
                    minimumSize: const Size(0, 36),
                  ),
                  child: Text(s.deleteAddress),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
