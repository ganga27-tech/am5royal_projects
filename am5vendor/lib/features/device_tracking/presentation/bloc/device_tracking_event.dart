import 'package:equatable/equatable.dart';

abstract class DeviceTrackingEvent extends Equatable {
  const DeviceTrackingEvent();

  @override
  List<Object> get props => [];
}

class SyncDeviceEvent extends DeviceTrackingEvent {}
