import 'package:flutter_bloc/flutter_bloc.dart';
import 'vendor_availability_event.dart';
import 'vendor_availability_state.dart';
import '../../domain/entities/vendor_availability.dart';
import '../../domain/usecases/get_vendor_availability.dart';
import '../../domain/usecases/update_vendor_availability.dart';

class VendorAvailabilityBloc extends Bloc<VendorAvailabilityEvent, VendorAvailabilityState> {
  final GetVendorAvailabilityUseCase getVendorAvailability;
  final UpdateVendorAvailabilityUseCase updateVendorAvailability;

  VendorAvailabilityBloc({
    required this.getVendorAvailability,
    required this.updateVendorAvailability,
  }) : super(VendorAvailabilityInitial()) {
    on<GetVendorAvailabilityEvent>(_onGetVendorAvailability);
    on<UpdateVendorAvailabilityEvent>(_onUpdateVendorAvailability);
    on<UpdateLocalDayEvent>(_onUpdateLocalDay);
  }

  Future<void> _onGetVendorAvailability(
    GetVendorAvailabilityEvent event,
    Emitter<VendorAvailabilityState> emit,
  ) async {
    emit(VendorAvailabilityLoading());

    final result = await getVendorAvailability();

    result.fold(
      (failure) => emit(VendorAvailabilityError(failure.message)),
      (availabilities) {
        if (availabilities.isEmpty) {
          // Initialize with default 7 days if empty
          final defaults = List.generate(7, (index) => VendorAvailability(
            dayOfWeek: index,
            startTime: '09:00:00',
            endTime: '17:00:00',
            isAvailable: true,
          ));
          emit(VendorAvailabilityLoaded(availabilities: defaults));
        } else {
          emit(VendorAvailabilityLoaded(availabilities: availabilities));
        }
      },
    );
  }

  Future<void> _onUpdateVendorAvailability(
    UpdateVendorAvailabilityEvent event,
    Emitter<VendorAvailabilityState> emit,
  ) async {
    if (state is VendorAvailabilityLoaded) {
      final currentState = state as VendorAvailabilityLoaded;
      emit(currentState.copyWith(isSaving: true));

      final result = await updateVendorAvailability(event.availabilities);

      result.fold(
        (failure) {
          emit(VendorAvailabilityError(failure.message));
          emit(currentState.copyWith(isSaving: false)); // Revert saving state
        },
        (availabilities) {
          emit(VendorAvailabilityUpdateSuccess(availabilities: availabilities));
          emit(VendorAvailabilityLoaded(availabilities: availabilities));
        },
      );
    }
  }

  void _onUpdateLocalDay(
    UpdateLocalDayEvent event,
    Emitter<VendorAvailabilityState> emit,
  ) {
    if (state is VendorAvailabilityLoaded) {
      final currentState = state as VendorAvailabilityLoaded;
      final updatedList = currentState.availabilities.map((e) {
        if (e.dayOfWeek == event.dayOfWeek) {
          return VendorAvailability(
            dayOfWeek: e.dayOfWeek,
            startTime: event.startTime ?? e.startTime,
            endTime: event.endTime ?? e.endTime,
            isAvailable: event.isAvailable ?? e.isAvailable,
          );
        }
        return e;
      }).toList();

      emit(currentState.copyWith(availabilities: updatedList));
    }
  }
}
