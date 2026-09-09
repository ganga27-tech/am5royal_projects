import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/permission_service.dart';
import '../../../../core/router/app_navigation.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../features/auth/domain/entities/auth.dart';
import '../../domain/entities/product.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../widgets/product_card.dart';
import '../widgets/product_form_dialog.dart';
import '../widgets/india_hubs_map_view.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();
  bool _isMapView = true;
  Auth? _currentUser;

  @override
  void initState() {
    super.initState();
    // Dispatch initial load event
    context.read<ProductBloc>().add(const ProductEvent.loadProducts());

    // Check and request permissions after login post-frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestPermissions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    context
        .read<ProductBloc>()
        .add(ProductEvent.loadProducts(search: value.isEmpty ? null : value));
  }

  void _showProductDialog([Product? product]) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ProductFormDialog(product: product),
    );

    if (result != null && mounted) {
      if (product != null) {
        // Edit mode
        context.read<ProductBloc>().add(
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
      } else {
        // Create mode
        context.read<ProductBloc>().add(
              ProductEvent.createProduct(
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
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Confirm Logout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content:
              const Text('Are you sure you want to log out of your session?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(const AuthEvent.logout());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child:
                  const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = context.watch<AuthBloc>().state;
    authState.maybeWhen(
      success: (_, auth) {
        _currentUser = auth;
      },
      orElse: () {},
    );
    final currentUser = _currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Master'),
        actions: [
          if (currentUser != null) ...[
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Tooltip(
                message:
                    '${currentUser.name ?? "Royal Vendor"}\n(${currentUser.email ?? currentUser.contact})',
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF0F4C81),
                  backgroundImage: (currentUser.profilePhoto != null &&
                          currentUser.profilePhoto!.startsWith('http'))
                      ? NetworkImage(currentUser.profilePhoto!)
                      : null,
                  child: (currentUser.profilePhoto == null ||
                          !currentUser.profilePhoto!.startsWith('http'))
                      ? Text(
                          (currentUser.name ?? currentUser.contact)
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          IconButton(
            icon:
                Icon(_isMapView ? Icons.grid_view_rounded : Icons.map_rounded),
            tooltip: _isMapView ? 'Show Grid View' : 'Show India Hubs Map',
            onPressed: () {
              setState(() {
                _isMapView = !_isMapView;
              });
            },
          ),
          IconButton(
            icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Theme toggling is handled by the System settings in this template.'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          if (currentUser != null)
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              tooltip: 'Logout',
              onPressed: () {
                _showLogoutDialog(context);
              },
            ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              state.maybeWhen(
                initial: () {
                  context.goLogin(fromLogout: true);
                },
                orElse: () {},
              );
            },
          ),
          BlocListener<ProductBloc, ProductState>(
            listener: (context, state) {
              state.maybeWhen(
                actionSuccess: (message, _) {
                  // Show success toast
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                  // Reload product list
                  context.read<ProductBloc>().add(ProductEvent.loadProducts(
                        search: _searchController.text.isEmpty
                            ? null
                            : _searchController.text,
                      ));
                },
                actionFailure: (message) {
                  // Show error toast
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                orElse: () {},
              );
            },
          ),
        ],
        child: _isMapView
            ? PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                itemCount: 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Stack(
                      children: [
                        const IndiaHubsMapView(),
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: _buildScrollIndicator(
                            icon: Icons.keyboard_double_arrow_down_rounded,
                            label: 'Scroll down for Dashboard',
                            onTap: () {
                              _pageController.animateToPage(
                                1,
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeInOutCubic,
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  } else {
                    return _buildIconsPage();
                  }
                },
              )
            : Column(
                children: [
                  // Search & Category Header section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText: 'Search products, categories...',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded),
                                      onPressed: () {
                                        _searchController.clear();
                                        _onSearchChanged('');
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Product List Grid
                  Expanded(
                    child: BlocBuilder<ProductBloc, ProductState>(
                      builder: (context, state) {
                        return state.maybeWhen(
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          loaded: (products, search) {
                            if (products.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.inventory_2_outlined,
                                      size: 80,
                                      color: isDark
                                          ? AppColors.darkBorder
                                          : AppColors.border,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No products found',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Try searching for something else or add a new product.',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return RefreshIndicator(
                              onRefresh: () async {
                                context
                                    .read<ProductBloc>()
                                    .add(ProductEvent.loadProducts(
                                      search: _searchController.text.isEmpty
                                          ? null
                                          : _searchController.text,
                                    ));
                              },
                              child: GridView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 400,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 0.85,
                                ),
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  final product = products[index];
                                  return ProductCard(
                                    product: product,
                                    onTap: () {
                                      print("this is category");
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) =>
                                      //         ProductDetailPage(
                                      //             productId: product.id),
                                      //   ),
                                      // );
                                    },
                                    onEdit: () => _showProductDialog(product),
                                    onDelete: () {
                                      // Confirmation Dialog
                                      showDialog(
                                        context: context,
                                        builder: (dialogCtx) => AlertDialog(
                                          title: const Text('Delete Product'),
                                          content: Text(
                                              'Are you sure you want to delete "${product.name}"?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(dialogCtx),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(dialogCtx);
                                                context.read<ProductBloc>().add(
                                                    ProductEvent.deleteProduct(
                                                        product.id));
                                              },
                                              child: const Text('Delete',
                                                  style: TextStyle(
                                                      color: Colors.redAccent)),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                          },
                          error: (message) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    color: Colors.redAccent, size: 60),
                                const SizedBox(height: 16),
                                Text('Error: $message',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    context
                                        .read<ProductBloc>()
                                        .add(const ProductEvent.loadProducts());
                                  },
                                  child: const Text('Retry'),
                                )
                              ],
                            ),
                          ),
                          // During actions, show loading overlay or keep showing loaded items
                          actionInProgress: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          orElse: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: _isMapView
          ? null
          : Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () => _showProductDialog(),
                backgroundColor: Colors.transparent,
                elevation: 0,
                label: const Text('Add Product',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                icon: const Icon(Icons.add_rounded, color: Colors.white),
              ),
            ),
    );
  }

  Future<void> _checkAndRequestPermissions() async {
    final prefs = di.sl<SharedPreferences>();
    final hasRequested = prefs.getBool('HAS_REQUESTED_PERMISSIONS') ?? false;

    if (!hasRequested) {
      final allGranted = await PermissionService.hasAllPermissionsGranted();
      if (!allGranted && mounted) {
        _showPermissionsRationaleDialog();
      } else {
        await prefs.setBool('HAS_REQUESTED_PERMISSIONS', true);
      }
    }
  }

  void _showPermissionsRationaleDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          title: const Row(
            children: [
              Icon(
                Icons.security_rounded,
                color: Color(0xFF0F4C81),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Permissions Required',
                  style: TextStyle(
                    color: const Color(0xFF0F4C81),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'To provide you with a premium vendor experience, AM5 Royal requires access to the following features:',
                  style: TextStyle(
                    color: Color(0xFF7F8C8D),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPermissionExplanationItem(
                  icon: Icons.notifications_active_rounded,
                  title: 'Notifications',
                  description:
                      'Receive real-time alerts for incoming orders, deal confirmations, and stock updates.',
                ),
                _buildPermissionExplanationItem(
                  icon: Icons.location_on_rounded,
                  title: 'Location',
                  description:
                      'Optimize order delivery routes and discover nearby supply warehouses.',
                ),
                _buildPermissionExplanationItem(
                  icon: Icons.sms_rounded,
                  title: 'SMS Alerts',
                  description:
                      'Automatically verify OTPs and security alerts directly for secure login.',
                ),
                _buildPermissionExplanationItem(
                  icon: Icons.contacts_rounded,
                  title: 'Contact Book',
                  description:
                      'Connect quickly with reference contacts and invite fellow vendors.',
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                await PermissionService.requestAllPermissions();

                final prefs = di.sl<SharedPreferences>();
                await prefs.setBool('HAS_REQUESTED_PERMISSIONS', true);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                          'Permissions updated successfully! Welcome to AM5 Royal.'),
                      backgroundColor: const Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F4C81),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Center(
                child: Text(
                  'Grant Access',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPermissionExplanationItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F4C81).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF0F4C81),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D3B66),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF7F8C8D),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconsPage() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String userName = "Royal Vendor";
    if (_currentUser != null && _currentUser!.name != null) {
      userName = _currentUser!.name!;
    }

    return Container(
      color: isDark ? AppColors.darkBackground : AppColors.background,
      child: Stack(
        children: [
          // Watercolor background overlay
          Positioned.fill(
            child: Image.asset(
              'assets/images/water.png',
              fit: BoxFit.cover,
              opacity: AlwaysStoppedAnimation(isDark ? 0.05 : 0.4),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: _buildScrollIndicator(
                      icon: Icons.keyboard_double_arrow_up_rounded,
                      label: 'Scroll up for Map',
                      isUp: true,
                      onTap: () {
                        _pageController.animateToPage(
                          0,
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOutCubic,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Dashboard Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          userName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          Text(
                            userName,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'QUICK ACTIONS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: isDark ? Colors.white60 : Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Interactive Quick Actions Grid
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildActionCard(
                          icon: Icons.add_shopping_cart_rounded,
                          title: 'Add Product',
                          subtitle: 'List a new item',
                          gradientColors: [
                            const Color(0xFFFA5D4E),
                            const Color(0xFF800020)
                          ],
                          onTap: () => _showProductDialog(),
                        ),
                        _buildActionCard(
                          icon: Icons.analytics_rounded,
                          title: 'Analytics',
                          subtitle: 'View sales stats',
                          gradientColors: [
                            const Color(0xFF3B82F6),
                            const Color(0xFF1D4ED8)
                          ],
                          onTap: () {
                            _showToast(
                                'Analytics console is being synchronized.');
                          },
                        ),
                        _buildActionCard(
                          icon: Icons.map_rounded,
                          title: 'Shipping Hubs',
                          subtitle: 'Map & dispatch',
                          gradientColors: [
                            const Color(0xFF10B981),
                            const Color(0xFF047857)
                          ],
                          onTap: () {
                            _pageController.animateToPage(
                              0,
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeInOutCubic,
                            );
                          },
                        ),
                        _buildActionCard(
                          icon: Icons.receipt_long_rounded,
                          title: 'Orders',
                          subtitle: 'Manage invoices',
                          gradientColors: [
                            const Color(0xFFF59E0B),
                            const Color(0xFFD97706)
                          ],
                          onTap: () {
                            _showToast('Loading orders queue...');
                          },
                        ),
                        _buildActionCard(
                          icon: Icons.support_agent_rounded,
                          title: 'Support',
                          subtitle: 'Contact manager',
                          gradientColors: [
                            const Color(0xFF8B5CF6),
                            const Color(0xFF6D28D9)
                          ],
                          onTap: () {
                            _showToast('Connecting to VIP Support Desk...');
                          },
                        ),
                        _buildActionCard(
                          icon: Icons.manage_accounts_rounded,
                          title: 'Settings',
                          subtitle: 'Account & profile',
                          gradientColors: [
                            const Color(0xFF6B7280),
                            const Color(0xFF374151)
                          ],
                          onTap: () {
                            _showToast('Opening Account Settings...');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: gradientColors[0].withOpacity(0.1),
          highlightColor: gradientColors[0].withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[1].withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScrollIndicator({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isUp = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E1E1E).withOpacity(0.9)
                : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, isUp ? -2 : 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isUp) Icon(icon, color: AppColors.primary, size: 18),
              if (isUp) const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              if (!isUp) const SizedBox(width: 8),
              if (!isUp) Icon(icon, color: AppColors.primary, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
