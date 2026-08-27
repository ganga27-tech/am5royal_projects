import 'package:equatable/equatable.dart';
import '../../data/models/add_service_response_model.dart';

abstract class AddServiceState extends Equatable {
  const AddServiceState();

  @override
  List<Object?> get props => [];
}

class AddServiceInitial extends AddServiceState {
  const AddServiceInitial();
}

class AddServiceLoading extends AddServiceState {
  const AddServiceLoading();
}

class AddServiceSuccess extends AddServiceState {
  final AddServiceResponseModel response;
  final int serviceId;
  final double amount;
  final bool isNegotiable;

  const AddServiceSuccess({
    required this.response,
    required this.serviceId,
    required this.amount,
    required this.isNegotiable,
  });

  @override
  List<Object?> get props => [response, serviceId, amount, isNegotiable];
}

class AddServiceError extends AddServiceState {
  final String message;

  const AddServiceError(this.message);

  @override
  List<Object?> get props => [message];
}

class RemoveServiceSuccess extends AddServiceState {
  final int serviceId;

  const RemoveServiceSuccess(this.serviceId);

  @override
  List<Object?> get props => [serviceId];
}
