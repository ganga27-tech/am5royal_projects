import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_stats.dart';
import '../../domain/entities/admin_employee.dart';
import '../../domain/entities/admin_vendor.dart';

class AdminState extends Equatable {
  final bool isLoading;
  final AdminStats? stats;
  final List<AdminEmployee>? employees;
  final List<AdminVendor>? vendors;
  final String? error;
  final String? successMessage;

  const AdminState({
    this.isLoading = false,
    this.stats,
    this.employees,
    this.vendors,
    this.error,
    this.successMessage,
  });

  AdminState copyWith({
    bool? isLoading,
    AdminStats? stats,
    List<AdminEmployee>? employees,
    List<AdminVendor>? vendors,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      employees: employees ?? this.employees,
      vendors: vendors ?? this.vendors,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [isLoading, stats, employees, vendors, error, successMessage];
}
