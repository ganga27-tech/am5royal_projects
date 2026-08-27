import 'package:equatable/equatable.dart';
import '../../domain/entities/vendor_availability.dart';

abstract class VendorAvailabilityEvent extends Equatable {
  const VendorAvailabilityEvent();

  @override
  List<Object?> get props => [];
}

class GetVendorAvailabilityEvent extends VendorAvailabilityEvent {
  const GetVendorAvailabilityEvent();
}

class UpdateVendorAvailabilityEvent extends VendorAvailabilityEvent {
  final List<VendorAvailability> availabilities;

  const UpdateVendorAvailabilityEvent({
    required this.availabilities,
  });

  @override
  List<Object?> get props => [availabilities];
}

class UpdateLocalDayEvent extends VendorAvailabilityEvent {
  final int dayOfWeek;
  final String? startTime;
  final String? endTime;
  final bool? isAvailable;

  const UpdateLocalDayEvent({
    required this.dayOfWeek,
    this.startTime,
    this.endTime,
    this.isAvailable,
  });

  @override
  List<Object?> get props => [dayOfWeek, startTime, endTime, isAvailable];
}
