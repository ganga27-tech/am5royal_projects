import 'package:equatable/equatable.dart';
import '../../../../home/data/models/employee_profile_model.dart';

abstract class EmployeeProfileEvent extends Equatable {
  const EmployeeProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadEmployeeProfile extends EmployeeProfileEvent {}

class UpdateEmployeeProfile extends EmployeeProfileEvent {
  final EmployeeProfileModel profile;

  const UpdateEmployeeProfile(this.profile);

  @override
  List<Object?> get props => [profile];
}
