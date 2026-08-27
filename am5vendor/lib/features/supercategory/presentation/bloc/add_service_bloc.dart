import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_service_usecase.dart';
import '../../domain/usecases/upload_media_usecase.dart';
import '../../domain/usecases/remove_service_usecase.dart';
import '../../data/models/add_service_request_model.dart';
import 'add_service_event.dart';
import 'add_service_state.dart';

class AddServiceBloc extends Bloc<AddServiceEvent, AddServiceState> {
  final AddServiceUseCase addServiceUseCase;
  final UploadMediaUseCase uploadMediaUseCase;
  final RemoveServiceUseCase removeServiceUseCase;

  AddServiceBloc({
    required this.addServiceUseCase,
    required this.uploadMediaUseCase,
    required this.removeServiceUseCase,
  }) : super(const AddServiceInitial()) {
    on<SubmitAddService>(_onSubmitAddService);
    on<SubmitRemoveService>(_onSubmitRemoveService);
  }

  Future<void> _onSubmitAddService(
    SubmitAddService event,
    Emitter<AddServiceState> emit,
  ) async {
    emit(const AddServiceLoading());

    List<MediaItemModel> uploadedMedia = [];

    // Upload images
    for (var file in event.imageFiles) {
      final uploadResult = await uploadMediaUseCase(file);
      uploadResult.fold(
        (failure) {
          emit(AddServiceError(failure.message));
          return; // Stop if upload fails
        },
        (mediaItem) => uploadedMedia.add(mediaItem),
      );
      if (state is AddServiceError) return;
    }

    // Upload video
    if (event.videoFile != null) {
      final uploadResult = await uploadMediaUseCase(event.videoFile!);
      uploadResult.fold(
        (failure) {
          emit(AddServiceError(failure.message));
          return;
        },
        (mediaItem) => uploadedMedia.add(mediaItem),
      );
      if (state is AddServiceError) return;
    }

    // Submit service
    final result = await addServiceUseCase(
      serviceId: event.serviceId,
      amount: event.amount,
      isNegotiable: event.isNegotiable,
      media: uploadedMedia,
    );
    
    result.fold(
      (failure) => emit(AddServiceError(failure.message)),
      (response) => emit(AddServiceSuccess(
        response: response,
        serviceId: event.serviceId,
        amount: event.amount,
        isNegotiable: event.isNegotiable,
      )),
    );
  }

  Future<void> _onSubmitRemoveService(
    SubmitRemoveService event,
    Emitter<AddServiceState> emit,
  ) async {
    emit(const AddServiceLoading());
    final result = await removeServiceUseCase(event.serviceId);
    result.fold(
      (failure) => emit(AddServiceError(failure.message)),
      (_) => emit(RemoveServiceSuccess(event.serviceId)),
    );
  }
}
