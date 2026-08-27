import 'package:flutter_bloc/flutter_bloc.dart';
import 'orders_event.dart';
import 'orders_state.dart';
import '../../domain/usecases/get_vendor_orders_usecase.dart';
import '../../domain/usecases/start_service_usecase.dart';
import '../../domain/usecases/complete_service_usecase.dart';

import '../../domain/usecases/accept_booking_usecase.dart';
import '../../domain/usecases/reject_booking_usecase.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final GetVendorOrdersUseCase getVendorOrdersUseCase;
  final StartServiceUseCase startServiceUseCase;
  final CompleteServiceUseCase completeServiceUseCase;
  final AcceptBookingUseCase acceptBookingUseCase;
  final RejectBookingUseCase rejectBookingUseCase;

  OrdersBloc({
    required this.getVendorOrdersUseCase,
    required this.startServiceUseCase,
    required this.completeServiceUseCase,
    required this.acceptBookingUseCase,
    required this.rejectBookingUseCase,
  }) : super(OrdersInitial()) {
    on<FetchOrdersEvent>((event, emit) async {
      emit(OrdersLoading());
      final result = await getVendorOrdersUseCase(statusFilter: event.statusFilter);
      result.fold(
        (failure) => emit(OrdersError(failure.message)),
        (orders) => emit(OrdersLoaded(orders)),
      );
    });

    on<StartServiceEvent>((event, emit) async {
      emit(OrderActionLoading());
      final result = await startServiceUseCase(event.orderId, event.startOtp);
      result.fold(
        (failure) => emit(OrderActionError(failure.message)),
        (_) => emit(const OrderActionSuccess('Service started successfully')),
      );
    });

    on<CompleteServiceEvent>((event, emit) async {
      emit(OrderActionLoading());
      final result = await completeServiceUseCase(event.orderId, event.endOtp);
      result.fold(
        (failure) => emit(OrderActionError(failure.message)),
        (_) => emit(const OrderActionSuccess('Service completed successfully')),
      );
    });

    on<AcceptBookingEvent>((event, emit) async {
      emit(OrderActionLoading());
      final result = await acceptBookingUseCase(event.orderId);
      result.fold(
        (failure) => emit(OrderActionError(failure.message)),
        (_) => emit(const OrderActionSuccess('Booking accepted successfully')),
      );
    });

    on<RejectBookingEvent>((event, emit) async {
      emit(OrderActionLoading());
      final result = await rejectBookingUseCase(event.orderId, reason: event.reason);
      result.fold(
        (failure) => emit(OrderActionError(failure.message)),
        (_) => emit(const OrderActionSuccess('Booking rejected')),
      );
    });
  }
}
