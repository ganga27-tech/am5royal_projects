import 'package:equatable/equatable.dart';
import '../../domain/entities/service_entity.dart';

abstract class ServiceEvent extends Equatable {
  const ServiceEvent();

  @override
  List<Object?> get props => [];
}

class FetchServices extends ServiceEvent {
  final int mainCategoryId;
  final List<int> subcategoryIds;

  const FetchServices({
    required this.mainCategoryId,
    required this.subcategoryIds,
  });

  @override
  List<Object?> get props => [mainCategoryId, subcategoryIds];
}

class ToggleServiceSelection extends ServiceEvent {
  final ServiceEntity service;

  const ToggleServiceSelection(this.service);

  @override
  List<Object?> get props => [service];
}

class ClearServiceSelection extends ServiceEvent {
  const ClearServiceSelection();
}
