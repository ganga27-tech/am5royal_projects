import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_ui/am5_ui.dart';

import '../cubit/cart_cubit.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _useWallet = false;

  @override
  void initState() {
    super.initState();
    context.read<CartCubit>().load();
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
        title: const Text('Cart'),
      ),
      body: BlocConsumer<CartCubit, CartState>(
        listener: (context, state) {
          if (state.status == CartStatus.error && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message!)),
            );
          }
        },
        builder: (context, state) {
          if (state.status == CartStatus.loading || state.status == CartStatus.initial) {
            return LivoraLoading(message: s.loading);
          }
          final cart = state.cart;
          if (cart == null || cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: LivoraSpacing.md),
                  const Text('Your cart is empty'),
                  const SizedBox(height: LivoraSpacing.lg),
                  OutlinedButton(
                    onPressed: () => context.go('/shop'),
                    child: const Text('Browse shop'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(LivoraSpacing.lg),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: LivoraSpacing.md),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return _CartLine(
                      title: item.product.name,
                      price: item.product.priceAmount,
                      quantity: item.quantity,
                      onRemove: () => context.read<CartCubit>().remove(item.productId),
                      onQty: (q) => context.read<CartCubit>().updateQty(item.productId, q),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(LivoraSpacing.lg),
                decoration: BoxDecoration(
                  color: LivoraColors.cardOf(context),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Pay from wallet (if available)'),
                        value: _useWallet,
                        onChanged: (v) => setState(() => _useWallet = v),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal', style: theme.textTheme.titleMedium),
                          Text(
                            '₹${cart.subtotalAmount.toStringAsFixed(0)}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: LivoraSpacing.md),
                      FilledButton(
                        onPressed: state.status == CartStatus.checkingOut
                            ? null
                            : () async {
                                final order = await context.read<CartCubit>().checkout(
                                      useWalletAmount: _useWallet ? cart.subtotalAmount : 0,
                                    );
                                if (!context.mounted || order == null) return;
                                context.go('/shop/orders');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Order placed successfully')),
                                );
                              },
                        child: state.status == CartStatus.checkingOut
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Place order'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CartLine extends StatelessWidget {
  const _CartLine({
    required this.title,
    required this.price,
    required this.quantity,
    required this.onRemove,
    required this.onQty,
  });

  final String title;
  final double price;
  final int quantity;
  final VoidCallback onRemove;
  final ValueChanged<int> onQty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: LivoraColors.cardOf(context),
      borderRadius: BorderRadius.circular(LivoraSpacing.radii.lg),
      child: Padding(
        padding: const EdgeInsets.all(LivoraSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    '₹${price.toStringAsFixed(0)} each',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: quantity > 1 ? () => onQty(quantity - 1) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$quantity'),
                IconButton(
                  onPressed: () => onQty(quantity + 1),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            IconButton(onPressed: onRemove, icon: const Icon(Icons.delete_outline)),
          ],
        ),
      ),
    );
  }
}
