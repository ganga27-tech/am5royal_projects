import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5_ui/am5_ui.dart';

import '../../../../core/booking_routes.dart';
import '../../../../core/design_system/am5_colors.dart';
import '../../../../core/design_system/am5_decorations.dart';
import '../../../../core/design_system/am5_spacing.dart';
import '../../../../shared/widgets/app_primitives.dart';
import '../../../../shared/widgets/service_widgets.dart';

class ServiceDetailPage extends StatefulWidget {
  const ServiceDetailPage({super.key, required this.serviceId});

  final String serviceId;

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  late Future<CatalogServiceItem> _future;
  bool _favorite = false;

  @override
  void initState() {
    super.initState();
    final catalog = context.read<CatalogApi>();
    final search = context.read<SearchApi>();
    _future = catalog.getService(widget.serviceId);
    unawaited(search.trackViewed(widget.serviceId).then((_) {}, onError: (_) {}));
  }

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    final theme = Theme.of(context);

    return FutureBuilder<CatalogServiceItem>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(),
            body: snapshot.hasError
                ? EmptyState(message: snapshot.error.toString(), actionLabel: s.retry, onAction: () => setState(() {}))
                : LivoraLoading(message: s.loading),
          );
        }
        final svc = snapshot.data!;
        return Scaffold(
          backgroundColor: Am5Colors.background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.pop(),
                  style: IconButton.styleFrom(backgroundColor: Colors.white70),
                ),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.share_outlined),
                    style: IconButton.styleFrom(backgroundColor: Colors.white70),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _favorite = !_favorite),
                    icon: Icon(_favorite ? Icons.favorite : Icons.favorite_border),
                    style: IconButton.styleFrom(backgroundColor: Colors.white70),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: svc.imageUrl != null
                      ? Image.network(svc.imageUrl!, fit: BoxFit.cover)
                      : Container(color: Am5Colors.lightRed, child: Icon(Icons.home_repair_service, size: 80, color: theme.colorScheme.primary)),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(Am5Spacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (svc.isFeatured)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Am5Colors.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(Am5Spacing.radiusFull),
                          ),
                          child: Text('Bestseller', style: theme.textTheme.labelSmall?.copyWith(color: Am5Colors.warning)),
                        ),
                      const SizedBox(height: Am5Spacing.sm),
                      Text(svc.name, style: theme.textTheme.headlineMedium),
                      const SizedBox(height: Am5Spacing.sm),
                      Row(
                        children: [
                          const RatingWidget(rating: 4.8, reviewCount: 240),
                          const SizedBox(width: Am5Spacing.lg),
                          Icon(Icons.schedule, size: 16, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text('${svc.durationMinutes} ${s.minutes}', style: theme.textTheme.bodyMedium),
                        ],
                      ),
                      const SizedBox(height: Am5Spacing.lg),
                      PriceWidget(amount: svc.basePrice),
                      const SizedBox(height: Am5Spacing.lg),
                      _TrustRow(),
                      const SizedBox(height: Am5Spacing.xl),
                      Text('About this service', style: theme.textTheme.titleMedium),
                      const SizedBox(height: Am5Spacing.sm),
                      Text(
                        svc.description ?? svc.shortDescription ?? 'Professional service delivered by verified experts.',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: Am5Spacing.xl),
                      Text('What\'s included', style: theme.textTheme.titleMedium),
                      const SizedBox(height: Am5Spacing.sm),
                      ..._includedItems(svc).map((item) => _CheckItem(text: item)),
                      const SizedBox(height: Am5Spacing.xl),
                      Text('What\'s not included', style: theme.textTheme.titleMedium),
                      const SizedBox(height: Am5Spacing.sm),
                      const _CheckItem(text: 'Spare parts & materials (charged separately if needed)', included: false),
                      const _CheckItem(text: 'Structural repairs beyond service scope', included: false),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(Am5Spacing.lg),
              decoration: BoxDecoration(
                color: Am5Colors.surface,
                boxShadow: [BoxShadow(color: Am5Colors.shadow, blurRadius: 12, offset: const Offset(0, -4))],
              ),
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Starts from', style: theme.textTheme.bodySmall),
                      Text(
                        svc.priceLabel,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: Am5Spacing.lg),
                  Expanded(
                    child: AppButton(
                      label: 'Book now',
                      onPressed: () => openServiceBookingById(
                        context,
                        serviceId: svc.id,
                        serviceName: svc.name,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<String> _includedItems(CatalogServiceItem svc) {
    return [
      'Verified professional at your doorstep',
      'Standard tools & equipment',
      'Up to ${svc.durationMinutes} minutes of service time',
      'Quality check before completion',
    ];
  }
}

class _TrustRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _item(Icons.verified_user_outlined, 'Verified', theme),
        _item(Icons.shield_outlined, 'Guaranteed', theme),
        _item(Icons.payments_outlined, 'Pay after service', theme),
      ],
    );
  }

  Widget _item(IconData icon, String label, ThemeData theme) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 22),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}

class _CheckItem extends StatelessWidget {
  const _CheckItem({required this.text, this.included = true});

  final String text;
  final bool included;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            included ? Icons.check_circle_rounded : Icons.cancel_outlined,
            size: 20,
            color: included ? Am5Colors.success : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: Am5Spacing.sm),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
