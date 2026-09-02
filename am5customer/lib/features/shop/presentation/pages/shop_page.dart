import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5_ui/am5_ui.dart';

import '../cubit/shop_cubit.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final _searchCtrl = TextEditingController();
  String? _category;

  static const _categories = [
    ('all', 'All'),
    ('cleaning', 'Cleaning'),
    ('supplies', 'Supplies'),
    ('general', 'General'),
  ];

  @override
  void initState() {
    super.initState();
    context.read<ShopCubit>().load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = LivoraStrings.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<ShopCubit, ShopState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      LivoraSpacing.lg,
                      LivoraSpacing.md,
                      LivoraSpacing.lg,
                      LivoraSpacing.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                s.navShop,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Cart',
                              onPressed: () => context.push('/shop/cart'),
                              icon: const Icon(Icons.shopping_cart_outlined),
                            ),
                            IconButton(
                              tooltip: 'Orders',
                              onPressed: () => context.push('/shop/orders'),
                              icon: const Icon(Icons.receipt_long_outlined),
                            ),
                          ],
                        ),
                        const SizedBox(height: LivoraSpacing.sm),
                        TextField(
                          controller: _searchCtrl,
                          decoration: InputDecoration(
                            hintText: 'Search products…',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.arrow_forward_rounded),
                              onPressed: () => context.read<ShopCubit>().load(
                                    category: _category == 'all' ? null : _category,
                                    q: _searchCtrl.text.trim(),
                                  ),
                            ),
                            filled: true,
                            fillColor: LivoraColors.canvasOf(context),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(LivoraSpacing.radii.lg),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (q) => context.read<ShopCubit>().load(
                                category: _category == 'all' ? null : _category,
                                q: q.trim(),
                              ),
                        ),
                        const SizedBox(height: LivoraSpacing.md),
                        SizedBox(
                          height: 36,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: LivoraSpacing.sm),
                            itemBuilder: (context, i) {
                              final (id, label) = _categories[i];
                              final selected = (_category ?? 'all') == id;
                              return FilterChip(
                                label: Text(label),
                                selected: selected,
                                onSelected: (_) {
                                  setState(() => _category = id);
                                  context.read<ShopCubit>().load(
                                        category: id == 'all' ? null : id,
                                        q: _searchCtrl.text.trim(),
                                      );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.status == ShopStatus.loading)
                  SliverFillRemaining(
                    child: LivoraLoading(message: s.loading),
                  )
                else if (state.status == ShopStatus.error)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.message ?? 'Could not load products'),
                          const SizedBox(height: LivoraSpacing.md),
                          FilledButton(
                            onPressed: () => context.read<ShopCubit>().load(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (state.products.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No products yet',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      LivoraSpacing.lg,
                      LivoraSpacing.md,
                      LivoraSpacing.lg,
                      LivoraSpacing.xxl,
                    ),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: LivoraSpacing.md,
                        crossAxisSpacing: LivoraSpacing.md,
                        childAspectRatio: 0.72,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _ProductCard(product: state.products[index]),
                        childCount: state.products.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final MarketplaceProduct product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: LivoraColors.cardOf(context),
      borderRadius: BorderRadius.circular(LivoraSpacing.radii.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/shop/products/${product.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: theme.colorScheme.primary.withValues(alpha: 0.06),
                child: product.imageUrl != null
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _placeholder(theme),
                      )
                    : _placeholder(theme),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(LivoraSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${product.priceAmount.toStringAsFixed(0)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (product.vendorName != null)
                    Text(
                      product.vendorName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(ThemeData theme) {
    return Center(
      child: Icon(
        Icons.cleaning_services_rounded,
        size: 40,
        color: theme.colorScheme.primary.withValues(alpha: 0.5),
      ),
    );
  }
}
