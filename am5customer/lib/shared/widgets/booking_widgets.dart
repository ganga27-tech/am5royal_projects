import 'package:flutter/material.dart';
import 'package:am5_core/am5_core.dart';

import '../../core/design_system/am5_colors.dart';
import '../../core/design_system/am5_decorations.dart';
import '../../core/design_system/am5_spacing.dart';
import 'service_widgets.dart';

class DateSelector extends StatelessWidget {
  const DateSelector({
    super.key,
    required this.selected,
    required this.onSelected,
    this.days = 14,
  });

  final DateTime selected;
  final ValueChanged<DateTime> onSelected;
  final int days;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final start = DateTime.now();
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Am5Spacing.lg),
        itemCount: days,
        separatorBuilder: (_, _) => const SizedBox(width: Am5Spacing.sm),
        itemBuilder: (context, index) {
          final day = DateTime(start.year, start.month, start.day + index);
          final isSelected = day.year == selected.year &&
              day.month == selected.month &&
              day.day == selected.day;
          return GestureDetector(
            onTap: () => onSelected(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              padding: const EdgeInsets.symmetric(vertical: Am5Spacing.md),
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary : Am5Colors.lightRed,
                borderRadius: BorderRadius.circular(Am5Spacing.radiusMd),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekday(day),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isSelected ? Colors.white : Am5Colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${day.day}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isSelected ? Colors.white : Am5Colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _weekday(DateTime d) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[d.weekday - 1];
  }
}

String _formatDateTime(DateTime d) {
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  return '${d.day}/${d.month}/${d.year} · $h:$m';
}

class TimeSlotSelector extends StatelessWidget {
  const TimeSlotSelector({
    super.key,
    required this.slots,
    required this.selected,
    required this.onSelected,
  });

  final List<BookingSlot> slots;
  final BookingSlot? selected;
  final ValueChanged<BookingSlot> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (slots.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(Am5Spacing.lg),
        child: Text('No slots available for this date', style: theme.textTheme.bodyMedium),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Am5Spacing.lg),
      child: Wrap(
        spacing: Am5Spacing.sm,
        runSpacing: Am5Spacing.sm,
        children: slots.map((slot) {
          final isSelected = selected == slot;
          return Material(
            color: isSelected ? theme.colorScheme.primary : Am5Colors.lightRed,
            borderRadius: BorderRadius.circular(Am5Spacing.radiusMd),
            child: InkWell(
              onTap: () => onSelected(slot),
              borderRadius: BorderRadius.circular(Am5Spacing.radiusMd),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  slot.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isSelected ? Colors.white : Am5Colors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    this.serviceName,
    this.onTap,
    this.onRebook,
    this.onViewDetails,
  });

  final Booking booking;
  final String? serviceName;
  final VoidCallback? onTap;
  final VoidCallback? onRebook;
  final VoidCallback? onViewDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Am5Spacing.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(Am5Spacing.lg),
          decoration: Am5Decorations.card(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      serviceName ?? booking.serviceName ?? 'Service',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  _StatusPill(status: booking.status),
                ],
              ),
              const SizedBox(height: Am5Spacing.sm),
              Text(
                _formatDateTime(booking.scheduledStart),
                style: theme.textTheme.bodyMedium,
              ),
              if (booking.professionalName != null) ...[
                const SizedBox(height: 4),
                Text('with ${booking.professionalName}', style: theme.textTheme.bodySmall),
              ],
              const SizedBox(height: Am5Spacing.sm),
              Row(
                children: [
                  Text(
                    booking.priceLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text('#${booking.bookingCode}', style: theme.textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: Am5Spacing.md),
              Row(
                children: [
                  if (onViewDetails != null)
                    OutlinedButton(onPressed: onViewDetails, child: const Text('Details')),
                  const SizedBox(width: Am5Spacing.sm),
                  if (onRebook != null)
                    FilledButton(onPressed: onRebook, child: const Text('Rebook')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color bg = Am5Colors.lightRed;
    Color fg = theme.colorScheme.primary;
    if (status == 'completed') {
      bg = Am5Colors.success.withValues(alpha: 0.12);
      fg = Am5Colors.success;
    } else if (status == 'cancelled') {
      bg = Am5Colors.outline.withValues(alpha: 0.3);
      fg = Am5Colors.textSecondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Am5Spacing.radiusFull),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: theme.textTheme.labelSmall?.copyWith(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}
