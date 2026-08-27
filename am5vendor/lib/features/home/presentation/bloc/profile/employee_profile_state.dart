import 'package:equatable/equatable.dart';
import '../../../../home/data/models/employee_profile_model.dart';

abstract class EmployeeProfileState extends Equatable {
  const EmployeeProfileState();

  @override
  List<Object?> get props => [];
}

class EmployeeProfileInitial extends EmployeeProfileState {}

class EmployeeProfileLoading extends EmployeeProfileState {}

class EmployeeProfileLoaded extends EmployeeProfileState {
  final EmployeeProfileModel profile;

  const EmployeeProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class EmployeeProfileUpdateSuccess extends EmployeeProfileState {
  final EmployeeProfileModel profile;

  const EmployeeProfileUpdateSuccess(this.profile);

  @override
  List<Object?> get props => [profile];
}

class EmployeeProfileError extends EmployeeProfileState {
  final String message;

  const EmployeeProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
