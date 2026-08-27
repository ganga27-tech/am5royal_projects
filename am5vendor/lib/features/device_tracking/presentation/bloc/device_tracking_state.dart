import 'package:equatable/equatable.dart';

abstract class DeviceTrackingState extends Equatable {
  const DeviceTrackingState();
  
  @override
  List<Object> get props => [];
}

class DeviceTrackingInitial extends DeviceTrackingState {}

class DeviceTrackingSyncing extends DeviceTrackingState {}

class DeviceTrackingSuccess extends DeviceTrackingState {}

class DeviceTrackingFailure extends DeviceTrackingState {
  final String message;

  const DeviceTrackingFailure({required this.message});

  @override
  List<Object> get props => [message];
}
