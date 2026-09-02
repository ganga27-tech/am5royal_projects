import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:am5_api/am5_api.dart';
import 'package:am5_core/am5_core.dart';
import 'package:am5customer/features/search/presentation/cubit/search_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockSearchApi extends Mock implements SearchApi {}

void main() {
  late _MockSearchApi api;

  setUp(() => api = _MockSearchApi());

  blocTest<SearchCubit, SearchViewState>(
    'bootstrap loads popular and history',
    build: () {
      when(() => api.popular()).thenAnswer(
        (_) async => [const PopularSearch(query: 'cleaning', hitCount: 5)],
      );
      when(() => api.history()).thenAnswer((_) async => []);
      return SearchCubit(api);
    },
    act: (c) => c.bootstrap(),
    expect: () => [
      isA<SearchViewState>().having((s) => s.bootStatus, 'boot', SearchBootStatus.loading),
      isA<SearchViewState>()
          .having((s) => s.bootStatus, 'boot', SearchBootStatus.ready)
          .having((s) => s.popular.length, 'popular', 1),
    ],
  );

  blocTest<SearchCubit, SearchViewState>(
    'submit returns search results',
    build: () {
      when(() => api.search(q: 'ac', sort: 'relevance')).thenAnswer(
        (_) async => const SearchPageResult(
          query: 'ac',
          total: 1,
          sort: 'relevance',
          items: [
            CatalogServiceItem(
              id: '1',
              categoryId: 'c1',
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
        ),
      );
      when(() => api.history()).thenAnswer((_) async => []);
      return SearchCubit(api);
    },
    seed: () => const SearchViewState(
      bootStatus: SearchBootStatus.ready,
      status: SearchStatus.idle,
      query: '',
      sort: 'relevance',
    ),
    act: (c) => c.submit(query: 'ac'),
    expect: () => [
      isA<SearchViewState>()
          .having((s) => s.status, 'status', SearchStatus.searching)
          .having((s) => s.query, 'query', 'ac'),
      isA<SearchViewState>()
          .having((s) => s.status, 'status', SearchStatus.results)
          .having((s) => s.result?.total, 'total', 1),
    ],
  );
}
