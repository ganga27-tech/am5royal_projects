import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5_ui/am5_ui.dart';

class ProductOrdersPage extends StatefulWidget {
  const ProductOrdersPage({super.key});

  @override
  State<ProductOrdersPage> createState() => _ProductOrdersPageState();
}

class _ProductOrdersPageState extends State<ProductOrdersPage> {
  List<ProductOrder>? _orders;
  bool _loading = true;
  String? _error;

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
      final orders = await context.read<MarketplaceApi>().listOrders();
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Product orders'),
      ),
      body: _loading
          ? LivoraLoading(message: s.loading)
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!),
                      const SizedBox(height: LivoraSpacing.md),
                      FilledButton(onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : (_orders == null || _orders!.isEmpty)
                  ? const Center(child: Text('No orders yet'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(LivoraSpacing.lg),
                        itemCount: _orders!.length,
                        separatorBuilder: (_, _) => const SizedBox(height: LivoraSpacing.md),
                        itemBuilder: (context, index) {
                          final order = _orders![index];
                          return Material(
                            color: LivoraColors.cardOf(context),
                            borderRadius: BorderRadius.circular(LivoraSpacing.radii.lg),
                            child: Padding(
                              padding: const EdgeInsets.all(LivoraSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Order #${order.id.substring(0, 8)}',
                                          style: theme.textTheme.titleSmall,
                                        ),
                                      ),
                                      _StatusChip(status: order.status),
                                    ],
                                  ),
                                  const SizedBox(height: LivoraSpacing.sm),
                                  Text(
                                    '₹${order.totalAmount.toStringAsFixed(0)} · ${order.items.length} item(s)',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  if (order.deliveryAddressSnapshot != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      order.deliveryAddressSnapshot!,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                  const SizedBox(height: LivoraSpacing.sm),
                                  ...order.items.map(
                                    (i) => Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '· ${i.productName} × ${i.quantity}',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(LivoraSpacing.radii.full),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
