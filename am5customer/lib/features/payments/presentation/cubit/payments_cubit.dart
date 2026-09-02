import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';

class WalletCubit extends Cubit<WalletViewState> {
  WalletCubit(this._api) : super(const WalletViewState.initial());

  final PaymentsApi _api;

  Future<void> load() async {
    emit(state.copyWith(status: WalletStatus.loading, clearMessage: true));
    try {
      final wallet = await _api.getWallet();
      emit(state.copyWith(status: WalletStatus.ready, wallet: wallet));
    } on Failure catch (f) {
      emit(state.copyWith(status: WalletStatus.error, message: f.message));
    } catch (_) {
      emit(state.copyWith(status: WalletStatus.error, message: 'Failed to load wallet'));
    }
  }
}

enum WalletStatus { initial, loading, ready, error }

class WalletViewState extends Equatable {
  const WalletViewState({required this.status, this.wallet, this.message});
  const WalletViewState.initial() : this(status: WalletStatus.initial);

  final WalletStatus status;
  final WalletInfo? wallet;
  final String? message;

  WalletViewState copyWith({
    WalletStatus? status,
    WalletInfo? wallet,
    String? message,
    bool clearMessage = false,
  }) {
    return WalletViewState(
      status: status ?? this.status,
      wallet: wallet ?? this.wallet,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, wallet, message];
}

class PayBookingCubit extends Cubit<PayBookingState> {
  PayBookingCubit(this._paymentsApi, this._bookingsApi, this.bookingId)
      : super(const PayBookingState.initial());

  final PaymentsApi _paymentsApi;
  final BookingsApi _bookingsApi;
  final String bookingId;

  Future<void> load() async {
    emit(state.copyWith(status: PayBookingStatus.loading));
    try {
      final results = await Future.wait([
        _bookingsApi.myBookings(),
        _paymentsApi.getWallet(),
      ]);
      final bookings = results[0] as List<Booking>;
      final wallet = results[1] as WalletInfo;
      final booking = bookings
          .where((b) => b.id == bookingId || b.bookingCode == bookingId)
          .firstOrNull;
      if (booking == null) {
        emit(state.copyWith(status: PayBookingStatus.error, message: 'Booking not found'));
        return;
      }
      emit(
        state.copyWith(
          status: PayBookingStatus.ready,
          booking: booking,
          wallet: wallet,
          useWallet: wallet.balance > 0,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(status: PayBookingStatus.error, message: f.message));
    } catch (_) {
      emit(state.copyWith(status: PayBookingStatus.error, message: 'Failed to load payment'));
    }
  }

  Future<void> applyCoupon(String code) async {
    final booking = state.booking;
    if (booking == null) return;
    try {
      final quote = await _paymentsApi.validateCoupon(code: code, orderAmount: booking.priceAmount);
      emit(state.copyWith(couponCode: code, quote: quote));
    } on Failure catch (f) {
      emit(state.copyWith(message: f.message));
    }
  }

  void toggleWallet(bool value) => emit(state.copyWith(useWallet: value));

  Future<void> pay() async {
    final booking = state.booking;
    final wallet = state.wallet;
    if (booking == null) return;
    emit(state.copyWith(submitting: true, clearMessage: true));
    try {
      final payable = state.quote?.valid == true
          ? state.quote!.payableAmount
          : (booking.payableAmount ?? booking.priceAmount);
      final walletUse = state.useWallet && wallet != null
          ? (wallet.balance < payable ? wallet.balance : payable)
          : 0.0;
      final payment = await _paymentsApi.createPayment(
        bookingId: bookingId,
        couponCode: state.quote?.valid == true ? state.couponCode : null,
        useWalletAmount: walletUse,
      );
      if (payment.status != 'captured') {
        await _paymentsApi.confirmPayment(payment.id);
      }
      emit(state.copyWith(submitting: false, message: 'paid'));
    } on Failure catch (f) {
      emit(state.copyWith(submitting: false, message: f.message));
    } catch (_) {
      emit(state.copyWith(submitting: false, message: 'Payment failed'));
    }
  }
}

enum PayBookingStatus { initial, loading, ready, error }

class PayBookingState extends Equatable {
  const PayBookingState({
    required this.status,
    this.booking,
    this.wallet,
    this.couponCode,
    this.quote,
    this.useWallet = false,
    this.submitting = false,
    this.message,
  });

  const PayBookingState.initial() : this(status: PayBookingStatus.initial);

  final PayBookingStatus status;
  final Booking? booking;
  final WalletInfo? wallet;
  final String? couponCode;
  final CouponQuote? quote;
  final bool useWallet;
  final bool submitting;
  final String? message;

  PayBookingState copyWith({
    PayBookingStatus? status,
    Booking? booking,
    WalletInfo? wallet,
    String? couponCode,
    CouponQuote? quote,
    bool? useWallet,
    bool? submitting,
    String? message,
    bool clearMessage = false,
  }) {
    return PayBookingState(
      status: status ?? this.status,
      booking: booking ?? this.booking,
      wallet: wallet ?? this.wallet,
      couponCode: couponCode ?? this.couponCode,
      quote: quote ?? this.quote,
      useWallet: useWallet ?? this.useWallet,
      submitting: submitting ?? this.submitting,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props =>
      [status, booking, wallet, couponCode, quote, useWallet, submitting, message];
}
