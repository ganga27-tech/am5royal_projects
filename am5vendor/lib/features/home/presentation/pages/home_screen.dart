import 'package:am5vendor/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/constants/colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../orders/presentation/bloc/orders_bloc.dart';
import '../../../orders/presentation/bloc/orders_event.dart';
import '../../../orders/presentation/bloc/orders_state.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../wallet/presentation/bloc/wallet_bloc.dart';
import '../../../wallet/presentation/bloc/wallet_event.dart';
import '../../../subscriptions/presentation/pages/my_subscriptions_screen.dart';
import '../../../earnings/presentation/pages/earnings_screen.dart';
import '../../../earnings/presentation/bloc/earnings_bloc.dart';
import '../../../earnings/presentation/bloc/earnings_event.dart';
import '../../../earnings/presentation/bloc/earnings_state.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/auth_storage_service.dart';
import '../../../../core/services/onboarding_navigation_service.dart';

// --- Spring Physics Click Effect ---
class SpringButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const SpringButton({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  State<SpringButton> createState() => _SpringButtonState();
}

class _SpringButtonState extends State<SpringButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    context.read<WalletBloc>().add(FetchWalletDetailsEvent());
    context.read<EarningsBloc>().add(FetchMyEarningsEvent());
    context
        .read<OrdersBloc>()
        .add(const FetchOrdersEvent(statusFilter: 'upcoming'));
    context.read<ProfileBloc>().add(FetchProfileEvent());

    // Check onboarding status on refresh/load of Home Screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOnboardingStatus();
    });
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final authStorage = di.sl<AuthStorageService>();
      final token = authStorage.getAccessToken();

      if (token == null || token.isEmpty || !mounted) return;

      final role = authStorage.getUserRole();
      if (role != null && role.isNotEmpty) {
        if (role == 'admin') {
          context.go(AppRoutes.adminDashboard);
          return;
        } else if (role == 'marketing' ||
            role == 'marketing_team' ||
            role == 'field_sales') {
          context.go(AppRoutes.marketingDashboard);
          return;
        }
      }

      await OnboardingNavigationService.fetchStatusAndNavigate(
        context,
        configureSession: true,
      );
    } catch (e) {
      debugPrint('Home onboarding status sync failed: $e');
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final status = _getStatusFilterForIndex(_tabController.index);
      context.read<OrdersBloc>().add(FetchOrdersEvent(statusFilter: status));
    }
  }

  String _getStatusFilterForIndex(int index) {
    switch (index) {
      case 0:
        return 'upcoming';
      case 1:
        return 'ongoing';
      case 2:
        return 'completed';
      default:
        return 'upcoming';
    }
  }

  Widget _buildMobileBottomNavBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.darkBorder.withValues(alpha: 0.5)
                : AppColors.border.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex.clamp(0, 1),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        selectedItemColor: AppColors.accent,
        unselectedItemColor:
            isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        selectedLabelStyle:
            GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle:
            GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 12),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            activeIcon: Icon(Icons.home_rounded, color: AppColors.accent),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            activeIcon: Icon(Icons.person_rounded, color: AppColors.accent),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSidebar(BuildContext context, bool isDark) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark
                ? AppColors.darkBorder.withValues(alpha: 0.5)
                : AppColors.border.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Branding Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/AM5 ROYAL TM logo.png',
                  height: 36,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.workspace_premium_rounded,
                      color: AppColors.accent,
                      size: 36),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AM5 ROYAL',
                        style: GoogleFonts.outfit(
                          color: isDark ? Colors.white : AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        'VENDOR PARTNER',
                        style: GoogleFonts.outfit(
                          color: AppColors.accent,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Profile Preview
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, profileState) {
                String vendorName = 'Vendor';
                String initials = 'V';
                if (profileState is ProfileLoaded) {
                  final p = profileState.profile;
                  vendorName =
                      "${p.firstName ?? ''} ${p.lastName ?? ''}".trim();
                  if (vendorName.isEmpty) vendorName = 'Vendor';
                }
                if (vendorName.isNotEmpty) {
                  final parts = vendorName.split(' ');
                  initials = parts.length > 1 &&
                          parts[0].isNotEmpty &&
                          parts[1].isNotEmpty
                      ? "${parts[0][0]}${parts[1][0]}".toUpperCase()
                      : vendorName[0].toUpperCase();
                }
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.02)
                        : Colors.black.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            AppColors.accent.withValues(alpha: 0.15),
                        child: Text(
                          initials,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          capitalize(vendorName),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color:
                                isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Sidebar Nav Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildSidebarNavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  isSelected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildSidebarNavItem(
                  icon: Icons.card_membership_rounded,
                  label: 'Subscriptions',
                  isSelected: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildSidebarNavItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Earnings',
                  isSelected: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildSidebarNavItem(
                  icon: Icons.person_rounded,
                  label: 'My Profile',
                  isSelected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                  isDark: isDark,
                ),
              ],
            ),
          ),
          // Logout at the bottom
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: _buildSidebarNavItem(
              icon: Icons.logout_rounded,
              label: 'Log Out',
              isSelected: false,
              isDanger: true,
              onTap: () => _showLogoutDialog(context),
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    bool isDanger = false,
  }) {
    final activeBgColor = isDark
        ? AppColors.accent.withValues(alpha: 0.12)
        : AppColors.accent.withValues(alpha: 0.1);
    final iconColor = isDanger
        ? AppColors.error
        : (isSelected
            ? AppColors.accent
            : (isDark ? Colors.white60 : Colors.black54));
    final textColor = isDanger
        ? AppColors.error
        : (isSelected
            ? AppColors.accent
            : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary));

    return SpringButton(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeBgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.accent.withValues(alpha: 0.2)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopHomeTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Welcome and Greeting Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, profileState) {
                String vendorName = 'Vendor';
                if (profileState is ProfileLoaded) {
                  final p = profileState.profile;
                  vendorName =
                      "${p.firstName ?? ''} ${p.lastName ?? ''}".trim();
                  if (vendorName.isEmpty) vendorName = 'Vendor';
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getGreeting(),
                      style: GoogleFonts.outfit(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      capitalize(vendorName),
                      style: GoogleFonts.outfit(
                        color: isDark ? Colors.white : AppColors.primary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
            // Quick Action: Subscription Shortcut
            SpringButton(
              onTap: () => setState(() => _currentIndex = 2),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Manage Subscription',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Quick Stats Row Cards
        Row(
          children: [
            // Lifetime Earnings Card
            Expanded(
              child: BlocBuilder<EarningsBloc, EarningsState>(
                builder: (context, state) {
                  double totalEarnings = 0.00;
                  if (state is EarningsLoaded) {
                    totalEarnings = state.earnings.totalEarnings;
                  }
                  return _buildStatCard(
                    title: 'Lifetime Earnings',
                    value: '₹${totalEarnings.toStringAsFixed(2)}',
                    icon: Icons.monetization_on_rounded,
                    color: AppColors.accent,
                    isDark: isDark,
                  );
                },
              ),
            ),
            const SizedBox(width: 20),
            // This Month Earnings Card
            Expanded(
              child: BlocBuilder<EarningsBloc, EarningsState>(
                builder: (context, state) {
                  double thisMonth = 0.00;
                  if (state is EarningsLoaded) {
                    thisMonth = state.earnings.thisMonthEarnings;
                  }
                  return _buildStatCard(
                    title: 'This Month Earnings',
                    value: '₹${thisMonth.toStringAsFixed(2)}',
                    icon: Icons.trending_up_rounded,
                    color: AppColors.success,
                    isDark: isDark,
                  );
                },
              ),
            ),
            const SizedBox(width: 20),
            // Total Bookings Card
            Expanded(
              child: BlocBuilder<OrdersBloc, OrdersState>(
                builder: (context, state) {
                  int total = 0;
                  if (state is OrdersLoaded) {
                    total = state.orders.length;
                  }
                  return _buildStatCard(
                    title: 'Total Bookings',
                    value: '$total Orders',
                    icon: Icons.assignment_rounded,
                    color: AppColors.primary,
                    isDark: isDark,
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        // TabBar + Content card
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? AppColors.darkBorder.withValues(alpha: 0.5)
                    : AppColors.border.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Constrain TabBar alignment to left side
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 500,
                    padding:
                        const EdgeInsets.only(left: 16, top: 16, right: 16),
                    child: _buildTabBar(),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: BlocBuilder<OrdersBloc, OrdersState>(
                    builder: (context, state) {
                      if (state is OrdersLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is OrdersError) {
                        final displayMessage =
                            state.message.toLowerCase() == 'not found'
                                ? 'no orders yet'
                                : state.message;
                        return _buildEmptyState(
                            context, 'No Orders Found', displayMessage);
                      } else if (state is OrdersLoaded) {
                        return TabBarView(
                          controller: _tabController,
                          children: [
                            _buildOrderList(
                                state.orders, ['new', 'ACCEPTED', 'PENDING']),
                            _buildOrderList(state.orders, ['IN_PROGRESS']),
                            _buildOrderList(state.orders, ['COMPLETED']),
                          ],
                        );
                      }
                      return const Center(child: Text('No orders found'));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.9)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.5)
              : AppColors.border.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopProfileTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'My Profile Settings',
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white : AppColors.primary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  // Profile summary card (Single column / horizontal Row representation)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurface.withValues(alpha: 0.9)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder.withValues(alpha: 0.5)
                            : AppColors.border.withValues(alpha: 0.5),
                      ),
                    ),
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        String authName = 'Vendor';
                        String authContact = 'N/A';
                        if (authState is Success) {
                          authName = authState.auth.name ?? 'Vendor';
                          authContact = authState.auth.contact;
                        }

                        return BlocBuilder<ProfileBloc, ProfileState>(
                          builder: (context, profileState) {
                            String vendorName = authName;
                            String vendorContact = authContact;

                            if (profileState is ProfileLoaded) {
                              final p = profileState.profile;
                              final fname = p.firstName ?? '';
                              final lname = p.lastName ?? '';
                              if (fname.isNotEmpty || lname.isNotEmpty) {
                                vendorName = "$fname $lname".trim();
                              }
                              if (p.mobile != null && p.mobile!.isNotEmpty) {
                                vendorContact = p.mobile!;
                              }
                            } else if (profileState is ProfileUpdateSuccess) {
                              final p = profileState.profile;
                              final fname = p.firstName ?? '';
                              final lname = p.lastName ?? '';
                              if (fname.isNotEmpty || lname.isNotEmpty) {
                                vendorName = "$fname $lname".trim();
                              }
                              if (p.mobile != null && p.mobile!.isNotEmpty) {
                                vendorContact = p.mobile!;
                              }
                            }

                            String initials = 'V';
                            if (vendorName.isNotEmpty &&
                                vendorName != 'Vendor') {
                              final parts = vendorName.split(' ');
                              initials = parts.length > 1 &&
                                      parts[0].isNotEmpty &&
                                      parts[1].isNotEmpty
                                  ? "${parts[0][0]}${parts[1][0]}".toUpperCase()
                                  : vendorName[0].toUpperCase();
                            }

                            return Row(
                              children: [
                                CircleAvatar(
                                  radius: 48,
                                  backgroundColor:
                                      AppColors.accent.withValues(alpha: 0.15),
                                  child: Text(
                                    initials,
                                    style: GoogleFonts.outfit(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vendorName,
                                        style: GoogleFonts.outfit(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        vendorContact,
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          color: isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                SpringButton(
                                  onTap: () {
                                    context.push(AppRoutes.editProfile);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.accent
                                            .withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Text(
                                      'Edit Profile Details',
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.accent,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Settings list container
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurface.withValues(alpha: 0.9)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder.withValues(alpha: 0.5)
                            : AppColors.border.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSettingsTile(
                          context: context,
                          icon: Icons.category_rounded,
                          title: 'Category Management',
                          subtitle: 'Add, edit or remove categories & services',
                          onTap: () => context.push(AppRoutes.manageCategories),
                        ),
                        const SizedBox(height: 12),
                        _buildSettingsTile(
                          context: context,
                          icon: Icons.list_alt_rounded,
                          title: 'Listing',
                          subtitle: 'Manage your business listings',
                          onTap: () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Coming Soon',
                                  style: GoogleFonts.outfit(),
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildSettingsTile(
                          context: context,
                          icon: Icons.verified_user_rounded,
                          title: 'Verification Certificate',
                          subtitle:
                              'View your partner registration certificate',
                          onTap: () =>
                              context.push(AppRoutes.verificationCertificate),
                        ),
                        const SizedBox(height: 12),
                        _buildSettingsTile(
                          context: context,
                          icon: Icons.history_edu_rounded,
                          title: 'Our Story',
                          subtitle: 'The journey & vision of AM5ROYAL',
                          onTap: () => context.push(AppRoutes.ourStory),
                        ),
                        const SizedBox(height: 12),
                        _buildSettingsTile(
                          context: context,
                          icon: Icons.security_rounded,
                          title: 'Privacy Policy',
                          subtitle: 'How we guard your identity',
                          onTap: () => context.push(AppRoutes.privacyPolicy),
                        ),
                        const SizedBox(height: 12),
                        _buildSettingsTile(
                          context: context,
                          icon: Icons.article_rounded,
                          title: 'Terms & Conditions',
                          subtitle: 'Vendor service rules & agreements',
                          onTap: () => context.push(AppRoutes.termsConditions),
                        ),
                        const SizedBox(height: 12),
                        _buildSettingsTile(
                          context: context,
                          icon: Icons.contact_support_rounded,
                          title: 'Help & Support',
                          subtitle: 'FAQs & support channels',
                          onTap: () => context.push(AppRoutes.helpSupport),
                        ),
                        const SizedBox(height: 12),
                        _buildSettingsTile(
                          context: context,
                          icon: Icons.policy_rounded,
                          title: 'Account Deletion Policy',
                          subtitle: 'Data retention & deletion rules',
                          onTap: () => context.push(AppRoutes.deleteAccountPolicy),
                        ),
                        const SizedBox(height: 12),
                        _buildSettingsTile(
                          context: context,
                          icon: Icons.delete_forever_rounded,
                          title: 'Delete Account',
                          subtitle: 'Permanently deactivate your profile',
                          isDanger: true,
                          onTap: () => context.push(AppRoutes.deleteAccount),
                        ),
                      ],
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

  Widget _getDesktopTabContent(BuildContext context, int index) {
    switch (index) {
      case 0:
        return _buildDesktopHomeTab(context);
      case 1:
        return _buildDesktopProfileTab(context);
      case 2:
        return const MySubscriptionsScreen(isEmbedded: true);
      case 3:
        return const EarningsScreen(isEmbedded: true);
      default:
        return _buildDesktopHomeTab(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveLayout.isMobile(context);

    return PopScope(
      canPop: false,
      child: isMobile
        ? Scaffold(
            backgroundColor:
                isDark ? AppColors.darkBackground : const Color(0xFFF7FBFF),
            body: Stack(
              children: [
                // Background watercolor mask matching onboarding theme
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/water.png',
                    fit: BoxFit.cover,
                    opacity: AlwaysStoppedAnimation(isDark ? 0.05 : 0.45),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.75)
                        : Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                IndexedStack(
                  index: _currentIndex.clamp(0, 1),
                  children: [
                    _buildHomeTab(context),
                    _buildProfileTab(context),
                  ],
                ),
              ],
            ),
            bottomNavigationBar: _buildMobileBottomNavBar(isDark),
          )
        : Scaffold(
            backgroundColor:
                isDark ? AppColors.darkBackground : const Color(0xFFF7FBFF),
            body: Row(
              children: [
                _buildDesktopSidebar(context, isDark),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/water.png',
                          fit: BoxFit.cover,
                          opacity: AlwaysStoppedAnimation(isDark ? 0.05 : 0.45),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.75)
                              : Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1200),
                              child:
                                  _getDesktopTabContent(context, _currentIndex),
                            ),
                          ),
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

  Widget _buildHomeTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context),
        SliverFillRemaining(
          child: Column(
            children: [
              _buildTabBar(),
              Expanded(
                child: BlocBuilder<OrdersBloc, OrdersState>(
                  builder: (context, state) {
                    if (state is OrdersLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is OrdersError) {
                      final displayMessage =
                          state.message.toLowerCase() == 'not found'
                              ? 'no orders yet'
                              : state.message;
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            displayMessage,
                            style: GoogleFonts.outfit(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    } else if (state is OrdersLoaded) {
                      return TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOrderList(
                              state.orders, ['new', 'ACCEPTED', 'PENDING']),
                          _buildOrderList(state.orders, ['IN_PROGRESS']),
                          _buildOrderList(state.orders, ['COMPLETED']),
                        ],
                      );
                    }
                    return const Center(child: Text('No orders found'));
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 120.0,
          floating: false,
          pinned: true,
          elevation: 0,
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.primary,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'My Profile',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          AppColors.darkSurface.withValues(alpha: 0.8),
                          AppColors.darkBackground
                        ]
                      : [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // User Details Card
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    String authName = 'Vendor';
                    String authContact = 'N/A';
                    if (authState is Success) {
                      authName = authState.auth.name ?? 'Vendor';
                      authContact = authState.auth.contact;
                    }

                    return BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (context, profileState) {
                        String vendorName = authName;
                        String vendorContact = authContact;
                        String? vendorStatus;

                        if (profileState is ProfileLoaded) {
                          final p = profileState.profile;
                          vendorStatus = p.status;
                          final fname = p.firstName ?? '';
                          final lname = p.lastName ?? '';
                          if (fname.isNotEmpty || lname.isNotEmpty) {
                            vendorName = "$fname $lname".trim();
                          }
                          if (p.mobile != null && p.mobile!.isNotEmpty) {
                            vendorContact = p.mobile!;
                          }
                        } else if (profileState is ProfileUpdateSuccess) {
                          final p = profileState.profile;
                          vendorStatus = p.status;
                          final fname = p.firstName ?? '';
                          final lname = p.lastName ?? '';
                          if (fname.isNotEmpty || lname.isNotEmpty) {
                            vendorName = "$fname $lname".trim();
                          }
                          if (p.mobile != null && p.mobile!.isNotEmpty) {
                            vendorContact = p.mobile!;
                          }
                        }

                        final normStatus = (vendorStatus ?? '')
                            .toLowerCase()
                            .replaceAll(' ', '_');
                        final isTemporaryActive =
                            normStatus == 'temporary_active';

                        // Generate initials
                        String initials = 'V';
                        if (vendorName.isNotEmpty && vendorName != 'Vendor') {
                          final parts = vendorName.split(' ');
                          if (parts.length > 1 &&
                              parts[0].isNotEmpty &&
                              parts[1].isNotEmpty) {
                            initials =
                                "${parts[0][0]}${parts[1][0]}".toUpperCase();
                          } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
                            initials = parts[0][0].toUpperCase();
                          }
                        }

                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkSurface
                                        .withValues(alpha: 0.9)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.darkBorder
                                          .withValues(alpha: 0.5)
                                      : AppColors.border.withValues(alpha: 0.5),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 34,
                                        backgroundColor: AppColors.accent
                                            .withValues(alpha: 0.18),
                                        child: Text(
                                          initials,
                                          style: GoogleFonts.outfit(
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.accent,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              vendorName,
                                              style: GoogleFonts.outfit(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? AppColors.darkTextPrimary
                                                    : AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              vendorContact,
                                              style: GoogleFonts.outfit(
                                                fontSize: 13,
                                                color: isDark
                                                    ? AppColors
                                                        .darkTextSecondary
                                                    : AppColors.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            SpringButton(
                                              onTap: () {
                                                context.push(AppRoutes.editProfile);
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: AppColors.accent
                                                      .withValues(alpha: 0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: AppColors.accent
                                                        .withValues(alpha: 0.3),
                                                  ),
                                                ),
                                                child: Text(
                                                  'Edit Profile',
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.accent,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isTemporaryActive) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isDark
                                              ? [
                                                  Colors.amber.shade900
                                                      .withValues(alpha: 0.25),
                                                  Colors.amber.shade800
                                                      .withValues(alpha: 0.15),
                                                ]
                                              : [
                                                  const Color(0xFFFFF8E1),
                                                  const Color(0xFFFFECB3),
                                                ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.amber.shade400
                                              .withValues(alpha: 0.5),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.amber.shade700
                                                  .withValues(alpha: 0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.hourglass_top_rounded,
                                              size: 16,
                                              color: isDark
                                                  ? Colors.amber.shade300
                                                  : Colors.amber.shade900,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Verification Pending',
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDark
                                                        ? Colors.amber.shade300
                                                        : Colors.amber.shade900,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Your verification is in progress. Our verification department will call you for verification within 7 working days.',
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    color: isDark
                                                        ? Colors.amber.shade200
                                                        : const Color(
                                                            0xFF7A4F01),
                                                    height: 1.35,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildSettingsTile(
                              context: context,
                              icon: Icons.category_rounded,
                              title: 'Category Management',
                              subtitle:
                                  'Add, edit or remove categories & services',
                              isLocked: isTemporaryActive,
                              onTap: () => context.push(AppRoutes.manageCategories),
                            ),
                            _buildSettingsTile(
                              context: context,
                              icon: Icons.list_alt_rounded,
                              title: 'Listing',
                              subtitle: 'Manage your business listings',
                              isLocked: isTemporaryActive,
                              onTap: () {
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Coming Soon',
                                      style: GoogleFonts.outfit(),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                            _buildSettingsTile(
                              context: context,
                              icon: Icons.dashboard_rounded,
                              title: 'Vendor Dashboard',
                              subtitle: 'Analytics, service count & KPIs',
                              isLocked: isTemporaryActive,
                              onTap: () => context.push(AppRoutes.vendorDashboard),
                            ),
                            _buildSettingsTile(
                              context: context,
                              icon: Icons.local_offer_rounded,
                              title: 'Offers & Media',
                              subtitle:
                                  'Promotions, photos/videos & new launches',
                              isLocked: isTemporaryActive,
                              onTap: () => context.push(AppRoutes.offersLaunches),
                            ),
                            _buildSettingsTile(
                              context: context,
                              icon: Icons.card_membership_rounded,
                              title: 'My Subscriptions',
                              subtitle: 'Upgrade & manage your plan',
                              isLocked: isTemporaryActive,
                              onTap: () => context.push(AppRoutes.mySubscriptions),
                            ),
                            _buildSettingsTile(
                              context: context,
                              icon: Icons.verified_user_rounded,
                              title: 'Verification Certificate',
                              subtitle:
                                  'View your partner registration certificate',
                              isLocked: isTemporaryActive,
                              onTap: () =>
                                  context.push(AppRoutes.verificationCertificate),
                            ),
                            _buildSettingsTile(
                              context: context,
                              icon: Icons.bar_chart_rounded,
                              title: 'My Earnings',
                              subtitle: 'Monthly stats & cashouts',
                              isLocked: isTemporaryActive,
                              onTap: () => context.push(AppRoutes.earnings),
                            ),
                            _buildSettingsTile(
                              context: context,
                              icon: Icons.history_edu_rounded,
                              title: 'Our Story',
                              subtitle: 'The journey & vision of AM5ROYAL',
                              onTap: () => context.push(AppRoutes.ourStory),
                            ),
                            _buildSettingsTile(
                              context: context,
                              icon: Icons.security_rounded,
                              title: 'Privacy Policy',
                              subtitle: 'How we guard your identity',
                              onTap: () => context.push(AppRoutes.privacyPolicy),
                            ),
                            _buildSettingsTile(
                              context: context,
                              icon: Icons.article_rounded,
                              title: 'Terms & Conditions',
                              subtitle: 'Vendor service rules & agreements',
                              onTap: () => context.push(AppRoutes.termsConditions),
                            ),
                            _buildSettingsTile(
                              context: context,
                              icon: Icons.contact_support_rounded,
                              title: 'Help & Support',
                              subtitle: 'FAQs & support channels',
                              onTap: () => context.push(AppRoutes.helpSupport),
                            ),
                            _buildSettingsTile(
                              context: context,
                              icon: Icons.policy_rounded,
                              title: 'Account Deletion Policy',
                              subtitle: 'Data retention & deletion rules',
                              onTap: () => context.push(AppRoutes.deleteAccountPolicy),
                            ),
                            _buildSettingsTile(
                              context: context,
                              icon: Icons.delete_forever_rounded,
                              title: 'Delete Account',
                              subtitle: 'Permanently deactivate your profile',
                              isDanger: true,
                              onTap: () => context.push(AppRoutes.deleteAccount),
                            ),
                            _buildSettingsTile(
                              context: context,
                              icon: Icons.logout_rounded,
                              title: 'Log Out',
                              subtitle: 'Sign out of your session safely',
                              isDanger: true,
                              onTap: () => _showLogoutDialog(context),
                            ),
                            const SizedBox(height: 40),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDanger = false,
    bool isLocked = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isLocked
        ? Colors.grey
        : (isDanger ? AppColors.error : AppColors.primaryLight);
    final textColor = isLocked
        ? Colors.grey
        : (isDanger
            ? AppColors.error
            : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SpringButton(
        onTap: () {
          if (isLocked) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Your account is under verification. Our department will verify within 7 working days.',
                  style: GoogleFonts.outfit(),
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.orange.shade800,
              ),
            );
          } else {
            onTap();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface.withValues(alpha: 0.85)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppColors.darkBorder.withValues(alpha: 0.5)
                  : AppColors.border.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isLocked
                    ? Icons.lock_outline_rounded
                    : Icons.chevron_right_rounded,
                color: isLocked
                    ? Colors.amber.shade700
                    : (isDark
                        ? AppColors.darkTextSecondary.withValues(alpha: 0.5)
                        : AppColors.textSecondary.withValues(alpha: 0.5)),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkSurface
              : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Confirm Log Out',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to end your current session?',
            style: GoogleFonts.outfit(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: GoogleFonts.outfit(
                    color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            SpringButton(
              onTap: () {
                Navigator.pop(dialogContext);
                // Dispatch logout event
                context.read<AuthBloc>().add(const AuthEvent.logout());
                // Navigate to Login page and clear stack
                context.go(AppRoutes.login);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Log Out',
                  style: GoogleFonts.outfit(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/water.png',
                fit: BoxFit.cover,
                opacity: AlwaysStoppedAnimation(isDark ? 0.08 : 0.45),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            AppColors.darkSurface.withValues(alpha: 0.7),
                            AppColors.darkBackground.withValues(alpha: 0.95),
                          ]
                        : [
                            AppColors.primary.withValues(alpha: 0.9),
                            AppColors.primaryDark.withValues(alpha: 0.95),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        String authName = 'Vendor';
                        if (authState is Success) {
                          authName = authState.auth.name ?? 'Vendor';
                        }
                        return BlocBuilder<ProfileBloc, ProfileState>(
                          builder: (context, profileState) {
                            String vendorName = authName;
                            if (profileState is ProfileLoaded) {
                              final p = profileState.profile;
                              final fname = p.firstName ?? '';
                              final lname = p.lastName ?? '';
                              if (fname.isNotEmpty || lname.isNotEmpty) {
                                vendorName = "$fname $lname".trim();
                              }
                            } else if (profileState is ProfileUpdateSuccess) {
                              final p = profileState.profile;
                              final fname = p.firstName ?? '';
                              final lname = p.lastName ?? '';
                              if (fname.isNotEmpty || lname.isNotEmpty) {
                                vendorName = "$fname $lname".trim();
                              }
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  getGreeting(),
                                  style: GoogleFonts.outfit(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  capitalize(vendorName),
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    // Glassmorphic interactive Wallet Balance Card (Commented out for now)
                    /*
                    SpringButton(
                      onTap: () {
                        final walletBloc = context.read<WalletBloc>();
                        final ordersBloc = context.read<OrdersBloc>();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const WalletScreen()),
                        ).then((_) {
                          walletBloc.add(FetchWalletDetailsEvent());
                          ordersBloc.add(FetchOrdersEvent(
                              statusFilter: _getStatusFilterForIndex(_tabController.index)));
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.accentLight.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet_rounded,
                                    color: AppColors.accentLight,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Wallet Balance',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white.withValues(alpha: 0.65),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Manage your funds',
                                      style: GoogleFonts.outfit(
                                        color: AppColors.accentLight,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            BlocBuilder<WalletBloc, WalletState>(
                              builder: (context, state) {
                                String balance = '₹0.00';
                                if (state is WalletLoaded) {
                                  balance =
                                      '₹${state.walletDetails.balance.toStringAsFixed(2)}';
                                }
                                return Row(
                                  children: [
                                    Text(
                                      balance,
                                      style: GoogleFonts.jetBrainsMono(
                                        color: Colors.white,
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: Colors.white60,
                                      size: 20,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    */
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurface.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? AppColors.darkBorder.withValues(alpha: 0.5)
                : AppColors.border.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor:
              isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          dividerColor: Colors.transparent,
          labelStyle:
              GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle:
              GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 13),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Ongoing'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String title, String subtitle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_turned_in_rounded,
                color: AppColors.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<OrderEntity> orders, List<String> statuses) {
    final filteredOrders =
        orders.where((o) => statuses.contains(o.status)).toList();

    if (filteredOrders.isEmpty) {
      String title = "No Upcoming Orders";
      String subtitle = "New bookings from customers will appear here.";
      if (statuses.contains('IN_PROGRESS')) {
        title = "No Ongoing Tasks";
        subtitle = "Active bookings you are working on will appear here.";
      } else if (statuses.contains('COMPLETED')) {
        title = "No Completed History";
        subtitle = "History of your successfully finished orders.";
      }
      return _buildEmptyState(context, title, subtitle);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrdersBloc>().add(FetchOrdersEvent(
            statusFilter: _getStatusFilterForIndex(_tabController.index)));
        context.read<WalletBloc>().add(FetchWalletDetailsEvent());
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];

          return SpringButton(
            onTap: () {
              final ordersBloc = context.read<OrdersBloc>();
              final walletBloc = context.read<WalletBloc>();
              context
                  .push(
                AppRoutes.orderDetails(order.id),
                extra: order,
              )
                  .then((_) {
                ordersBloc.add(FetchOrdersEvent(
                    statusFilter:
                        _getStatusFilterForIndex(_tabController.index)));
                walletBloc.add(FetchWalletDetailsEvent());
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface.withValues(alpha: 0.85)
                    : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorder.withValues(alpha: 0.6)
                      : AppColors.border.withValues(alpha: 0.8),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkSurfaceVariant
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'REF: ${order.bookingReference}',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _getStatusBgColor(order.status, isDark),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _getStatusColor(order.status)
                                      .withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _getFriendlyStatusText(order.status)
                                    .toUpperCase(),
                                style: GoogleFonts.outfit(
                                  color: _getStatusColor(order.status),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          order.serviceName ?? 'General Service',
                          style: GoogleFonts.outfit(
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkSurfaceVariant
                                    : Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person_outline_rounded,
                                size: 14,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              (order.customerName == null ||
                                      order.customerName!.isEmpty ||
                                      order.customerName == 'N/A')
                                  ? 'Client Account'
                                  : order.customerName!,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkSurfaceVariant
                                    : Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.calendar_today_rounded,
                                size: 13,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${order.bookingDate ?? "Today"} • ${order.bookingTime ?? "Anytime"}',
                              style: GoogleFonts.outfit(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkSurfaceVariant
                                    : Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                order.serviceAddress ?? 'No address provided',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontSize: 12.5,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 1,
                    color: isDark
                        ? AppColors.darkBorder.withValues(alpha: 0.4)
                        : AppColors.border.withValues(alpha: 0.4),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'View Order Details',
                          style: GoogleFonts.outfit(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.accentLight
                                : AppColors.primaryLight,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 15,
                          color: isDark
                              ? AppColors.accentLight
                              : AppColors.primaryLight,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'NEW':
      case 'PENDING':
        return AppColors.statusPending;
      case 'ACCEPTED':
        return AppColors.statusConfirmed;
      case 'IN_PROGRESS':
        return AppColors.statusInProgress;
      case 'COMPLETED':
        return AppColors.statusCompleted;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusBgColor(String status, bool isDark) {
    final baseColor = _getStatusColor(status);
    return baseColor.withValues(alpha: isDark ? 0.15 : 0.08);
  }

  String _getFriendlyStatusText(String status) {
    if (status.toLowerCase() == 'new') return 'New';
    if (status.toLowerCase() == 'accepted') return 'Accepted';
    if (status.toLowerCase() == 'pending') return 'Pending';
    if (status.toLowerCase() == 'in_progress') return 'Ongoing';
    if (status.toLowerCase() == 'completed') return 'Completed';
    return status;
  }
}
