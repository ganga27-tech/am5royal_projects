import 'package:flutter/material.dart';
import 'package:am5_core/am5_core.dart';

import '../../core/design_system/am5_colors.dart';
import '../../core/design_system/am5_decorations.dart';
import '../../core/design_system/am5_spacing.dart';
import 'app_primitives.dart';

class RatingWidget extends StatelessWidget {
  const RatingWidget({
    super.key,
    required this.rating,
    this.reviewCount,
    this.size = 14,
  });

  final double rating;
  final int? reviewCount;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: size, color: Am5Colors.warning),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: theme.textTheme.labelLarge?.copyWith(fontSize: size),
        ),
        if (reviewCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: theme.textTheme.bodySmall?.copyWith(fontSize: size - 1),
          ),
        ],
      ],
    );
  }
}

class PriceWidget extends StatelessWidget {
  const PriceWidget({
    super.key,
    required this.amount,
    this.prefix = 'Starts from',
    this.currency = '₹',
    this.emphasize = true,
  });

  final double amount;
  final String prefix;
  final String currency;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (prefix.isNotEmpty)
          Text(prefix, style: theme.textTheme.bodySmall),
        Text(
          '$currency${amount.toStringAsFixed(0)}',
          style: emphasize
              ? theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                )
              : theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.service,
    this.onTap,
    this.onBook,
    this.badge,
    this.distanceKm,
    this.rating = 4.8,
    this.reviewCount = 120,
    this.compact = false,
  });

  final CatalogServiceItem service;
  final VoidCallback? onTap;
  final VoidCallback? onBook;
  final String? badge;
  final double? distanceKm;
  final double rating;
  final int reviewCount;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageHeight = compact ? 100.0 : 140.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Am5Spacing.radiusLg),
        child: Container(
          decoration: Am5Decorations.card(context),
          clipBehavior: Clip.antiAlias,
          child: compact
              ? _horizontalLayout(context, theme, imageHeight)
              : _verticalLayout(context, theme, imageHeight),
        ),
      ),
    );
  }

  Widget _verticalLayout(BuildContext context, ThemeData theme, double imageHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _image(imageHeight),
        Padding(
          padding: const EdgeInsets.all(Am5Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (badge != null || service.isFeatured) _badgeRow(theme),
              Text(service.name, style: theme.textTheme.titleMedium, maxLines: 2),
              if (service.shortDescription != null) ...[
                const SizedBox(height: 4),
                Text(
                  service.shortDescription!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: Am5Spacing.sm),
              Row(
                children: [
                  RatingWidget(rating: rating, reviewCount: reviewCount, size: 13),
                  const Spacer(),
                  Text(
                    '${service.durationMinutes} min',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: Am5Spacing.sm),
              Row(
                children: [
                  PriceWidget(amount: service.basePrice),
                  const Spacer(),
                  if (onBook != null)
                    FilledButton(
                      onPressed: onBook,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      child: const Text('Book'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _horizontalLayout(BuildContext context, ThemeData theme, double imageHeight) {
    return Row(
      children: [
        SizedBox(width: 110, height: imageHeight, child: _image(imageHeight)),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(Am5Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name, style: theme.textTheme.titleSmall, maxLines: 2),
                const SizedBox(height: 4),
                RatingWidget(rating: rating, reviewCount: reviewCount, size: 12),
                const SizedBox(height: 6),
                Row(
                  children: [
                    PriceWidget(amount: service.basePrice, prefix: '', emphasize: true),
                    if (distanceKm != null) ...[
                      const SizedBox(width: 8),
                      Text('${distanceKm!.toStringAsFixed(1)} km', style: theme.textTheme.bodySmall),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _badgeRow(ThemeData theme) {
    final label = badge ?? (service.isFeatured ? 'Popular' : null);
    if (label == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Am5Colors.warning.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(Am5Spacing.radiusFull),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: Am5Colors.warning,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _image(double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: Am5Colors.lightRed,
      child: service.imageUrl != null
          ? Image.network(service.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => _placeholder())
          : _placeholder(),
    );
  }

  Widget _placeholder() {
    return Center(
      child: Icon(Icons.home_repair_service_rounded, color: Am5Colors.brandRed.withValues(alpha: 0.4), size: 40),
    );
  }
}

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.selected = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected ? theme.colorScheme.primary : Am5Colors.lightRed,
      borderRadius: BorderRadius.circular(Am5Spacing.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Am5Spacing.radiusLg),
        child: SizedBox(
          width: 88,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Am5Spacing.md, horizontal: Am5Spacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: selected ? Colors.white : theme.colorScheme.primary,
                  size: 26,
                ),
                const SizedBox(height: Am5Spacing.sm),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: selected ? Colors.white : Am5Colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

IconData categoryIconFor(String slugOrName) {
  final key = slugOrName.toLowerCase();
  if (key.contains('clean')) return Icons.cleaning_services_outlined;
  if (key.contains('beauty') || key.contains('wellness')) return Icons.spa_outlined;
  if (key.contains('appliance') || key.contains('ac')) return Icons.ac_unit_outlined;
  if (key.contains('plumb')) return Icons.plumbing_outlined;
  if (key.contains('electric')) return Icons.electrical_services_outlined;
  if (key.contains('pest')) return Icons.bug_report_outlined;
  return Icons.grid_view_rounded;
}
