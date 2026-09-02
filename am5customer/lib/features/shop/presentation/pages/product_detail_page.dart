import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5_ui/am5_ui.dart';

import '../cubit/cart_cubit.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  MarketplaceProduct? _product;
  bool _loading = true;
  String? _error;
  int _qty = 1;

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
      final product = await context.read<MarketplaceApi>().getProduct(widget.productId);
      if (!mounted) return;
      setState(() {
        _product = product;
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
    final theme = Theme.of(context);
    final s = LivoraStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(_product?.name ?? s.navShop),
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
              : _buildContent(context, theme, _product!),
      bottomNavigationBar: _product == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(LivoraSpacing.lg),
                child: Row(
                  children: [
                    _QtyStepper(
                      value: _qty,
                      max: _product!.stockQuantity,
                      onChanged: (v) => setState(() => _qty = v),
                    ),
                    const SizedBox(width: LivoraSpacing.md),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _product!.stockQuantity < 1
                            ? null
                            : () async {
                                await context.read<CartCubit>().add(_product!.id, quantity: _qty);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Added to cart')),
                                );
                              },
                        icon: const Icon(Icons.add_shopping_cart_rounded),
                        label: const Text('Add to cart'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme, MarketplaceProduct p) {
    return ListView(
      padding: const EdgeInsets.all(LivoraSpacing.lg),
      children: [
        AspectRatio(
          aspectRatio: 1.2,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(LivoraSpacing.radii.lg),
            ),
            clipBehavior: Clip.antiAlias,
            child: p.imageUrl != null
                ? Image.network(p.imageUrl!, fit: BoxFit.cover)
                : Icon(Icons.inventory_2_outlined, size: 72, color: theme.colorScheme.primary),
          ),
        ),
        const SizedBox(height: LivoraSpacing.lg),
        Text(p.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: LivoraSpacing.sm),
        Text(
          '₹${p.priceAmount.toStringAsFixed(0)} / ${p.unitLabel}',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (p.vendorName != null) ...[
          const SizedBox(height: LivoraSpacing.xs),
          Text('Sold by ${p.vendorName}', style: theme.textTheme.bodyMedium),
        ],
        const SizedBox(height: LivoraSpacing.sm),
        Text(
          p.stockQuantity > 0 ? '${p.stockQuantity} in stock' : 'Out of stock',
          style: theme.textTheme.labelLarge?.copyWith(
            color: p.stockQuantity > 0 ? Colors.green.shade700 : theme.colorScheme.error,
          ),
        ),
        const SizedBox(height: LivoraSpacing.lg),
        if (p.shortDescription != null)
          Text(p.shortDescription!, style: theme.textTheme.bodyLarge),
        if (p.description != null) ...[
          const SizedBox(height: LivoraSpacing.md),
          Text(p.description!, style: theme.textTheme.bodyMedium),
        ],
      ],
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.value,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(LivoraSpacing.radii.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_rounded),
          ),
          Text('$value', style: Theme.of(context).textTheme.titleMedium),
          IconButton(
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}
