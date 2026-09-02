import 'package:flutter/material.dart';

import '../../core/design_system/am5_colors.dart';
import '../../core/design_system/am5_decorations.dart';
import '../../core/design_system/am5_spacing.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    this.controller,
    this.hint = 'Search for services, professionals…',
    this.onSubmitted,
    this.onMicTap,
    this.onTap,
    this.readOnly = false,
    this.large = false,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onMicTap;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Am5Colors.surface,
      elevation: 0,
      shadowColor: Am5Colors.shadow,
      borderRadius: BorderRadius.circular(Am5Spacing.radiusXl),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Am5Spacing.radiusXl),
          border: Border.all(color: Am5Colors.outline.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: Am5Colors.shadow,
              blurRadius: large ? 20 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          onSubmitted: onSubmitted,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Am5Colors.surface,
            contentPadding: EdgeInsets.symmetric(
              horizontal: Am5Spacing.lg,
              vertical: large ? 18 : 14,
            ),
            prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.primary),
            suffixIcon: IconButton(
              onPressed: onMicTap,
              icon: Icon(Icons.mic_rounded, color: theme.colorScheme.primary),
              tooltip: 'Voice search',
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

class LocationHeader extends StatelessWidget {
  const LocationHeader({
    super.key,
    required this.locationLabel,
    this.onLocationTap,
    this.onNotifications,
    this.onProfile,
    this.notificationCount = 0,
    this.avatarInitial,
  });

  final String locationLabel;
  final VoidCallback? onLocationTap;
  final VoidCallback? onNotifications;
  final VoidCallback? onProfile;
  final int notificationCount;
  final String? avatarInitial;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Am5Spacing.lg,
        Am5Spacing.md,
        Am5Spacing.lg,
        Am5Spacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onLocationTap,
              borderRadius: BorderRadius.circular(Am5Spacing.radiusMd),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Location', style: theme.textTheme.bodySmall),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 18, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            locationLabel,
                            style: theme.textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.onSurfaceVariant),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onNotifications,
            icon: Badge(
              isLabelVisible: notificationCount > 0,
              label: Text('$notificationCount'),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
          GestureDetector(
            onTap: onProfile,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                (avatarInitial ?? 'U').substring(0, 1).toUpperCase(),
                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentNoticeCard extends StatelessWidget {
  const PaymentNoticeCard({
    super.key,
    required this.acknowledged,
    required this.onAcknowledgeChanged,
  });

  final bool acknowledged;
  final ValueChanged<bool> onAcknowledgeChanged;

  static const noticeText =
      'Payment is to be made directly to the service provider after completion of the service. '
      'AM5 Royal is not responsible for payments made before service completion or outside the authorized service process.';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(Am5Spacing.lg),
      decoration: Am5Decorations.softRedGradient(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payments_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: Am5Spacing.sm),
              Text('Payment notice', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: Am5Spacing.sm),
          Text(noticeText, style: theme.textTheme.bodyMedium),
          const SizedBox(height: Am5Spacing.md),
          CheckboxListTile(
            value: acknowledged,
            onChanged: (v) => onAcknowledgeChanged(v ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              'I understand and agree to the payment terms.',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
