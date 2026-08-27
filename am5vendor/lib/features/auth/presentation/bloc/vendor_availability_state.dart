import 'package:equatable/equatable.dart';
import '../../domain/entities/vendor_availability.dart';

abstract class VendorAvailabilityState extends Equatable {
  const VendorAvailabilityState();

  @override
  List<Object?> get props => [];
}

class VendorAvailabilityInitial extends VendorAvailabilityState {}

class VendorAvailabilityLoading extends VendorAvailabilityState {}

class VendorAvailabilityLoaded extends VendorAvailabilityState {
  final List<VendorAvailability> availabilities;
  final bool isSaving;

  const VendorAvailabilityLoaded({
    required this.availabilities,
    this.isSaving = false,
  });

  VendorAvailabilityLoaded copyWith({
    List<VendorAvailability>? availabilities,
    bool? isSaving,
  }) {
    return VendorAvailabilityLoaded(
      availabilities: availabilities ?? this.availabilities,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [availabilities, isSaving];
}

class VendorAvailabilityError extends VendorAvailabilityState {
  final String message;

  const VendorAvailabilityError(this.message);

  @override
  List<Object?> get props => [message];
}

class VendorAvailabilityUpdateSuccess extends VendorAvailabilityState {
  final List<VendorAvailability> availabilities;

  const VendorAvailabilityUpdateSuccess({required this.availabilities});

  @override
  List<Object?> get props => [availabilities];
}
