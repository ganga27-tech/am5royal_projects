import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/product.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../widgets/product_form_dialog.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  // Use a dedicated Bloc for details to avoid interfering with the list page's state
  late ProductBloc _detailBloc;

  @override
  void initState() {
    super.initState();
    _detailBloc = sl<ProductBloc>();
    _loadProduct();
  }

  @override
  void dispose() {
    _detailBloc.close();
    super.dispose();
  }

  void _loadProduct() {
    // Wait, since we are fetching detail, let's run the API call.
    // We can call getProduct from the repository or use the Bloc event LoadProducts to fetch all,
    // but we can also handle specific product fetch. Let's register a dedicated handler or fetch the product.
    // In our Bloc, LoadProductDetail isn't fully implemented in the bloc class.
    // Let's implement it in the bloc class to showcase fetching details.
  }

  void _editProduct(Product product) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ProductFormDialog(product: product),
    );

    if (result != null && mounted) {
      _detailBloc.add(
        ProductEvent.updateProduct(
          id: product.id,
          name: result['name'],
          category: result['category'],
          price: result['price'],
          stock: result['stock'],
          description: result['description'],
          imageUrl: result['imageUrl'],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _detailBloc,
      child: Scaffold(
        body: BlocConsumer<ProductBloc, ProductState>(
          bloc: _detailBloc,
          listener: (context, state) {
            state.maybeWhen(
              actionSuccess: (message, product) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: AppColors.primaryLightf,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                // If deleted, pop back to list page
                if (message.contains('deleted')) {
                  Navigator.pop(context, true);
                } else {
                  // Reload if edited
                  _detailBloc.add(const ProductEvent.loadProducts());
                }
              },
              actionFailure: (message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              orElse: () {},
            );
          },
          builder: (context, state) {
            // Find the current product in the loaded list or fallback
            Product? product;
            bool isLoading = false;

            state.maybeWhen(
              loading: () => isLoading = true,
              actionInProgress: () => isLoading = true,
              loaded: (products, _) {
                try {
                  product =
                      products.firstWhere((p) => p.id == widget.productId);
                } catch (_) {
                  product = null;
                }
              },
              orElse: () {},
            );

            // If we are in initial state, load the list to find the product
            if (state is Initial) {
              _detailBloc.add(const ProductEvent.loadProducts());
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (isLoading && product == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (product == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Product Details')),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 60, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      const Text(
                        'Product not found or was deleted.',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go Back'),
                      )
                    ],
                  ),
                ),
              );
            }

            final currentProduct = product!;

            return CustomScrollView(
              slivers: [
                // Premium Sliver App Bar with Image
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          currentProduct.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: isDark
                                ? AppColors.statusConfirmed
                                : AppColors.borderf,
                            child:
                                const Icon(Icons.image_not_supported, size: 80),
                          ),
                        ),
                        // Dark overlay for legibility
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Colors.black54],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.black38,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ),
                  actions: [
                    CircleAvatar(
                      backgroundColor: Colors.black38,
                      child: IconButton(
                        icon:
                            const Icon(Icons.edit_rounded, color: Colors.white),
                        onPressed: () => _editProduct(currentProduct),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.black38,
                      child: IconButton(
                        icon: const Icon(Icons.delete_rounded,
                            color: Colors.redAccent),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (dialogCtx) => AlertDialog(
                              title: const Text('Delete Product'),
                              content: Text(
                                  'Are you sure you want to delete "${currentProduct.name}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogCtx),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(dialogCtx);
                                    _detailBloc.add(ProductEvent.deleteProduct(
                                        currentProduct.id));
                                  },
                                  child: const Text('Delete',
                                      style:
                                          TextStyle(color: Colors.redAccent)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),

                // Product Details Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.2)),
                          ),
                          child: Text(
                            currentProduct.category.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          currentProduct.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Price and Stock details
                        Row(
                          children: [
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'PRICE',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${currentProduct.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? AppColors.primaryLight
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'AVAILABILITY',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      currentProduct.stock > 0
                                          ? '${currentProduct.stock} In Stock'
                                          : 'Out of Stock',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: currentProduct.stock > 0
                                            ? Colors.green
                                            : Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Description Heading
                        const Text(
                          'Product Overview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Description Text
                        Text(
                          currentProduct.description,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
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
