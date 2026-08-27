import 'package:equatable/equatable.dart';

abstract class BusinessRegistrationState extends Equatable {
  const BusinessRegistrationState();

  @override
  List<Object?> get props => [];
}

class BusinessRegistrationInitial extends BusinessRegistrationState {}

class BusinessRegistrationLoading extends BusinessRegistrationState {}

class BusinessRegistrationSuccess extends BusinessRegistrationState {}

class BusinessRegistrationFailure extends BusinessRegistrationState {
  final String message;

  const BusinessRegistrationFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
