import 'package:equatable/equatable.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class FetchOrdersEvent extends OrdersEvent {
  final String? statusFilter;
  const FetchOrdersEvent({this.statusFilter});

  @override
  List<Object?> get props => [statusFilter];
}

class StartServiceEvent extends OrdersEvent {
  final String orderId;
  final String startOtp;
  const StartServiceEvent(this.orderId, this.startOtp);

  @override
  List<Object?> get props => [orderId, startOtp];
}

class CompleteServiceEvent extends OrdersEvent {
  final String orderId;
  final String endOtp;
  const CompleteServiceEvent(this.orderId, this.endOtp);

  @override
  List<Object?> get props => [orderId, endOtp];
}

class AcceptBookingEvent extends OrdersEvent {
  final String orderId;
  const AcceptBookingEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class RejectBookingEvent extends OrdersEvent {
  final String orderId;
  final String? reason;
  const RejectBookingEvent(this.orderId, {this.reason});

  @override
  List<Object?> get props => [orderId, reason];
}
