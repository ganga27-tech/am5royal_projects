import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';

class HomeCatalogCubit extends Cubit<HomeCatalogState> {
  HomeCatalogCubit(
    this._catalogApi,
    this._searchApi, [
    this._professionalsApi,
  ]) : super(const HomeCatalogState.initial());

  final CatalogApi _catalogApi;
  final SearchApi _searchApi;
  final ProfessionalsApi? _professionalsApi;

  Future<void> load({String? pincode, String? city}) async {
    emit(state.copyWith(status: HomeCatalogStatus.loading, clearMessage: true));
    try {
      final categories = await _catalogApi.listCategories();
      List<CatalogServiceItem> featured = const [];
      List<CatalogBanner> banners = const [];
      List<Professional> nearbyVendors = const [];

      if (_professionalsApi != null) {
        try {
          nearbyVendors = await _professionalsApi.listProfessionals(
            pincode: pincode,
            city: city,
            limit: 20,
          );
        } catch (_) {
          nearbyVendors = const [];
        }
      }

      try {
        featured = await _catalogApi.listServices(featured: true);
      } catch (_) {
        featured = const [];
      }
      try {
        banners = await _catalogApi.listBanners(placement: 'home');
      } catch (_) {
        banners = const [];
      }

      DiscoverHome? discover;
      try {
        discover = await _searchApi.discoverHome();
      } catch (_) {
        discover = null;
      }

      emit(
        state.copyWith(
          status: HomeCatalogStatus.ready,
          banners: banners,
          categories: categories,
          featured: discover?.featuredServices ?? featured,
          trending: discover?.trendingServices ?? const [],
          recentlyViewed: discover?.recentlyViewed ?? const [],
          popularSearches: discover?.popularSearches ?? const [],
          nearbyVendors: nearbyVendors,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(status: HomeCatalogStatus.error, message: f.message));
    } catch (_) {
      emit(state.copyWith(status: HomeCatalogStatus.error, message: 'Failed to load catalog'));
    }
  }
}

enum HomeCatalogStatus { initial, loading, ready, error }

class HomeCatalogState extends Equatable {
  const HomeCatalogState({
    required this.status,
    this.banners = const [],
    this.categories = const [],
    this.featured = const [],
    this.trending = const [],
    this.recentlyViewed = const [],
    this.popularSearches = const [],
    this.nearbyVendors = const [],
    this.message,
  });

  const HomeCatalogState.initial() : this(status: HomeCatalogStatus.initial);

  final HomeCatalogStatus status;
  final List<CatalogBanner> banners;
  final List<CatalogCategory> categories;
  final List<CatalogServiceItem> featured;
  final List<CatalogServiceItem> trending;
  final List<CatalogServiceItem> recentlyViewed;
  final List<PopularSearch> popularSearches;
  final List<Professional> nearbyVendors;
  final String? message;

  HomeCatalogState copyWith({
    HomeCatalogStatus? status,
    List<CatalogBanner>? banners,
    List<CatalogCategory>? categories,
    List<CatalogServiceItem>? featured,
    List<CatalogServiceItem>? trending,
    List<CatalogServiceItem>? recentlyViewed,
    List<PopularSearch>? popularSearches,
    List<Professional>? nearbyVendors,
    String? message,
    bool clearMessage = false,
  }) {
    return HomeCatalogState(
      status: status ?? this.status,
      banners: banners ?? this.banners,
      categories: categories ?? this.categories,
      featured: featured ?? this.featured,
      trending: trending ?? this.trending,
      recentlyViewed: recentlyViewed ?? this.recentlyViewed,
      popularSearches: popularSearches ?? this.popularSearches,
      nearbyVendors: nearbyVendors ?? this.nearbyVendors,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [
        status,
        banners,
        categories,
        featured,
        trending,
        recentlyViewed,
        popularSearches,
        nearbyVendors,
        message,
      ];
}
