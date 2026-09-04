import 'package:flutter/material.dart';
import 'package:am5_core/am5_core.dart';
import 'package:go_router/go_router.dart';

import '../../core/design_system/am5_colors.dart';

enum VendorCardStyle { profile, feed }

class VendorCard extends StatelessWidget {
  const VendorCard({
    super.key,
    required this.vendor,
    this.onTap,
    this.onBook,
    this.compact = false,
    this.style = VendorCardStyle.profile,
  });

  final Professional vendor;
  final VoidCallback? onTap;
  final VoidCallback? onBook;
  final bool compact;
  final VendorCardStyle style;

  @override
  Widget build(BuildContext context) {
    if (style == VendorCardStyle.feed && !compact) {
      return _FeedVendorCard(vendor: vendor, onTap: onTap);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Am5Colors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFF1F1F1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () => context.push('/vendors/${vendor.id}'),
          child: compact ? _buildCompactLayout(context) : _buildFullLayout(context),
        ),
      ),
    );
  }

  Widget _buildFullLayout(BuildContext context) {
    final hasBanner = vendor.hasBanner;
    final hasPhoto = vendor.hasAvatar;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Banner / Header
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE31E24), Color(0xFF881337)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                image: hasBanner
                    ? DecorationImage(
                        image: NetworkImage(vendor.bannerUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.4),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            // Verified Badge / Tag on Banner
            Positioned(
              top: 10,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified, size: 14, color: Color(0xFF16A34A)),
                    const SizedBox(width: 4),
                    Text(
                      'Verified Vendor',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Vendor Avatar
            Positioned(
              bottom: -22,
              left: 16,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
                  ],
                  image: hasPhoto
                      ? DecorationImage(
                          image: NetworkImage(vendor.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: !hasPhoto
                    ? Center(
                        child: Text(
                          vendor.displayName.isNotEmpty
                              ? vendor.displayName.substring(0, 1).toUpperCase()
                              : 'V',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE31E24),
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Body Content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Business Name & Rating
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      vendor.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFD97706)),
                        const SizedBox(width: 3),
                        Text(
                          vendor.ratingAvg.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFB45309),
                          ),
                        ),
                        if (vendor.ratingCount > 0) ...[
                          const SizedBox(width: 2),
                          Text(
                            '(${vendor.ratingCount})',
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Location & Distance Pill
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      vendor.city != null && vendor.city!.isNotEmpty
                          ? vendor.city!
                          : 'Hyderabad & surrounding area',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (vendor.distanceKm != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        vendor.distanceLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1D4ED8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),

              // Divider
              Divider(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 12),

              // Pricing & Action Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Starts from',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        vendor.priceLabel.isNotEmpty ? vendor.priceLabel : '₹499',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE31E24),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: onBook ?? () => context.push('/vendors/${vendor.id}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE31E24),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    ),
                    child: const Text(
                      'View Profile',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    final hasPhoto = vendor.hasAvatar;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF3F4F6),
              image: hasPhoto
                  ? DecorationImage(
                      image: NetworkImage(vendor.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: !hasPhoto
                ? Center(
                    child: Text(
                      vendor.displayName.isNotEmpty
                          ? vendor.displayName.substring(0, 1).toUpperCase()
                          : 'V',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE31E24),
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        vendor.displayName,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, size: 13, color: Color(0xFF16A34A)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${vendor.city ?? 'Hyderabad'} · ★ ${vendor.ratingAvg.toStringAsFixed(1)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 3),
                Text(
                  'Starts ${vendor.priceLabel.isNotEmpty ? vendor.priceLabel : '₹499'}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFE31E24),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

class _FeedVendorCard extends StatelessWidget {
  const _FeedVendorCard({required this.vendor, this.onTap});

  final Professional vendor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasBanner = vendor.hasBanner;
    final hasPhoto = vendor.hasAvatar;
    final price = vendor.priceLabel.isNotEmpty ? vendor.priceLabel : '₹499';
    final city = vendor.city != null && vendor.city!.isNotEmpty
        ? vendor.city!
        : 'Hyderabad';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () => context.push('/vendors/${vendor.id}'),
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: hasBanner
                          ? Image.network(
                              vendor.bannerUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _imageFallback(hasPhoto),
                            )
                          : _imageFallback(hasPhoto),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.05),
                              Colors.black.withValues(alpha: 0.45),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (vendor.isVerified)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, size: 14, color: Am5Colors.success),
                              SizedBox(width: 4),
                              Text(
                                'Verified Vendor',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Am5Colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Starts from $price',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            vendor.displayName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Am5Colors.success,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, size: 13, color: Colors.white),
                              const SizedBox(width: 2),
                              Text(
                                vendor.ratingAvg.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'For you',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Am5Colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.bolt_rounded, size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          vendor.distanceKm != null ? 'Near & fast' : 'Verified professional',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Am5Colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: Am5Colors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            city,
                            style: theme.textTheme.bodySmall?.copyWith(color: Am5Colors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (vendor.ratingCount > 0)
                          Text(
                            '${vendor.ratingCount} reviews',
                            style: theme.textTheme.bodySmall?.copyWith(color: Am5Colors.textSecondary),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageFallback(bool hasPhoto) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE31E24), Color(0xFF881337)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: CircleAvatar(
          radius: 36,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          backgroundImage: hasPhoto ? NetworkImage(vendor.avatarUrl!) : null,
          child: !hasPhoto
              ? Text(
                  vendor.displayName.isNotEmpty
                      ? vendor.displayName.substring(0, 1).toUpperCase()
                      : 'V',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
