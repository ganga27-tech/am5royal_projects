import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_admin_stats.dart';
import '../../domain/usecases/get_admin_employees.dart';
import '../../domain/usecases/get_admin_vendors.dart';
import '../../domain/usecases/update_employee_status.dart';
import '../../domain/usecases/update_vendor_status.dart';
import '../../domain/usecases/create_employee.dart';
import '../../domain/usecases/update_employee.dart';
import '../../domain/usecases/create_vendor.dart';
import '../../domain/usecases/create_service.dart';
import '../../domain/usecases/update_vendor.dart';
import '../../domain/usecases/delete_vendor.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final GetAdminStats getAdminStats;
  final GetAdminEmployees getAdminEmployees;
  final GetAdminVendors getAdminVendors;
  final UpdateEmployeeStatus updateEmployeeStatus;
  final UpdateVendorStatus updateVendorStatus;
  final CreateEmployee createEmployee;
  final UpdateEmployee updateEmployee;
  final CreateVendor createVendor;
  final CreateService createService;
  final UpdateVendor updateVendor;
  final DeleteVendor deleteVendor;

  AdminBloc({
    required this.getAdminStats,
    required this.getAdminEmployees,
    required this.getAdminVendors,
    required this.updateEmployeeStatus,
    required this.updateVendorStatus,
    required this.createEmployee,
    required this.updateEmployee,
    required this.createVendor,
    required this.createService,
    required this.updateVendor,
    required this.deleteVendor,
  }) : super(const AdminState()) {
    on<FetchAdminDashboardStats>((event, emit) async {
      emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
      final result = await getAdminStats(NoParams());
      result.fold(
        (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
        (stats) => emit(state.copyWith(isLoading: false, stats: stats)),
      );
    });

    on<FetchAdminEmployeesList>((event, emit) async {
      emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
      final result = await getAdminEmployees(NoParams());
      result.fold(
        (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
        (employees) => emit(state.copyWith(isLoading: false, employees: employees)),
      );
    });

    on<FetchAdminVendorsList>((event, emit) async {
      emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
      final result = await getAdminVendors(GetAdminVendorsParams(searchQuery: event.searchQuery));
      result.fold(
        (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
        (vendors) => emit(state.copyWith(isLoading: false, vendors: vendors)),
      );
    });

    on<UpdateEmployeeAccountStatus>((event, emit) async {
      emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
      final result = await updateEmployeeStatus(
        UpdateEmployeeStatusParams(employeeId: event.employeeId, status: event.status),
      );
      result.fold(
        (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
        (_) {
          emit(state.copyWith(isLoading: false, successMessage: 'Employee status updated successfully'));
          add(FetchAdminEmployeesList()); // Refresh list
        },
      );
    });

    on<UpdateVendorAccountStatus>((event, emit) async {
      emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
      final result = await updateVendorStatus(
        UpdateVendorStatusParams(vendorId: event.vendorId, status: event.status),
      );
      result.fold(
        (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
        (_) {
          emit(state.copyWith(isLoading: false, successMessage: 'Vendor status updated successfully'));
          add(FetchAdminVendorsList()); // Refresh list
        },
      );
    });

    on<CreateEmployeeSubmitted>((event, emit) async {
      emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
      final result = await createEmployee(CreateEmployeeParams(data: event.data));
      result.fold(
        (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
        (_) {
          emit(state.copyWith(isLoading: false, successMessage: 'Employee created successfully'));
          add(FetchAdminEmployeesList()); // Refresh the list
        },
      );
    });

    on<UpdateEmployeeSubmitted>((event, emit) async {
      emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
      final result = await updateEmployee(UpdateEmployeeParams(id: event.employeeId, data: event.data));
      result.fold(
        (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
        (_) {
          emit(state.copyWith(isLoading: false, successMessage: 'Employee updated successfully'));
          add(FetchAdminEmployeesList()); // Refresh the list
        },
      );
    });

    on<CreateVendorSubmitted>((event, emit) async {
      emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
      final result = await createVendor(CreateVendorParams(data: event.data));
      result.fold(
        (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
        (_) {
          emit(state.copyWith(isLoading: false, successMessage: 'Vendor created successfully'));
          add(FetchAdminVendorsList()); // Refresh the list
        },
      );
    });

    on<CreateServiceSubmitted>((event, emit) async {
      emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
      final result = await createService(event.name, event.mainCategoryId, event.subCategoryId, event.imagePath);
      result.fold(
        (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
        (_) {
          emit(state.copyWith(isLoading: false, successMessage: 'Service created successfully'));
        },
      );
    });

    on<UpdateVendorSubmitted>((event, emit) async {
      emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
      final result = await updateVendor(UpdateVendorParams(id: event.vendorId, data: event.data));
      result.fold(
        (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
        (_) {
          emit(state.copyWith(isLoading: false, successMessage: 'Vendor updated successfully'));
          add(FetchAdminVendorsList());
        },
      );
    });

    on<DeleteVendorSubmitted>((event, emit) async {
      emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
      final result = await deleteVendor(DeleteVendorParams(id: event.vendorId));
      result.fold(
        (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
        (_) {
          emit(state.copyWith(isLoading: false, successMessage: 'Vendor deleted successfully'));
          add(FetchAdminVendorsList());
        },
      );
    });
  }
}
