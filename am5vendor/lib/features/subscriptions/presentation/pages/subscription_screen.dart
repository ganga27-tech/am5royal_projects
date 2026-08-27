import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/constants/colors.dart';
import '../../../../core/services/onboarding_session_guard.dart';
import '../../../../core/services/payment_return_coordinator.dart';
import '../../../../core/services/payment_session_service.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/utils/app_razorpay.dart';
import '../../../../core/utils/razorpay_checkout_helper.dart';
import '../../../../core/utils/razorpay_checkout_options.dart';
import '../../../products/data/models/product_model.dart';
import '../../domain/entities/subscription_plan_entity.dart';
import '../../domain/entities/my_subscription_entity.dart';
import '../../domain/usecases/recover_payment_usecase.dart';
import '../bloc/subscription_bloc.dart';
import '../bloc/subscription_event.dart';
import '../bloc/subscription_state.dart';

class SubscriptionScreen extends StatefulWidget {
  final bool fromOnboarding;
  final bool recoverPayment;
  final bool isSingleService;
  final List<SubCategoryItem> selectedSubCategories;

  const SubscriptionScreen({
    super.key,
    this.fromOnboarding = false,
    this.recoverPayment = false,
    this.isSingleService = true,
    this.selectedSubCategories = const [],
  });

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  static const _razorpayKey = 'rzp_live_TKoWIICulRFoyv';
  static const _razorpayPaymentCancelledCode = 2;

  int? _processingPlanId;
  List<SubscriptionPlanEntity>? _displayPlans;
  MySubscriptionEntity? _activeSubscription;
  late SubscriptionBloc _subscriptionBloc;
  late AppRazorpay _razorpay;
  late RecoverPaymentUseCase _recoverPayment;

  String? _pendingOrderId;
  bool _checkoutOpened = false;
  bool _isVerifying = false;

  final Map<int, bool> _termsExpandedPlans = {};
  final Map<int, bool> _termsAcceptedPlans = {};

  late AnimationController _badgePulseController;
  late Animation<double> _badgeScaleAnimation;

  late AnimationController _sparkleRotateController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _badgePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _badgeScaleAnimation = Tween<double>(begin: 0.96, end: 1.05).animate(
      CurvedAnimation(
        parent: _badgePulseController,
        curve: Curves.easeInOut,
      ),
    );

    _sparkleRotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _recoverPayment = di.sl<RecoverPaymentUseCase>();
    _subscriptionBloc = di.sl<SubscriptionBloc>()
      ..add(CancelLoadingEvent())
      ..add(FetchSubscriptionsEvent());

    _razorpay = getRazorpay();
    _razorpay.init(
      onSuccess: _handlePaymentSuccess,
      onError: _handlePaymentError,
      onExternalWallet: (_) {},
    );

    if (widget.recoverPayment) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _silentRecoverPayment();
      });
    }
  }

  @override
  void dispose() {
    _badgePulseController.dispose();
    _sparkleRotateController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    RazorpayCheckoutHelper.setAutoDismissEnabled(false);
    _razorpay.clear();
    _subscriptionBloc.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _checkoutOpened) {
      PaymentReturnCoordinator.onReturnFromUpi(GoRouter.of(context));
    }
  }

  Future<void> _launchRazorpay(Map<String, dynamic> orderData) async {
    final orderId = orderData['order_id']?.toString();
    final planId = _processingPlanId;
    if (orderId == null || planId == null) {
      _showPaymentMessage('Unable to start payment. Please try again.');
      return;
    }

    _pendingOrderId = orderId;

    await di.sl<PaymentSessionService>().saveCheckoutSession(
          orderId: orderId,
          planId: planId,
          orderData: orderData,
        );

    final amount = orderData['amount'];
    final parsedAmount =
        amount is int ? amount : int.tryParse(amount?.toString() ?? '') ?? 0;

    final options = await RazorpayCheckoutOptions.build(
      razorpayKey: _razorpayKey,
      amount: parsedAmount,
      orderId: orderId,
      description: orderData['plan_name']?.toString() ?? 'Subscription',
      currency: orderData['currency']?.toString() ?? 'INR',
    );

    final prefill = options['prefill'];
    final contact = prefill is Map ? prefill['contact']?.toString() ?? '' : '';
    if (contact.trim().isEmpty) {
      _subscriptionBloc.add(CancelLoadingEvent());
      _showPaymentMessage(
        'Phone number not found. Please log out and sign in again, then retry.',
      );
      return;
    }

    _razorpay.clear();
    await _paymentSessionMarkOpened();
    _checkoutOpened = true;
    await RazorpayCheckoutHelper.setAutoDismissEnabled(true);

    try {
      _razorpay.open(options);
    } catch (e) {
      _showPaymentMessage('Could not open payment. Please try again.');
    }
  }

  Future<void> _paymentSessionMarkOpened() async {
    await di.sl<PaymentSessionService>().markCheckoutOpened();
  }

  void _handlePaymentSuccess(
    String paymentId,
    String orderId,
    String signature,
  ) {
    if (_processingPlanId == null) return;
    _checkoutOpened = false;
    _subscriptionBloc.add(
      VerifyPaymentEvent(
        paymentId: paymentId,
        orderId: orderId,
        signature: signature,
        planId: _processingPlanId!,
      ),
    );
  }

  void _handlePaymentError(String message, int? code) {
    _checkoutOpened = false;
    RazorpayCheckoutHelper.dismissCheckout();
    _razorpay.clear();

    if (code == _razorpayPaymentCancelledCode ||
        message.toLowerCase().contains('cancel')) {
      _subscriptionBloc.add(CancelLoadingEvent());
      return;
    }

    PaymentReturnCoordinator.onReturnFromUpi(GoRouter.of(context));
  }

  Future<void> _silentRecoverPayment() async {
    if (_isVerifying) return;

    _checkoutOpened = false;
    await RazorpayCheckoutHelper.dismissCheckout();
    _razorpay.clear();

    final session = await di.sl<PaymentSessionService>().getActiveSession();
    final orderId = _pendingOrderId ?? session?.orderId;
    final planId = _processingPlanId ?? session?.planId;
    if (orderId == null || planId == null) return;

    _pendingOrderId = orderId;
    _processingPlanId = planId;
    _isVerifying = true;
    if (mounted) setState(() {});

    for (var i = 0; i < 4; i++) {
      if (i > 0) await Future.delayed(const Duration(seconds: 2));

      final result = await _recoverPayment(
        RecoverPaymentParams(razorpayOrderId: orderId, planId: planId),
      );

      if (result.isRight()) {
        _isVerifying = false;
        await _completeSuccessfulPayment();
        return;
      }
    }

    _isVerifying = false;
    if (mounted) {
      setState(() {});
      _subscriptionBloc.add(CancelLoadingEvent());
      _showPaymentMessage(
        'Payment not confirmed yet. If amount was deducted, reopen the app in a minute.',
      );
    }
  }

  Future<void> _completeSuccessfulPayment() async {
    await RazorpayCheckoutHelper.dismissCheckout();
    await RazorpayCheckoutHelper.setAutoDismissEnabled(false);
    await di.sl<PaymentSessionService>().clearSession();
    await OnboardingSessionGuard.instance.markPaymentCompleted();
    AnalyticsService().logEvent(name: 'subscription_payment_success');
    if (!mounted) return;
    context.go('/home');
  }

  void _showPaymentMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.outfit()),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showPaymentFailedDialog(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
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
          title: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Payment Failed',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _subscriptionBloc.add(CancelLoadingEvent());
              },
              child: Text(
                'Try Again',
                style: GoogleFonts.outfit(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleBackNav() {
    OnboardingSessionGuard.instance.unlockOnForwardProgress();
    if (widget.fromOnboarding || !context.canPop()) {
      context.go(
        '/business-registration',
        extra: {
          'firstName': '',
          'lastName': '',
          'businessName': '',
          'isSingleService': widget.isSingleService,
          'selectedSubCategories': widget.selectedSubCategories,
        },
      );
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _subscriptionBloc,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            _handleBackNav();
          }
        },
        child: Scaffold(
          backgroundColor:
              isDark ? AppColors.darkBackground : const Color(0xFFF7FBFF),
          appBar: AppBar(
            title: Text(
              'Choose Your Plan',
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: isDark ? Colors.white : AppColors.textPrimary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: _handleBackNav,
            ),
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/water.png',
                  fit: BoxFit.cover,
                  opacity: AlwaysStoppedAnimation(isDark ? 0.12 : 0.8),
                ),
              ),
              Positioned.fill(
                child: Container(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.85)
                      : Colors.white.withValues(alpha: 0.35),
                ),
              ),
              if (_isVerifying)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.35),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.accent),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Confirming payment...',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              SafeArea(
                child: BlocConsumer<SubscriptionBloc, SubscriptionState>(
                  listener: (context, state) {
                    if (state is SubscriptionLoaded) {
                      _displayPlans = state.plans;
                      _activeSubscription = state.activeSubscription;
                    } else if (state is SubscriptionError) {
                      _showPaymentFailedDialog(state.message);
                    } else if (state is PurchaseInitiateSuccess) {
                      _launchRazorpay(state.orderData);
                    } else if (state is PaymentVerificationSuccess) {
                      _completeSuccessfulPayment();
                    }
                  },
                  buildWhen: (previous, current) {
                    return current is SubscriptionLoading ||
                        current is SubscriptionLoaded ||
                        current is SubscriptionError ||
                        current is PurchaseInitiateSuccess ||
                        current is SubscriptionInitial;
                  },
                  builder: (context, state) {
                    if (state is SubscriptionLoading) {
                      if (_displayPlans != null && _displayPlans!.isNotEmpty) {
                        return Stack(
                          children: [
                            _buildPlansContent(
                              context,
                              _displayPlans!,
                              _activeSubscription,
                            ),
                            Container(
                              color: Colors.black.withValues(alpha: 0.25),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.accent,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.accent),
                        ),
                      );
                    } else if (state is SubscriptionError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: Colors.redAccent),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
                              style: GoogleFonts.outfit(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () => _subscriptionBloc
                                  .add(FetchSubscriptionsEvent()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: Text('Try Again',
                                  style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                      );
                    } else if (state is SubscriptionLoaded) {
                      return _buildPlansContent(
                        context,
                        state.plans,
                        state.activeSubscription,
                      );
                    } else if (state is PurchaseInitiateSuccess &&
                        _displayPlans != null &&
                        _displayPlans!.isNotEmpty) {
                      return _buildPlansContent(
                        context,
                        _displayPlans!,
                        _activeSubscription,
                      );
                    }

                    if (_displayPlans != null && _displayPlans!.isNotEmpty) {
                      return _buildPlansContent(
                        context,
                        _displayPlans!,
                        _activeSubscription,
                      );
                    }

                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.accent),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlansContent(
    BuildContext context,
    List<SubscriptionPlanEntity> plans,
    MySubscriptionEntity? activeSubscription,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (plans.isEmpty) {
      return Center(
        child: Text(
          'No subscription plans available right now.',
          style: GoogleFonts.outfit(
            color:
                isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            fontSize: 15,
          ),
        ),
      );
    }

    final uniquePlans = <String, SubscriptionPlanEntity>{};
    for (final plan in plans) {
      final key = '${plan.name}_${plan.price}_${plan.validityDays}';
      if (!uniquePlans.containsKey(key)) {
        uniquePlans[key] = plan;
      }
    }
    final deduplicatedPlans = uniquePlans.values.toList();

    final sortedPlans = List<SubscriptionPlanEntity>.from(deduplicatedPlans)
      ..sort((a, b) => a.price.compareTo(b.price));

    final maxPrice = sortedPlans.isNotEmpty
        ? sortedPlans
            .map((p) => p.price)
            .reduce((curr, next) => curr > next ? curr : next)
        : 0.0;

    final screenWidth = MediaQuery.of(context).size.width;
    int itemsPerRow = 1;
    if (screenWidth >= 1200) {
      itemsPerRow = 4;
    } else if (screenWidth >= 768) {
      itemsPerRow = 2;
    }

    if (itemsPerRow == 1) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            ...sortedPlans.map((plan) {
              final isHighlighted = plan.price == maxPrice;
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildPlanCard(
                  context,
                  plan,
                  isHighlighted,
                  activeSubscription,
                ),
              );
            }),
          ],
        ),
      );
    }

    final List<List<SubscriptionPlanEntity>> rows = [];
    for (int i = 0; i < sortedPlans.length; i += itemsPerRow) {
      rows.add(
        sortedPlans.sublist(
          i,
          i + itemsPerRow > sortedPlans.length
              ? sortedPlans.length
              : i + itemsPerRow,
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...rows.map((rowPlans) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...rowPlans.map((plan) {
                          final isHighlighted = plan.price == maxPrice;
                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: _buildPlanCard(
                                context,
                                plan,
                                isHighlighted,
                                activeSubscription,
                              ),
                            ),
                          );
                        }),
                        ...List.generate(
                          itemsPerRow - rowPlans.length,
                          (index) => const Expanded(child: SizedBox()),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  _PlanPurchaseAction _planPurchaseAction(
    SubscriptionPlanEntity plan,
    MySubscriptionEntity? activeSubscription,
  ) {
    if (activeSubscription == null ||
        activeSubscription.status.toLowerCase() != 'active') {
      return _PlanPurchaseAction.subscribe;
    }

    final activePlan = activeSubscription.plan;
    if (activePlan == null) {
      return _PlanPurchaseAction.subscribe;
    }

    if (plan.id == activePlan.id) {
      return _PlanPurchaseAction.current;
    }
    if (plan.price < activePlan.price) {
      return _PlanPurchaseAction.downgradeBlocked;
    }
    if (plan.price > activePlan.price) {
      return _PlanPurchaseAction.upgrade;
    }
    return _PlanPurchaseAction.subscribe;
  }

  Widget _buildPlanCard(
    BuildContext context,
    SubscriptionPlanEntity plan,
    bool isHighlighted,
    MySubscriptionEntity? activeSubscription,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isWide = MediaQuery.of(context).size.width >= 768;
    final purchaseAction = _planPurchaseAction(plan, activeSubscription);
    final isActionDisabled = purchaseAction == _PlanPurchaseAction.current ||
        purchaseAction == _PlanPurchaseAction.downgradeBlocked;

    final highlightGradient = isDark
        ? LinearGradient(
            colors: [
              const Color(0xFF13254A).withValues(alpha: 0.85),
              const Color(0xFF0C1935).withValues(alpha: 0.75),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: [
              const Color(0xFFEEF5FF).withValues(alpha: 0.9),
              Colors.white.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final standardGradient = isDark
        ? LinearGradient(
            colors: [
              const Color(0xFF10192A).withValues(alpha: 0.65),
              const Color(0xFF0D1424).withValues(alpha: 0.55),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.75),
              Colors.white.withValues(alpha: 0.65),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final List<Widget> featuresListWidgets = [
      ...plan.features.map((feature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: isHighlighted ? AppColors.accent : AppColors.success,
                size: 18,
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
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
      ...plan.disabledFeatures.map((disabledFeature) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color:
                    isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                size: 18,
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
                    decorationColor: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF4B5563),
                    decorationThickness: 1.8,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: isHighlighted ? highlightGradient : standardGradient,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isHighlighted
                  ? AppColors.accent.withValues(alpha: 0.8)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.08)),
              width: isHighlighted ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        plan.name.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: isHighlighted
                              ? (isDark
                                  ? AppColors.accentLight
                                  : AppColors.accentDark)
                              : (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary),
                        ),
                      ),
                    ),
                    if (purchaseAction == _PlanPurchaseAction.current)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'CURRENT PLAN',
                          style: GoogleFonts.outfit(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.success,
                            letterSpacing: 1.0,
                          ),
                        ),
                      )
                    else if (isHighlighted)
                      ScaleTransition(
                        scale: _badgeScaleAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFF59E0B).withValues(alpha: 0.25),
                                const Color(0xFFEAB308).withValues(alpha: 0.15),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFF59E0B)
                                  .withValues(alpha: 0.7),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF59E0B)
                                    .withValues(alpha: 0.25),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RotationTransition(
                                turns: _sparkleRotateController,
                                child: const Icon(
                                  Icons.auto_awesome,
                                  size: 12,
                                  color: Color(0xFFF59E0B),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Vendor/Partner top choice',
                                style: GoogleFonts.outfit(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? const Color(0xFFFBBF24)
                                      : const Color(0xFFD97706),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 4),
                              RotationTransition(
                                turns: _sparkleRotateController,
                                child: const Icon(
                                  Icons.auto_awesome,
                                  size: 12,
                                  color: Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (plan.originalPrice != null &&
                        plan.originalPrice! > plan.price)
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              '₹${plan.originalPrice!.toInt()}',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            plan.offerText ?? '',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          )
                        ],
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${plan.price.toInt()}',
                          style: GoogleFonts.outfit(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '/ ${plan.validityDays} days + 0% GST',
                            style: GoogleFonts.outfit(
                              fontSize: 13.5,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(
                  color: isDark
                      ? AppColors.darkBorder.withValues(alpha: 0.5)
                      : AppColors.border.withValues(alpha: 0.5),
                  thickness: 1,
                ),
                const SizedBox(height: 14),
                if (isWide)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: featuresListWidgets,
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: featuresListWidgets,
                  ),
                const SizedBox(height: 16),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isActionDisabled
                          ? null
                          : (isHighlighted
                              ? AppColors.accentGradient
                              : AppColors.primaryGradient),
                      color: isActionDisabled
                          ? (isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.06))
                          : null,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isActionDisabled
                          ? null
                          : [
                              BoxShadow(
                                color: (isHighlighted
                                        ? AppColors.accent
                                        : AppColors.primary)
                                    .withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                    ),
                    child: ElevatedButton(
                      onPressed: isActionDisabled
                          ? null
                          : () {
                              setState(() {
                                final isExpanded =
                                    _termsExpandedPlans[plan.id] ?? false;
                                _termsExpandedPlans[plan.id] = !isExpanded;
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        switch (purchaseAction) {
                          _PlanPurchaseAction.current => 'Current Plan',
                          _PlanPurchaseAction.downgradeBlocked =>
                            'Downgrade Not Available',
                          _PlanPurchaseAction.upgrade => 'Upgrade Now',
                          _PlanPurchaseAction.subscribe => 'Subscribe Now',
                        },
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isActionDisabled
                              ? (isDark
                                  ? Colors.white.withValues(alpha: 0.6)
                                  : const Color(0xFF64748B))
                              : (isHighlighted
                                  ? AppColors.primaryDark
                                  : Colors.white),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                if (!isActionDisabled &&
                    (_termsExpandedPlans[plan.id] ?? false)) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.25)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Builder(
                          builder: (context) {
                            final isTextExpanded =
                                _termsAcceptedPlans[plan.id] ?? false;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '• AM5 Royal provides customer leads based on your selected subscription plan.\n'
                                  '• AM5 Royal will assign only leads. Acceptance or rejection of the lead depends on the Vendor/Partner.\n'
                                  '• Once after successful payment of your selected subscription plan, it cannot be canceled or refunded.',
                                  maxLines: isTextExpanded ? null : 2,
                                  overflow: isTextExpanded
                                      ? TextOverflow.visible
                                      : TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _termsAcceptedPlans[plan.id] =
                                          !isTextExpanded;
                                    });
                                  },
                                  child: Text(
                                    isTextExpanded ? 'Read Less' : 'Read More',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.accentLight
                                          : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: Checkbox(
                                value: _termsAcceptedPlans[plan.id] ?? false,
                                activeColor: AppColors.primary,
                                onChanged: (val) {
                                  final isChecked = val ?? false;
                                  setState(() {
                                    _termsAcceptedPlans[plan.id] = isChecked;
                                  });
                                  if (isChecked) {
                                    ScaffoldMessenger.of(context)
                                      ..clearSnackBars()
                                      ..showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Terms & Conditions agreed. Opening payment...',
                                            style: GoogleFonts.outfit(),
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    _processingPlanId = plan.id;
                                    _subscriptionBloc.add(
                                        PurchasePlanEvent(planId: plan.id));
                                  }
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  final current =
                                      _termsAcceptedPlans[plan.id] ?? false;
                                  final isChecked = !current;
                                  setState(() {
                                    _termsAcceptedPlans[plan.id] = isChecked;
                                  });
                                  if (isChecked) {
                                    ScaffoldMessenger.of(context)
                                      ..clearSnackBars()
                                      ..showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Terms & Conditions agreed. Opening payment...',
                                            style: GoogleFonts.outfit(),
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    _processingPlanId = plan.id;
                                    _subscriptionBloc.add(
                                        PurchasePlanEvent(planId: plan.id));
                                  }
                                },
                                child: Text(
                                  'I agree to the Terms & Conditions',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _PlanPurchaseAction {
  subscribe,
  current,
  upgrade,
  downgradeBlocked,
}
