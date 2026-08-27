import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/usecases/get_services_usecase.dart';
import 'service_event.dart';
import 'service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  final GetServicesUseCase getServicesUseCase;

  ServiceBloc({required this.getServicesUseCase}) : super(const ServiceInitial()) {
    on<FetchServices>(_onFetchServices);
    on<ToggleServiceSelection>(_onToggleServiceSelection);
    on<ClearServiceSelection>(_onClearServiceSelection);
  }

  Future<void> _onFetchServices(
    FetchServices event,
    Emitter<ServiceState> emit,
  ) async {
    emit(const ServiceLoading());

    if (event.subcategoryIds.isEmpty) {
      final result = await getServicesUseCase(mainCategoryId: event.mainCategoryId);
      result.fold(
        (failure) => emit(ServiceError(failure.message)),
        (services) {
          if (services.isEmpty) {
            emit(const ServiceEmpty());
          } else {
            emit(ServiceSuccess(services: services, selectedServices: const []));
          }
        },
      );
    } else {
      // Parallel requests for all subcategory IDs
      final futures = event.subcategoryIds.map(
        (subId) => getServicesUseCase(mainCategoryId: event.mainCategoryId, subCategoryId: subId)
      );

      final results = await Future.wait(futures);
      final List<ServiceEntity> allServices = [];
      String? errorMessage;

      for (final res in results) {
        res.fold(
          (failure) => errorMessage = failure.message,
          (services) => allServices.addAll(services),
        );
      }

      if (errorMessage != null && allServices.isEmpty) {
        emit(ServiceError(errorMessage!));
        return;
      }

      // Deduplicate by ID
      final seen = <int>{};
      final uniqueServices = allServices.where((s) => seen.add(s.id)).toList();

      if (uniqueServices.isEmpty) {
        emit(const ServiceEmpty());
      } else {
        emit(ServiceSuccess(services: uniqueServices, selectedServices: const []));
      }
    }
  }

  void _onToggleServiceSelection(
    ToggleServiceSelection event,
    Emitter<ServiceState> emit,
  ) {
    final currentState = state;
    if (currentState is ServiceSuccess) {
      final selectedList = List<ServiceEntity>.from(currentState.selectedServices);
      final isSelected = selectedList.any((s) => s.id == event.service.id);

      if (isSelected) {
        selectedList.removeWhere((s) => s.id == event.service.id);
      } else {
        selectedList.add(event.service);
      }

      emit(ServiceSuccess(
        services: currentState.services,
        selectedServices: selectedList,
      ));
    }
  }

  void _onClearServiceSelection(
    ClearServiceSelection event,
    Emitter<ServiceState> emit,
  ) {
    final currentState = state;
    if (currentState is ServiceSuccess) {
      emit(ServiceSuccess(
        services: currentState.services,
        selectedServices: const [],
      ));
    }
  }
}
