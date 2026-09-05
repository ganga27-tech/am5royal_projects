import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_core/am5_core.dart';

import '../../../../core/design_system/am5_colors.dart';
import '../../../../core/design_system/am5_decorations.dart';
import '../../../../core/design_system/am5_spacing.dart';
import '../../../../shared/widgets/app_primitives.dart';
import '../../../../shared/widgets/search_and_header.dart';

class BookingConfirmationPage extends StatelessWidget {
  const BookingConfirmationPage({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final time = _formatTime(booking.scheduledStart);

    return Scaffold(
      backgroundColor: Am5Colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Am5Spacing.lg),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 88,
                height: 88,
                decoration: Am5Decorations.brandGradient(),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
              ),
              const SizedBox(height: Am5Spacing.xl),
              Text(
                'Booking confirmed!',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Am5Spacing.sm),
              Text(
                '#${booking.bookingCode}',
                style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
              ),
              const SizedBox(height: Am5Spacing.xxl),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Am5Spacing.lg),
                decoration: Am5Decorations.card(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.serviceName, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      '${_formatDate(booking.scheduledStart)} · $time',
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (booking.professionalName != null &&
                        booking.professionalName!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Professional: ${booking.professionalName}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                    if (booking.priceAmount > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Estimated: ${booking.priceLabel}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: Am5Spacing.lg),
              Container(
                padding: const EdgeInsets.all(Am5Spacing.lg),
                decoration: Am5Decorations.softRedGradient(),
                child: Text(
                  PaymentNoticeCard.noticeText,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const Spacer(),
              AppButton(
                label: 'View bookings',
                onPressed: () => context.go('/bookings'),
              ),
              const SizedBox(height: Am5Spacing.sm),
              AppButton(
                label: 'Go to home',
                outlined: true,
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
