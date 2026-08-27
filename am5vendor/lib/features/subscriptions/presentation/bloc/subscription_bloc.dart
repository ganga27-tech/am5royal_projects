import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/subscription_plan_entity.dart';
import '../../domain/entities/my_subscription_entity.dart';
import '../../domain/usecases/get_subscription_plans_usecase.dart';
import '../../domain/usecases/purchase_plan_usecase.dart';
import '../../domain/usecases/verify_payment_usecase.dart';
import '../../domain/usecases/recover_payment_usecase.dart';
import '../../domain/usecases/get_my_subscriptions_usecase.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final GetSubscriptionPlansUseCase getSubscriptionPlans;
  final PurchasePlanUseCase purchasePlan;
  final VerifyPaymentUseCase verifyPayment;
  final RecoverPaymentUseCase recoverPayment;
  final GetMySubscriptionsUseCase getMySubscriptions;

  List<SubscriptionPlanEntity> _cachedPlans = [];
  MySubscriptionEntity? _cachedActiveSubscription;

  SubscriptionBloc({
    required this.getSubscriptionPlans,
    required this.purchasePlan,
    required this.verifyPayment,
    required this.recoverPayment,
    required this.getMySubscriptions,
  }) : super(SubscriptionInitial()) {
    on<FetchSubscriptionsEvent>(_onFetchSubscriptions);
    on<PurchasePlanEvent>(_onPurchasePlan);
    on<VerifyPaymentEvent>(_onVerifyPayment);
    on<RecoverPaymentEvent>(_onRecoverPayment);
    on<CheckActiveSubscriptionEvent>(_onCheckActiveSubscription);
    on<CancelLoadingEvent>(_onCancelLoading);
  }

  void _onCancelLoading(CancelLoadingEvent event, Emitter<SubscriptionState> emit) {
    if (_cachedPlans.isNotEmpty) {
      emit(SubscriptionLoaded(
        plans: _cachedPlans,
        activeSubscription: _cachedActiveSubscription,
      ));
    } else {
      emit(SubscriptionInitial());
    }
  }

  MySubscriptionEntity? _findActiveSubscription(
    List<MySubscriptionEntity> subscriptions,
  ) {
    for (final subscription in subscriptions) {
      if (subscription.status.toLowerCase() == 'active') {
        return subscription;
      }
    }
    return null;
  }

  Future<void> _onFetchSubscriptions(FetchSubscriptionsEvent event, Emitter<SubscriptionState> emit) async {
    emit(SubscriptionLoading());
    
    final plansResult = await getSubscriptionPlans(NoParams());
    final subscriptionsResult = await getMySubscriptions(const NoParams());

    plansResult.fold(
      (failure) => emit(SubscriptionError(message: failure.message)),
      (plans) {
        subscriptionsResult.fold(
          (_) {
            _cachedPlans = plans;
            _cachedActiveSubscription = null;
            emit(SubscriptionLoaded(plans: plans));
          },
          (subscriptions) {
            _cachedPlans = plans;
            _cachedActiveSubscription = _findActiveSubscription(subscriptions);
            emit(SubscriptionLoaded(
              plans: plans,
              activeSubscription: _cachedActiveSubscription,
            ));
          },
        );
      },
    );
  }

  Future<void> _onPurchasePlan(PurchasePlanEvent event, Emitter<SubscriptionState> emit) async {
    if (_cachedPlans.isNotEmpty) {
      emit(SubscriptionLoaded(
        plans: _cachedPlans,
        activeSubscription: _cachedActiveSubscription,
      ));
    } else {
      emit(SubscriptionLoading());
    }
    
    final result = await purchasePlan(PurchasePlanParams(planId: event.planId));
    
    result.fold(
      (failure) => emit(SubscriptionError(message: failure.message)),
      (data) {
        _cachedActiveSubscription = null;
        if (data.containsKey('order_id')) {
          emit(PurchaseInitiateSuccess(orderData: data));
        } else {
          emit(PaymentVerificationSuccess(
            message: data['message'] ?? 'Plan activated successfully',
          ));
        }
      },
    );
  }

  Future<void> _onVerifyPayment(VerifyPaymentEvent event, Emitter<SubscriptionState> emit) async {
    emit(SubscriptionLoading());
    
    final result = await verifyPayment(VerifyPaymentParams(
      razorpayPaymentId: event.paymentId,
      razorpayOrderId: event.orderId,
      razorpaySignature: event.signature,
      planId: event.planId,
    ));
    
    result.fold(
      (failure) => emit(SubscriptionError(message: failure.message)),
      (data) {
        _cachedActiveSubscription = null;
        emit(PaymentVerificationSuccess(
          message: data['message'] ?? 'Payment successful',
        ));
      },
    );
  }

  Future<void> _onRecoverPayment(
    RecoverPaymentEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());

    final result = await recoverPayment(
      RecoverPaymentParams(
        razorpayOrderId: event.orderId,
        planId: event.planId,
      ),
    );

    result.fold(
      (failure) => emit(SubscriptionError(message: failure.message)),
      (data) {
        _cachedActiveSubscription = null;
        emit(
          PaymentVerificationSuccess(
            message: data['message'] ?? 'Subscription activated successfully',
          ),
        );
      },
    );
  }

  Future<void> _onCheckActiveSubscription(
    CheckActiveSubscriptionEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    final result = await getMySubscriptions(const NoParams());

    result.fold(
      (_) {},
      (subscriptions) {
        final hasActive = subscriptions.any(
          (subscription) => subscription.status.toLowerCase() == 'active',
        );
        if (hasActive) {
          emit(
            const PaymentVerificationSuccess(
              message: 'Your subscription is already active',
            ),
          );
        }
      },
    );
  }
}
