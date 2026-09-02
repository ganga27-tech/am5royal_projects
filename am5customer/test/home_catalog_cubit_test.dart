import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5customer/features/catalog/presentation/cubit/home_catalog_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockCatalogApi extends Mock implements CatalogApi {}

class _MockSearchApi extends Mock implements SearchApi {}

void main() {
  late _MockCatalogApi catalogApi;
  late _MockSearchApi searchApi;

  setUp(() {
    catalogApi = _MockCatalogApi();
    searchApi = _MockSearchApi();
  });

  blocTest<HomeCatalogCubit, HomeCatalogState>(
    'loads home catalog and discovery sections',
    build: () {
      when(() => catalogApi.listBanners(placement: 'home_hero')).thenAnswer((_) async => []);
      when(() => catalogApi.listCategories()).thenAnswer(
        (_) async => [
          const CatalogCategory(
            id: '1',
            name: 'Cleaning',
            slug: 'cleaning',
            sortOrder: 1,
            isActive: true,
          ),
        ],
      );
      when(() => searchApi.discoverHome()).thenAnswer(
        (_) async => const DiscoverHome(
          featuredServices: [],
          trendingServices: [
            CatalogServiceItem(
              id: 's1',
              categoryId: '1',
              name: 'AC Service',
              slug: 'ac-service',
              basePrice: 599,
              currency: 'INR',
              durationMinutes: 60,
              isActive: true,
              isFeatured: true,
              sortOrder: 1,
            ),
          ],
          popularSearches: [PopularSearch(query: 'ac service', hitCount: 10)],
        ),
      );
      return HomeCatalogCubit(catalogApi, searchApi);
    },
    act: (c) => c.load(),
    expect: () => [
      isA<HomeCatalogState>().having((s) => s.status, 'status', HomeCatalogStatus.loading),
      isA<HomeCatalogState>()
          .having((s) => s.status, 'status', HomeCatalogStatus.ready)
          .having((s) => s.categories.length, 'cats', 1)
          .having((s) => s.trending.length, 'trending', 1)
          .having((s) => s.popularSearches.length, 'popular', 1),
    ],
  );
}
