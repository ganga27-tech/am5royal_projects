import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5_ui/am5_ui.dart';

import '../../../../core/customer_brand.dart';
import '../../../../core/design_system/am5_colors.dart';
import '../cubit/bookings_cubit.dart';

enum _BookingFilter { all, upcoming, inProgress, completed, cancelled }

class BookingsListPage extends StatelessWidget {
  const BookingsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookingsCubit(context.read<BookingsApi>())..load(),
      child: const _BookingsView(),
    );
  }
}

class _BookingsView extends StatefulWidget {
  const _BookingsView();

  @override
  State<_BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends State<_BookingsView> {
  _BookingFilter _filter = _BookingFilter.all;

  List<Booking> _filtered(List<Booking> items) {
    switch (_filter) {
      case _BookingFilter.all:
        return items;
      case _BookingFilter.upcoming:
        return items
            .where((b) => b.status == 'pending' || b.status == 'confirmed')
            .toList();
      case _BookingFilter.inProgress:
        return items.where((b) => b.status == 'in_progress').toList();
      case _BookingFilter.completed:
        return items.where((b) => b.status == 'completed').toList();
      case _BookingFilter.cancelled:
        return items.where((b) => b.status == 'cancelled').toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    final theme = Theme.of(context);

    return BlocConsumer<BookingsCubit, BookingsViewState>(
      listenWhen: (p, c) => p.message != c.message && c.message != null,
      listener: (context, state) {
        final text =
            state.message == 'cancelled' ? s.bookingCancelled : state.message!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
        context.read<BookingsCubit>().clearMessage();
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Am5Colors.background,
          body: SafeArea(
            bottom: false,
            child: _buildBody(context, state, s, theme),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    BookingsViewState state,
    LivoraStrings s,
    ThemeData theme,
  ) {
    if (state.status == BookingsStatus.loading ||
        state.status == BookingsStatus.initial) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(title: s.myBookings),
          Expanded(child: LivoraLoading(message: s.loading)),
        ],
      );
    }

    if (state.status == BookingsStatus.error) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(title: s.myBookings),
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
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: LivoraSpacing.lg),
                  LivoraButton(
                    label: s.retry,
                    onPressed: () => context.read<BookingsCubit>().load(),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final filtered = _filtered(state.items);

    return RefreshIndicator(
      color: theme.colorScheme.primary,
      onRefresh: () => context.read<BookingsCubit>().load(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _Header(title: s.myBookings)),
          SliverToBoxAdapter(
            child: _FilterRow(
              filter: _filter,
              strings: s,
              onChanged: (f) => setState(() => _filter = f),
            ),
          ),
          if (state.items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(
                icon: Icons.event_available_outlined,
                title: s.bookingsEmpty,
                actionLabel: s.navExplore,
                onAction: () => context.go('/search'),
              ),
            )
          else if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(
                icon: Icons.filter_list_off_rounded,
                title: s.bookingsFilterEmpty,
                actionLabel: s.bookingsShowAll,
                onAction: () => setState(() => _filter = _BookingFilter.all),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                LivoraSpacing.lg,
                LivoraSpacing.md,
                LivoraSpacing.lg,
                LivoraSpacing.xxl,
              ),
              sliver: SliverList.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: LivoraSpacing.md),
                itemBuilder: (context, index) {
                  return _BookingCard(
                    booking: filtered[index],
                    strings: s,
                    onPay: () =>
                        context.push('/bookings/${filtered[index].id}/pay'),
                    onTrack: () =>
                        context.push('/bookings/${filtered[index].id}/track'),
                    onChat: () =>
                        context.push('/bookings/${filtered[index].id}/chat'),
                    onCancel: () => context
                        .read<BookingsCubit>()
                        .cancel(filtered[index].id),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        LivoraSpacing.lg,
        LivoraSpacing.md,
        LivoraSpacing.lg,
        LivoraSpacing.sm,
      ),
      child: Text(
        title,
        style: theme.textTheme.headlineMedium?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.filter,
    required this.strings,
    required this.onChanged,
  });

  final _BookingFilter filter;
  final LivoraStrings strings;
  final ValueChanged<_BookingFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = <(_BookingFilter, String)>[
      (_BookingFilter.all, strings.bookingsFilterAll),
      (_BookingFilter.upcoming, strings.bookingsUpcoming),
      (_BookingFilter.inProgress, strings.bookingsInProgress),
      (_BookingFilter.completed, strings.bookingsCompleted),
      (_BookingFilter.cancelled, strings.bookingsCancelled),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: LivoraSpacing.lg),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (value, label) = items[index];
          final selected = filter == value;
          return FilterChip(
            label: Text(label),
            selected: selected,
            showCheckmark: false,
            onSelected: (_) => onChanged(value),
            selectedColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected
                      ? theme.colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
            side: BorderSide(
              color: selected
                  ? theme.colorScheme.primary
                  : Theme.of(context).colorScheme.outlineVariant,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(LivoraSpacing.radii.full),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(LivoraSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Am5Colors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: LivoraSpacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: LivoraSpacing.lg),
          LivoraButton(
            label: actionLabel,
            variant: LivoraButtonVariant.secondary,
            onPressed: onAction,
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.strings,
    required this.onPay,
    required this.onTrack,
    required this.onChat,
    required this.onCancel,
  });

  final Booking booking;
  final LivoraStrings strings;
  final VoidCallback onPay;
  final VoidCallback onTrack;
  final VoidCallback onChat;
  final VoidCallback onCancel;

  bool get _canPay =>
      booking.paymentStatus != 'paid' && booking.status != 'cancelled';
  bool get _canTrack =>
      booking.status == 'confirmed' || booking.status == 'in_progress';
  bool get _canChat => booking.status != 'cancelled';
  bool get _canCancel =>
      booking.status == 'pending' || booking.status == 'confirmed';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusMeta = _statusMeta(booking.status, strings, theme);
    final paid = booking.paymentStatus == 'paid';

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(LivoraSpacing.radii.xl),
      child: Padding(
        padding: const EdgeInsets.all(LivoraSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(LivoraSpacing.radii.md),
                  ),
                  child: Icon(
                    Icons.home_repair_service_outlined,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.serviceName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.bookingCode,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  booking.priceLabel,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: LivoraSpacing.md),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Badge(
                  label: statusMeta.label,
                  background: statusMeta.background,
                  foreground: statusMeta.foreground,
                ),
                _Badge(
                  label: paid ? strings.paid : strings.unpaid,
                  background: paid
                      ? LivoraColors.success.withValues(alpha: 0.12)
                      : LivoraColors.warning.withValues(alpha: 0.12),
                  foreground: paid ? LivoraColors.success : LivoraColors.warning,
                ),
              ],
            ),
            const SizedBox(height: LivoraSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Am5Colors.background,
                borderRadius: BorderRadius.circular(LivoraSpacing.radii.md),
              ),
              child: Column(
                children: [
                  _MetaRow(
                    icon: Icons.person_outline_rounded,
                    label: booking.professionalName?.isNotEmpty == true
                        ? booking.professionalName!
                        : strings.professionals,
                  ),
                  const SizedBox(height: 8),
                  _MetaRow(
                    icon: Icons.calendar_today_outlined,
                    label: _formatSchedule(booking.scheduledStart),
                  ),
                  const SizedBox(height: 8),
                  _MetaRow(
                    icon: Icons.schedule_outlined,
                    label: '${booking.durationMinutes} ${strings.minutes}',
                  ),
                ],
              ),
            ),
            if (_canPay || _canTrack || _canChat || _canCancel) ...[
              const SizedBox(height: LivoraSpacing.md),
              _ActionRow(
                canPay: _canPay,
                canTrack: _canTrack,
                canChat: _canChat,
                canCancel: _canCancel,
                strings: strings,
                onPay: onPay,
                onTrack: onTrack,
                onChat: onChat,
                onCancel: onCancel,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.canPay,
    required this.canTrack,
    required this.canChat,
    required this.canCancel,
    required this.strings,
    required this.onPay,
    required this.onTrack,
    required this.onChat,
    required this.onCancel,
  });

  final bool canPay;
  final bool canTrack;
  final bool canChat;
  final bool canCancel;
  final LivoraStrings strings;
  final VoidCallback onPay;
  final VoidCallback onTrack;
  final VoidCallback onChat;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final primaryLabel = canPay
        ? strings.payNow
        : canTrack
            ? strings.trackLive
            : null;
    final primaryIcon = canPay
        ? Icons.payments_outlined
        : Icons.near_me_outlined;
    final primaryAction = canPay
        ? onPay
        : canTrack
            ? onTrack
            : null;

    return Row(
      children: [
        if (primaryAction != null) ...[
          Expanded(
            child: FilledButton.icon(
              onPressed: primaryAction,
              icon: Icon(primaryIcon, size: 18),
              label: Text(primaryLabel!),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (canTrack && canPay)
          _IconAction(
            tooltip: strings.trackLive,
            icon: Icons.near_me_outlined,
            onPressed: onTrack,
          ),
        if (canChat)
          _IconAction(
            tooltip: strings.chat,
            icon: Icons.chat_bubble_outline_rounded,
            onPressed: onChat,
          ),
        if (canCancel)
          _IconAction(
            tooltip: strings.cancelBooking,
            icon: Icons.close_rounded,
            destructive: true,
            onPressed: onCancel,
          ),
      ],
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.destructive = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        destructive ? LivoraColors.error : theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: destructive
              ? LivoraColors.error.withValues(alpha: 0.08)
              : theme.colorScheme.primary.withValues(alpha: 0.08),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(icon, size: 20, color: color),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(LivoraSpacing.radii.full),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

({String label, Color background, Color foreground}) _statusMeta(
  String status,
  LivoraStrings s,
  ThemeData theme,
) {
  switch (status) {
    case 'pending':
      return (
        label: s.bookingStatusPending,
        background: LivoraColors.warning.withValues(alpha: 0.12),
        foreground: LivoraColors.warning,
      );
    case 'confirmed':
      return (
        label: s.bookingStatusConfirmed,
        background: theme.colorScheme.primary.withValues(alpha: 0.12),
        foreground: theme.colorScheme.primary,
      );
    case 'in_progress':
      return (
        label: s.bookingStatusInProgress,
        background: const Color(0xFF0B6E99).withValues(alpha: 0.12),
        foreground: const Color(0xFF0B6E99),
      );
    case 'completed':
      return (
        label: s.bookingStatusCompleted,
        background: LivoraColors.success.withValues(alpha: 0.12),
        foreground: LivoraColors.success,
      );
    case 'cancelled':
      return (
        label: s.bookingStatusCancelled,
        background: LivoraColors.error.withValues(alpha: 0.1),
        foreground: LivoraColors.error,
      );
    default:
      return (
        label: status,
        background: Am5Colors.background,
        foreground: LivoraColors.onSurfaceVariant,
      );
  }
}

String _formatSchedule(DateTime dt) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final weekday = weekdays[dt.weekday - 1];
  final month = months[dt.month - 1];
  final hour24 = dt.hour;
  final minute = dt.minute.toString().padLeft(2, '0');
  final period = hour24 >= 12 ? 'PM' : 'AM';
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  return '$weekday, $month ${dt.day} · $hour12:$minute $period';
}
