import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/sync_device_usecase.dart';
import 'device_tracking_event.dart';
import 'device_tracking_state.dart';

class DeviceTrackingBloc extends Bloc<DeviceTrackingEvent, DeviceTrackingState> {
  final SyncDeviceUseCase syncDeviceUseCase;

  DeviceTrackingBloc({required this.syncDeviceUseCase}) : super(DeviceTrackingInitial()) {
    on<SyncDeviceEvent>(_onSyncDevice);
  }

  Future<void> _onSyncDevice(SyncDeviceEvent event, Emitter<DeviceTrackingState> emit) async {
    emit(DeviceTrackingSyncing());
    
    final result = await syncDeviceUseCase(NoParams());
    
    result.fold(
      (failure) => emit(DeviceTrackingFailure(message: failure.message)),
      (_) => emit(DeviceTrackingSuccess()),
    );
  }
}
