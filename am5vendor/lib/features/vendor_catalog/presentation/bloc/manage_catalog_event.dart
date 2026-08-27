import 'package:equatable/equatable.dart';

abstract class ManageCatalogEvent extends Equatable {
  const ManageCatalogEvent();

  @override
  List<Object?> get props => [];
}

class LoadVendorCatalog extends ManageCatalogEvent {
  const LoadVendorCatalog();
}

class RemoveSubCategoryEvent extends ManageCatalogEvent {
  final int subCategoryId;
  const RemoveSubCategoryEvent(this.subCategoryId);

  @override
  List<Object?> get props => [subCategoryId];
}

class DeleteServiceEvent extends ManageCatalogEvent {
  final int vendorServiceId;
  const DeleteServiceEvent(this.vendorServiceId);

  @override
  List<Object?> get props => [vendorServiceId];
}

class UpdateServiceEvent extends ManageCatalogEvent {
  final int vendorServiceId;
  final double price;
  final String? description;
  final bool negotiable;
  final List<Map<String, String>> media;

  const UpdateServiceEvent({
    required this.vendorServiceId,
    required this.price,
    this.description,
    required this.negotiable,
    this.media = const [],
  });

  @override
  List<Object?> get props =>
      [vendorServiceId, price, description, negotiable, media];
}

class ProceedToPaymentEvent extends ManageCatalogEvent {
  const ProceedToPaymentEvent();
}
