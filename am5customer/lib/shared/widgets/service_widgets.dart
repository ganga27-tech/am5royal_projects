import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:am5_core/am5_core.dart';

import '../../core/design_system/am5_colors.dart';
import '../../core/design_system/am5_decorations.dart';
import '../../core/design_system/am5_spacing.dart';

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
    this.imageUrl,
    this.onTap,
    this.selected = false,
    this.circular = false,
  });

  final String label;
  final IconData icon;
  final String? imageUrl;
  final VoidCallback? onTap;
  final bool selected;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (circular) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Am5Spacing.radiusLg),
        child: SizedBox(
          width: 76,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? theme.colorScheme.primary : Am5Colors.outline.withValues(alpha: 0.5),
                    width: selected ? 2 : 1,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                clipBehavior: Clip.antiAlias,
                child: _categoryImage(theme),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: selected ? theme.colorScheme.primary : Am5Colors.textPrimary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  height: 1.15,
                ),
              ),
              if (selected)
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 28,
                  height: 3,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(Am5Spacing.radiusFull),
                  ),
                ),
            ],
          ),
        ),
      );
    }

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

  Widget _categoryImage(ThemeData theme) {
    final rawUrl = imageUrl?.trim();
    if (rawUrl == null || rawUrl.isEmpty) {
      return _categoryIcon(theme);
    }

    final isSvg = rawUrl.toLowerCase().contains('.svg');
    final isAsset = rawUrl.startsWith('assets/');

    if (isAsset) {
      if (isSvg) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset(
              rawUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => _categoryIcon(theme),
            ),
          ),
        );
      }
      return Image.asset(
        rawUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _categoryIcon(theme),
      );
    }

    if (isSvg) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.network(
            rawUrl,
            fit: BoxFit.contain,
            placeholderBuilder: (_) => _categoryIcon(theme),
            errorBuilder: (_, _, _) => _categoryIcon(theme),
          ),
        ),
      );
    }

    return Image.network(
      rawUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _categoryIcon(theme),
    );
  }

  Widget _categoryIcon(ThemeData theme) {
    return ColoredBox(
      color: selected
          ? theme.colorScheme.primary.withValues(alpha: 0.12)
          : Am5Colors.lightRed,
      child: Center(
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 28,
        ),
      ),
    );
  }
}

IconData categoryIconFor(String slugOrName) {
  final key = slugOrName.toLowerCase();
  if (key.contains('security') ||
      key.contains('safety') ||
      key.contains('guard') ||
      key.contains('cctv')) {
    return Icons.security_rounded;
  }
  if (key.contains('home') || key.contains('house')) {
    return Icons.home_work_rounded;
  }
  if (key.contains('event') ||
      key.contains('wedding') ||
      key.contains('party')) {
    return Icons.celebration_rounded;
  }
  if (key.contains('religio') ||
      key.contains('spiritual') ||
      key.contains('pooja') ||
      key.contains('temple') ||
      key.contains('pandit')) {
    return Icons.auto_awesome_rounded;
  }
  if (key.contains('clean')) return Icons.cleaning_services_rounded;
  if (key.contains('beauty') ||
      key.contains('wellness') ||
      key.contains('salon') ||
      key.contains('spa')) {
    return Icons.spa_rounded;
  }
  if (key.contains('appliance') ||
      key.contains('ac') ||
      key.contains('cool')) {
    return Icons.ac_unit_rounded;
  }
  if (key.contains('plumb')) return Icons.plumbing_rounded;
  if (key.contains('electric')) return Icons.electrical_services_rounded;
  if (key.contains('pest')) return Icons.pest_control_rounded;
  if (key.contains('paint')) return Icons.format_paint_rounded;
  if (key.contains('doctor') ||
      key.contains('health') ||
      key.contains('medical') ||
      key.contains('nurs') ||
      key.contains('physio')) {
    return Icons.medical_services_rounded;
  }
  if (key.contains('pet')) return Icons.pets_rounded;
  if (key.contains('cook') ||
      key.contains('chef') ||
      key.contains('food') ||
      key.contains('cater')) {
    return Icons.restaurant_rounded;
  }
  if (key.contains('driver') ||
      key.contains('car') ||
      key.contains('auto') ||
      key.contains('travel') ||
      key.contains('ride') ||
      key.contains('wheeler')) {
    return Icons.directions_car_rounded;
  }
  if (key.contains('interior') ||
      key.contains('modular') ||
      key.contains('carpen') ||
      key.contains('furnitur')) {
    return Icons.chair_rounded;
  }
  if (key.contains('pack') ||
      key.contains('shift') ||
      key.contains('mover')) {
    return Icons.local_shipping_rounded;
  }
  if (key.contains('train') ||
      key.contains('educat') ||
      key.contains('class') ||
      key.contains('tutor')) {
    return Icons.school_rounded;
  }
  if (key.contains('water') || key.contains('proof')) {
    return Icons.water_drop_rounded;
  }
  if (key.contains('hotel') || key.contains('accommodat')) {
    return Icons.hotel_rounded;
  }
  return Icons.category_rounded;
}
