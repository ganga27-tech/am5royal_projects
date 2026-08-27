import 'package:flutter_bloc/flutter_bloc.dart';
import 'employee_profile_event.dart';
import 'employee_profile_state.dart';
import '../../../data/datasources/employee_api_service.dart';

class EmployeeProfileBloc extends Bloc<EmployeeProfileEvent, EmployeeProfileState> {
  final EmployeeApiService employeeApiService;

  EmployeeProfileBloc({required this.employeeApiService}) : super(EmployeeProfileInitial()) {
    on<LoadEmployeeProfile>(_onLoadEmployeeProfile);
    on<UpdateEmployeeProfile>(_onUpdateEmployeeProfile);
  }

  Future<void> _onLoadEmployeeProfile(LoadEmployeeProfile event, Emitter<EmployeeProfileState> emit) async {
    emit(EmployeeProfileLoading());
    try {
      final profile = await employeeApiService.getEmployeeProfile();
      emit(EmployeeProfileLoaded(profile));
    } catch (e) {
      emit(EmployeeProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateEmployeeProfile(UpdateEmployeeProfile event, Emitter<EmployeeProfileState> emit) async {
    emit(EmployeeProfileLoading());
    try {
      final updatedProfile = await employeeApiService.updateEmployeeProfile(event.profile);
      emit(EmployeeProfileUpdateSuccess(updatedProfile));
    } catch (e) {
      emit(EmployeeProfileError(e.toString()));
    }
  }
}
