import 'package:equatable/equatable.dart';

abstract class MySubscriptionsEvent extends Equatable {
  const MySubscriptionsEvent();

  @override
  List<Object> get props => [];
}

class FetchMySubscriptionsEvent extends MySubscriptionsEvent {}
