import 'package:equatable/equatable.dart';
import '../../domain/entities/service_entity.dart';

abstract class ServiceState extends Equatable {
  const ServiceState();

  @override
  List<Object?> get props => [];
}

class ServiceInitial extends ServiceState {
  const ServiceInitial();
}

class ServiceLoading extends ServiceState {
  const ServiceLoading();
}

class ServiceSuccess extends ServiceState {
  final List<ServiceEntity> services;
  final List<ServiceEntity> selectedServices;

  const ServiceSuccess({
    required this.services,
    required this.selectedServices,
  });

  @override
  List<Object?> get props => [services, selectedServices];
}

class ServiceEmpty extends ServiceState {
  const ServiceEmpty();
}

class ServiceError extends ServiceState {
  final String message;

  const ServiceError(this.message);

  @override
  List<Object?> get props => [message];
}
