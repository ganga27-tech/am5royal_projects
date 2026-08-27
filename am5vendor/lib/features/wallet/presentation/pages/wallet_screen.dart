import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_razorpay.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';
import '../../domain/entities/wallet_entity.dart';

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

class _SpringButtonState extends State<SpringButton> with SingleTickerProviderStateMixin {
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

// --- Skeletal Shimmer Pulse Widget ---
class PulseSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const PulseSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<PulseSkeleton> createState() => _PulseSkeletonState();
}

class _PulseSkeletonState extends State<PulseSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _opacityAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : Colors.grey[300],
          borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// --- Pulsing Crown Badge Icon (Banned Circular Spinner replacement) ---
class PulseBadgeIcon extends StatefulWidget {
  const PulseBadgeIcon({super.key});

  @override
  State<PulseBadgeIcon> createState() => _PulseBadgeIconState();
}

class _PulseBadgeIconState extends State<PulseBadgeIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.15).animate(
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: const Icon(
          Icons.workspace_premium_rounded,
          color: AppColors.accent,
          size: 32,
        ),
      ),
    );
  }
}

// --- Wallet Main Screen Widget ---
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<WalletBloc>()..add(FetchWalletDetailsEvent()),
      child: const WalletView(),
    );
  }
}

class WalletView extends StatefulWidget {
  const WalletView({super.key});

  @override
  State<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  late AppRazorpay _razorpay;
  final TextEditingController _amountController = TextEditingController();
  WalletDetailsEntity? _cachedWallet;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _razorpay = getRazorpay();
    _razorpay.init(
      onSuccess: _handlePaymentSuccess,
      onError: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    _amountController.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(String paymentId, String orderId, String signature) {
    context.read<WalletBloc>().add(VerifyTopupEvent(
          paymentId: paymentId,
          orderId: orderId,
          signature: signature,
          amount: double.tryParse(_amountController.text) ?? 0,
        ));
  }

  void _handlePaymentError(String message, int? code) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: $message')),
    );
  }

  void _handleExternalWallet(String walletName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet: $walletName')),
    );
  }

  void _openCheckout(String orderId, double amount, String key) {
    var options = {
      'key': key,
      'amount': (amount * 100).toInt(),
      'name': 'Vendor Wallet Topup',
      'order_id': orderId,
      'prefill': {
        'contact': '9999999999',
        'email': 'vendor@example.com'
      }
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  /*
  void _showTopupDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 1,
            ),
          ),
          title: Text(
            'Topup Wallet',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter the amount you wish to add to your royal wallet balance.',
                style: GoogleFonts.outfit(
                  fontSize: 13.5,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.outfit(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: GoogleFonts.outfit(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                  labelText: 'Amount',
                  labelStyle: GoogleFonts.outfit(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.accent,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.outfit(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SpringButton(
              onTap: () {
                final amount = double.tryParse(_amountController.text);
                if (amount != null && amount > 0) {
                  Navigator.pop(ctx);
                  context.read<WalletBloc>().add(TopupWalletEvent(amount: amount));
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  'Proceed',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShortcutButton(BuildContext context, double amount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SpringButton(
      onTap: () {
        _amountController.text = amount.toInt().toString();
        context.read<WalletBloc>().add(TopupWalletEvent(amount: amount));
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark 
              ? AppColors.darkSurface.withValues(alpha: 0.9) 
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark 
                ? AppColors.darkBorder.withValues(alpha: 0.6) 
                : AppColors.border.withValues(alpha: 0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            '+ ₹${amount.toInt()}',
            style: GoogleFonts.outfit(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
  */

  Widget _buildFilterChip(BuildContext context, String filter) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedFilter == filter;

    return SpringButton(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected
              ? null
              : (isDark
                  ? AppColors.darkSurface.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.8)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.3)
                : (isDark
                    ? AppColors.darkBorder.withValues(alpha: 0.5)
                    : AppColors.border.withValues(alpha: 0.5)),
            width: 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Text(
          filter,
          style: GoogleFonts.outfit(
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }

  Widget _buildWalletSkeleton(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Card skeleton
        PulseSkeleton(
          width: double.infinity,
          height: 190,
          borderRadius: BorderRadius.circular(24),
        ),
        const SizedBox(height: 18),
        // Stats grid skeleton
        Row(
          children: [
            Expanded(
              child: PulseSkeleton(
                width: double.infinity,
                height: 72,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: PulseSkeleton(
                width: double.infinity,
                height: 72,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Presets header skeleton
        Align(
          alignment: Alignment.centerLeft,
          child: PulseSkeleton(
            width: 100,
            height: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 12),
        // Presets buttons row skeleton
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) => PulseSkeleton(
            width: (MediaQuery.of(context).size.width - 32 - 36) / 4,
            height: 44,
            borderRadius: BorderRadius.circular(16),
          )),
        ),
        const SizedBox(height: 28),
        // Transaction list header skeleton
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PulseSkeleton(width: 140, height: 18, borderRadius: BorderRadius.circular(4)),
            PulseSkeleton(width: 50, height: 14, borderRadius: BorderRadius.circular(4)),
          ],
        ),
        const SizedBox(height: 16),
        // Transaction rows skeletons
        ...List.generate(3, (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PulseSkeleton(
            width: double.infinity,
            height: 76,
            borderRadius: BorderRadius.circular(18),
          ),
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF7FBFF),
      appBar: AppBar(
        title: Text(
          'My Wallet',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppColors.primary,
        ),
      ),
      body: Stack(
        children: [
          // Watercolor background atmosphere matching onboarding
          Positioned.fill(
            child: Image.asset(
              'assets/images/water.png',
              fit: BoxFit.cover,
              opacity: AlwaysStoppedAnimation(isDark ? 0.08 : 0.7),
            ),
          ),
          Positioned.fill(
            child: Container(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.25),
            ),
          ),
          SafeArea(
            child: BlocConsumer<WalletBloc, WalletState>(
              listener: (context, state) {
                if (state is WalletTopupInitiated) {
                  _openCheckout(
                    state.topupResponse.orderId,
                    state.topupResponse.amount,
                    state.topupResponse.key,
                  );
                } else if (state is WalletTopupSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Topup Successful!')),
                  );
                  context.read<WalletBloc>().add(FetchWalletDetailsEvent());
                } else if (state is WalletError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                if (state is WalletLoaded) {
                  _cachedWallet = state.walletDetails;
                }

                final isLoading = state is WalletLoading;

                if (_cachedWallet == null) {
                  if (isLoading) {
                    return _buildWalletSkeleton(context);
                  } else if (state is WalletError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: GoogleFonts.outfit(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SpringButton(
                            onTap: () {
                              context.read<WalletBloc>().add(FetchWalletDetailsEvent());
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Retry',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return _buildWalletSkeleton(context);
                }

                final filteredTransactions = _cachedWallet!.transactions.where((tx) {
                  if (_selectedFilter == 'All') return true;
                  if (_selectedFilter == 'Credits') return tx.transactionType == 'credit';
                  if (_selectedFilter == 'Debits') return tx.transactionType == 'debit';
                  return true;
                }).toList();

                return Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: () async {
                        context.read<WalletBloc>().add(FetchWalletDetailsEvent());
                      },
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 24),
                        children: [
                          // Premium Credit-Card Style Balance Card
                          Container(
                            height: 190,
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: isDark
                                  ? const LinearGradient(
                                      colors: [
                                        AppColors.darkSurfaceVariant,
                                        AppColors.darkSurface,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : const LinearGradient(
                                      colors: [
                                        AppColors.primaryLight,
                                        AppColors.primary,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                              border: Border.all(
                                color: AppColors.accent.withValues(alpha: isDark ? 0.25 : 0.45),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (isDark ? AppColors.darkSurface : AppColors.primary)
                                      .withValues(alpha: 0.25),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Stack(
                                children: [
                                  // Translucent organic glass reflections
                                  Positioned(
                                    right: -30,
                                    top: -30,
                                    child: Container(
                                      width: 160,
                                      height: 160,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.white.withValues(alpha: 0.08),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: -40,
                                    bottom: -40,
                                    child: Container(
                                      width: 140,
                                      height: 140,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.white.withValues(alpha: 0.04),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(22.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Header Row: Brand & Icon
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'AM5 ROYAL PARTNER',
                                              style: GoogleFonts.outfit(
                                                color: Colors.white.withValues(alpha: 0.8),
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                            const Icon(
                                              Icons.workspace_premium_rounded,
                                              color: AppColors.accentLight,
                                              size: 24,
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        // Main Content Row: Info on Left, Top Up Button on Right
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            // Left: Available Balance & Reward points
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Available Balance',
                                                    style: GoogleFonts.outfit(
                                                      color: Colors.white.withValues(alpha: 0.65),
                                                      fontSize: 12.5,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '₹${_cachedWallet!.balance.toStringAsFixed(2)}',
                                                    style: GoogleFonts.outfit(
                                                      color: Colors.white,
                                                      fontSize: 34,
                                                      fontWeight: FontWeight.w900,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  // Reward points capsule
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withValues(alpha: 0.12),
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(
                                                        color: Colors.white.withValues(alpha: 0.15),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const Icon(
                                                          Icons.stars_rounded,
                                                          color: AppColors.accentLight,
                                                          size: 14,
                                                        ),
                                                        const SizedBox(width: 5),
                                                        Text(
                                                          '${_cachedWallet!.rewardPoints} Reward Points',
                                                          style: GoogleFonts.outfit(
                                                            color: Colors.white,
                                                            fontSize: 10.5,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Right: Elegant Top Up Button (Commented out for now)
                                            /*
                                            SpringButton(
                                              onTap: () => _showTopupDialog(context),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                decoration: BoxDecoration(
                                                  gradient: AppColors.accentGradient,
                                                  borderRadius: BorderRadius.circular(16),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppColors.accent.withValues(alpha: 0.3),
                                                      blurRadius: 10,
                                                      offset: const Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.add_rounded,
                                                      color: AppColors.primaryDark,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Top Up',
                                                      style: GoogleFonts.outfit(
                                                        fontWeight: FontWeight.bold,
                                                        color: AppColors.primaryDark,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            */
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Stats grid: Total Earned and Reward points
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.darkSurface.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isDark ? AppColors.darkBorder.withValues(alpha: 0.5) : AppColors.border.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: AppColors.success.withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.trending_up_rounded,
                                            color: AppColors.success,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Total Earned',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 11,
                                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '₹${_cachedWallet!.totalEarned.toStringAsFixed(2)}',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 15,
                                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.darkSurface.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isDark ? AppColors.darkBorder.withValues(alpha: 0.5) : AppColors.border.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: AppColors.accent.withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.stars_rounded,
                                            color: AppColors.accent,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Reward Tier',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 11,
                                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${_cachedWallet!.rewardPoints} PTS',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 15,
                                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                                  fontWeight: FontWeight.bold,
                                                ),
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
                          ),
                          // Actions Panel Label (Commented out for now)
                          /*
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20, top: 22, bottom: 8),
                            child: Text(
                              'Quick Top Up',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          // Shortcuts Row
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildShortcutButton(context, 100),
                                _buildShortcutButton(context, 500),
                                _buildShortcutButton(context, 1000),
                                SpringButton(
                                  onTap: () => _showTopupDialog(context),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.darkSurface.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isDark ? AppColors.darkBorder.withValues(alpha: 0.6) : AppColors.border.withValues(alpha: 0.6),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.02),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.add_rounded,
                                            color: isDark ? AppColors.accentLight : AppColors.accent,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Custom',
                                            style: GoogleFonts.outfit(
                                              color: isDark ? AppColors.accentLight : AppColors.accent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          */
                          // Transactions Header
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20, top: 26, bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Recent Transactions',
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'History',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.accentLight : AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Transaction Filter Chips Row
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                _buildFilterChip(context, 'All'),
                                const SizedBox(width: 8),
                                _buildFilterChip(context, 'Credits'),
                                const SizedBox(width: 8),
                                _buildFilterChip(context, 'Debits'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Transaction Card stack
                          ...filteredTransactions.map((tx) {
                            final isCredit = tx.transactionType == 'credit';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurface.withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isDark 
                                      ? AppColors.darkBorder.withValues(alpha: 0.6) 
                                      : AppColors.border.withValues(alpha: 0.6),
                                  width: 1,
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
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isCredit
                                          ? AppColors.success.withValues(alpha: 0.1)
                                          : AppColors.error.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                      color: isCredit ? AppColors.success : AppColors.error,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tx.description ?? 'Wallet Transaction',
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13.5,
                                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          tx.createdAt.toLocal().toString().split('.')[0],
                                          style: GoogleFonts.outfit(
                                            fontSize: 11,
                                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${isCredit ? '+' : '-'}₹${tx.amount.abs().toStringAsFixed(2)}',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                      color: isCredit ? AppColors.success : AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          if (filteredTransactions.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.history_rounded,
                                      size: 48,
                                      color: isDark 
                                          ? AppColors.darkTextSecondary.withValues(alpha: 0.3) 
                                          : AppColors.textSecondary.withValues(alpha: 0.3),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No transactions found',
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                    if (isLoading)
                      Container(
                        color: Colors.black.withValues(alpha: 0.35),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : AppColors.border,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const PulseBadgeIcon(),
                                const SizedBox(height: 14),
                                Text(
                                  'Processing payment...',
                                  style: GoogleFonts.outfit(
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
