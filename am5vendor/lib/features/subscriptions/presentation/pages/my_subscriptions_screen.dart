import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../bloc/my_subscriptions_bloc.dart';
import '../bloc/my_subscriptions_event.dart';
import '../bloc/my_subscriptions_state.dart';

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

class MySubscriptionsScreen extends StatefulWidget {
  final bool isEmbedded;
  const MySubscriptionsScreen({super.key, this.isEmbedded = false});

  @override
  State<MySubscriptionsScreen> createState() => _MySubscriptionsScreenState();
}

class _MySubscriptionsScreenState extends State<MySubscriptionsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    context.read<MySubscriptionsBloc>().add(FetchMySubscriptionsEvent());
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Stack(
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
        BlocBuilder<MySubscriptionsBloc, MySubscriptionsState>(
          builder: (context, state) {
            if (state is MySubscriptionsLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              );
            } else if (state is MySubscriptionsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: GoogleFonts.outfit(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SpringButton(
                        onTap: () => context.read<MySubscriptionsBloc>().add(FetchMySubscriptionsEvent()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
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
                ),
              );
            } else if (state is MySubscriptionsLoaded) {
              if (state.subscriptions.isEmpty) {
                return _buildEmptyState(isDark);
              }
              return FadeTransition(
                opacity: _fadeAnimation,
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<MySubscriptionsBloc>().add(FetchMySubscriptionsEvent());
                  },
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20.0),
                    itemCount: state.subscriptions.length,
                    itemBuilder: (context, index) {
                      final sub = state.subscriptions[index];
                      return _buildSubscriptionCard(sub, isDark);
                    },
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );

    if (widget.isEmbedded) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF7FBFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Subscriptions',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: content,
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF0F5FA),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.card_membership_rounded,
                size: 80,
                color: isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.5) : AppColors.textHint,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Subscriptions Yet',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Subscribe to a plan to start receiving premium service leads and visibility boost.',
              style: GoogleFonts.outfit(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(dynamic sub, bool isDark) {
    final bool isActive = sub.status.toLowerCase() == 'active';
    final DateFormat formatter = DateFormat('MMM dd, yyyy');
    final plan = sub.plan;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder.withValues(alpha: 0.5) : AppColors.border.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: isActive
                  ? AppColors.primary
                  : (isDark ? AppColors.darkSurfaceVariant : const Color(0xFFE9F1FC)),
              child: Row(
                children: [
                  Icon(
                    Icons.card_membership_rounded,
                    color: isActive
                        ? AppColors.accent
                        : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      plan?.name ?? 'Unknown Plan',
                      style: GoogleFonts.outfit(
                        color: isActive
                            ? Colors.white
                            : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.accent
                          : (isDark ? AppColors.darkBorder : const Color(0xFFD5E1F0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isActive ? 'ACTIVE' : sub.status.toUpperCase(),
                      style: GoogleFonts.outfit(
                        color: isActive
                            ? Colors.white
                            : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Details Body
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 3-Column Info Ticket Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Valid From
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VALID FROM',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              formatter.format(sub.startDate),
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Divider
                      Container(
                        height: 32,
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        color: isDark 
                            ? AppColors.darkBorder.withValues(alpha: 0.5) 
                            : AppColors.border.withValues(alpha: 0.5),
                      ),
                      // Valid Until
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VALID UNTIL',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              formatter.format(sub.endDate),
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Divider
                      Container(
                        height: 32,
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        color: isDark 
                            ? AppColors.darkBorder.withValues(alpha: 0.5) 
                            : AppColors.border.withValues(alpha: 0.5),
                      ),
                      // Price Paid
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PRICE PAID',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              plan != null ? '₹${plan.price.toStringAsFixed(2)}' : 'N/A',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  if (plan != null && plan.features != null && plan.features.isNotEmpty) ...[
                    const Divider(height: 40, thickness: 1),
                    Text(
                      'PLAN BENEFITS',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (plan.features != null)
                          ...plan.features.map<Widget>((feature) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 16,
                                    color: isDark ? AppColors.accentLight : AppColors.accent,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      feature,
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        if (plan.disabledFeatures != null)
                          ...plan.disabledFeatures.map<Widget>((disabledFeature) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 16,
                                    color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      disabledFeature,
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        color: isDark
                                            ? const Color(0xFF9CA3AF)
                                            : const Color(0xFF6B7280),
                                        decoration: TextDecoration.lineThrough,
                                        decorationThickness: 1.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
