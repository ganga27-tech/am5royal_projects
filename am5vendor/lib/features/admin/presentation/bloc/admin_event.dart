import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class FetchAdminDashboardStats extends AdminEvent {}

class FetchAdminEmployeesList extends AdminEvent {}

class FetchAdminVendorsList extends AdminEvent {
  final String? searchQuery;

  const FetchAdminVendorsList({this.searchQuery});

  @override
  List<Object?> get props => [searchQuery];
}

class UpdateEmployeeAccountStatus extends AdminEvent {
  final int employeeId;
  final String status;

  const UpdateEmployeeAccountStatus(this.employeeId, this.status);

  @override
  List<Object?> get props => [employeeId, status];
}

class UpdateVendorAccountStatus extends AdminEvent {
  final int vendorId;
  final String status;

  const UpdateVendorAccountStatus(this.vendorId, this.status);

  @override
  List<Object> get props => [vendorId, status];
}

class CreateEmployeeSubmitted extends AdminEvent {
  final Map<String, dynamic> data;

  const CreateEmployeeSubmitted(this.data);

  @override
  List<Object> get props => [data];
}

class UpdateEmployeeSubmitted extends AdminEvent {
  final int employeeId;
  final Map<String, dynamic> data;

  const UpdateEmployeeSubmitted(this.employeeId, this.data);

  @override
  List<Object> get props => [employeeId, data];
}

class CreateVendorSubmitted extends AdminEvent {
  final Map<String, dynamic> data;

  const CreateVendorSubmitted(this.data);

  @override
  List<Object> get props => [data];
}

class UpdateVendorSubmitted extends AdminEvent {
  final int vendorId;
  final Map<String, dynamic> data;

  const UpdateVendorSubmitted(this.vendorId, this.data);

  @override
  List<Object> get props => [vendorId, data];
}

class DeleteVendorSubmitted extends AdminEvent {
  final int vendorId;

  const DeleteVendorSubmitted(this.vendorId);

  @override
  List<Object> get props => [vendorId];
}

class CreateServiceSubmitted extends AdminEvent {
  final String name;
  final int mainCategoryId;
  final int subCategoryId;
  final String imagePath;

  const CreateServiceSubmitted({
    required this.name,
    required this.mainCategoryId,
    required this.subCategoryId,
    required this.imagePath,
  });

  @override
  List<Object> get props => [name, mainCategoryId, subCategoryId, imagePath];
}
