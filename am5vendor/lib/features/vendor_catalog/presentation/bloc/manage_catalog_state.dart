import 'package:equatable/equatable.dart';
import '../../data/models/vendor_catalog_models.dart';

abstract class ManageCatalogState extends Equatable {
  const ManageCatalogState();

  @override
  List<Object?> get props => [];
}

class ManageCatalogInitial extends ManageCatalogState {}

class ManageCatalogLoading extends ManageCatalogState {}

class ManageCatalogLoaded extends ManageCatalogState {
  final VendorCatalogModel catalog;

  const ManageCatalogLoaded(this.catalog);

  @override
  List<Object?> get props => [catalog];
}

class ManageCatalogActionInProgress extends ManageCatalogState {
  final VendorCatalogModel? catalog;
  const ManageCatalogActionInProgress({this.catalog});

  @override
  List<Object?> get props => [catalog];
}

class ManageCatalogProceedReady extends ManageCatalogState {
  final int activeServices;
  const ManageCatalogProceedReady(this.activeServices);

  @override
  List<Object?> get props => [activeServices];
}

class ManageCatalogError extends ManageCatalogState {
  final String message;
  final VendorCatalogModel? catalog;

  const ManageCatalogError(this.message, {this.catalog});

  @override
  List<Object?> get props => [message, catalog];
}
