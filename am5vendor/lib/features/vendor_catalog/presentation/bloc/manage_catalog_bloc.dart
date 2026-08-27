import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/vendor_catalog_models.dart';
import '../../data/repositories/vendor_catalog_repository.dart';
import 'manage_catalog_event.dart';
import 'manage_catalog_state.dart';

class ManageCatalogBloc extends Bloc<ManageCatalogEvent, ManageCatalogState> {
  final VendorCatalogRepository repository;

  ManageCatalogBloc({required this.repository}) : super(ManageCatalogInitial()) {
    on<LoadVendorCatalog>(_onLoad);
    on<RemoveSubCategoryEvent>(_onRemoveSubCategory);
    on<DeleteServiceEvent>(_onDeleteService);
    on<UpdateServiceEvent>(_onUpdateService);
    on<ProceedToPaymentEvent>(_onProceed);
  }

  VendorCatalogModel? get _cachedCatalog {
    final current = state;
    if (current is ManageCatalogLoaded) return current.catalog;
    if (current is ManageCatalogActionInProgress) return current.catalog;
    if (current is ManageCatalogError) return current.catalog;
    return null;
  }

  VendorCatalogModel _filterVisibleCatalog(VendorCatalogModel catalog) {
    final categories = catalog.categories
        .map((category) {
          final visibleSubs = category.subCategories
              .where((sub) => sub.activeServices.isNotEmpty)
              .toList();
          return VendorCatalogMainCategoryModel(
            mainCategoryId: category.mainCategoryId,
            mainCategoryName: category.mainCategoryName,
            iconUrl: category.iconUrl,
            subCategories: visibleSubs,
          );
        })
        .where((category) => category.subCategories.isNotEmpty)
        .toList();

    return VendorCatalogModel(
      categories: categories,
      totalServices: catalog.totalServices,
      totalActiveServices: catalog.totalActiveServices,
    );
  }

  Future<void> _onLoad(
    LoadVendorCatalog event,
    Emitter<ManageCatalogState> emit,
  ) async {
    emit(ManageCatalogLoading());
    final result = await repository.getCatalog();
    result.fold(
      (failure) => emit(ManageCatalogError(failure.message)),
      (catalog) => emit(ManageCatalogLoaded(_filterVisibleCatalog(catalog))),
    );
  }

  Future<void> _reload(Emitter<ManageCatalogState> emit) async {
    final cached = _cachedCatalog;
    emit(ManageCatalogActionInProgress(catalog: cached));
    final result = await repository.getCatalog();
    result.fold(
      (failure) => emit(ManageCatalogError(failure.message, catalog: cached)),
      (catalog) => emit(ManageCatalogLoaded(_filterVisibleCatalog(catalog))),
    );
  }

  Future<void> _onRemoveSubCategory(
    RemoveSubCategoryEvent event,
    Emitter<ManageCatalogState> emit,
  ) async {
    final cached = _cachedCatalog;
    emit(ManageCatalogActionInProgress(catalog: cached));
    final result = await repository.removeSubCategory(event.subCategoryId);
    if (result.isLeft()) {
      emit(ManageCatalogError(
        result.fold((f) => f.message, (_) => ''),
        catalog: cached,
      ));
      return;
    }
    await _reload(emit);
  }

  Future<void> _onDeleteService(
    DeleteServiceEvent event,
    Emitter<ManageCatalogState> emit,
  ) async {
    final cached = _cachedCatalog;
    emit(ManageCatalogActionInProgress(catalog: cached));
    final result = await repository.deleteService(event.vendorServiceId);
    if (result.isLeft()) {
      emit(ManageCatalogError(
        result.fold((f) => f.message, (_) => ''),
        catalog: cached,
      ));
      return;
    }
    await _reload(emit);
  }

  Future<void> _onUpdateService(
    UpdateServiceEvent event,
    Emitter<ManageCatalogState> emit,
  ) async {
    final cached = _cachedCatalog;
    emit(ManageCatalogActionInProgress(catalog: cached));
    final result = await repository.updateService(
      vendorServiceId: event.vendorServiceId,
      price: event.price,
      description: event.description,
      negotiable: event.negotiable,
      media: event.media,
    );
    if (result.isLeft()) {
      emit(ManageCatalogError(
        result.fold((f) => f.message, (_) => ''),
        catalog: cached,
      ));
      return;
    }
    await _reload(emit);
  }

  Future<void> _onProceed(
    ProceedToPaymentEvent event,
    Emitter<ManageCatalogState> emit,
  ) async {
    final cached = _cachedCatalog;
    emit(ManageCatalogActionInProgress(catalog: cached));
    final result = await repository.proceedToPayment();
    result.fold(
      (failure) => emit(ManageCatalogError(failure.message, catalog: cached)),
      (count) => emit(ManageCatalogProceedReady(count)),
    );
  }
}
