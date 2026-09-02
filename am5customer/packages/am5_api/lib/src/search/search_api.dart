import 'dart:convert';

import 'package:am5_core/am5_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../client/api_client.dart';
import '../catalog/catalog_api.dart';

/// Catalog-backed search adapter for AM5 backend (no dedicated search service).
class SearchApi {
  SearchApi(this._client) : _catalogApi = CatalogApi(_client);

  final ApiClient _client;
  final CatalogApi _catalogApi;

  static const _historyKey = 'am5_search_history';
  static const _popularQueries = [
  'AC repair',
  'Home cleaning',
  'Plumbing',
  'Electrician',
  'Salon at home',
  ];

  Future<SearchPageResult> search({
    String? q,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    bool featured = false,
    String sort = 'relevance',
    int limit = 20,
    int offset = 0,
    String locale = 'en',
  }) async {
    final query = q?.trim().toLowerCase() ?? '';
    var services = await _catalogApi.listServices(
      categoryId: categoryId,
      featured: featured,
    );

    if (query.isNotEmpty) {
      services = services.where((s) {
        final haystack = '${s.name} ${s.shortDescription ?? ''} ${s.description ?? ''}'
            .toLowerCase();
        return haystack.contains(query);
      }).toList();
    }

    if (minPrice != null) {
      services = services.where((s) => s.basePrice >= minPrice).toList();
    }
    if (maxPrice != null) {
      services = services.where((s) => s.basePrice <= maxPrice).toList();
    }

    if (sort == 'price_asc') {
      services.sort((a, b) => a.basePrice.compareTo(b.basePrice));
    } else if (sort == 'price_desc') {
      services.sort((a, b) => b.basePrice.compareTo(a.basePrice));
    } else {
      services.sort((a, b) => a.name.compareTo(b.name));
    }

    if (query.isNotEmpty) {
      await _appendHistory(query, services.length);
    }

    final slice = services.skip(offset).take(limit).toList();
    return SearchPageResult(
      query: q,
      total: services.length,
      items: slice,
      sort: sort,
    );
  }

  Future<SearchSuggest> suggest({required String q, int limit = 8}) async {
    final query = q.trim().toLowerCase();
    if (query.length < 2) {
      return const SearchSuggest();
    }

    final categories = await _catalogApi.listCategories();
    final services = await _catalogApi.listServices();

    final matchedCategories = categories
        .where((c) => c.name.toLowerCase().contains(query))
        .take(limit)
        .toList();
    final matchedServices = services
        .where((s) => s.name.toLowerCase().contains(query))
        .take(limit)
        .toList();
    final matchedQueries = _popularQueries
        .where((item) => item.toLowerCase().contains(query))
        .take(limit)
        .toList();

    return SearchSuggest(
      services: matchedServices,
      categories: matchedCategories,
      queries: matchedQueries,
    );
  }

  Future<List<PopularSearch>> popular({String locale = 'en', int limit = 10}) async {
    return _popularQueries
        .take(limit)
        .map((q) => PopularSearch(query: q, hitCount: 0))
        .toList();
  }

  Future<List<SearchHistoryItem>> history({int limit = 20}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyKey) ?? [];
    return raw
        .take(limit)
        .map((entry) {
          final decoded = jsonDecode(entry) as Map<String, dynamic>;
          return SearchHistoryItem.fromJson(decoded);
        })
        .toList();
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  Future<DiscoverHome> discoverHome({String locale = 'en'}) async {
    final categories = await _catalogApi.listCategories();
    var services = await _catalogApi.listServices();
    if (services.isEmpty && categories.isNotEmpty) {
      services = await _catalogApi.listServices(categoryId: categories.first.id);
    }

    final featured = services.take(6).toList();
    final trending = services.skip(featured.length).take(6).toList();

    return DiscoverHome(
      popularSearches: await popular(limit: 6),
      featuredServices: featured,
      trendingServices: trending,
      recentlyViewed: const [],
    );
  }

  Future<void> trackViewed(String serviceId) async {
    // AM5 has no recently-viewed endpoint; no-op for now.
  }

  Future<void> _appendHistory(String query, int resultCount) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_historyKey) ?? [];
    final entry = jsonEncode({
      'query': query,
      'result_count': resultCount,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
    final updated = [
      entry,
      ...existing.where((e) {
        try {
          final map = jsonDecode(e) as Map<String, dynamic>;
          return (map['query'] as String?)?.toLowerCase() != query.toLowerCase();
        } catch (_) {
          return true;
        }
      }),
    ].take(20).toList();
    await prefs.setStringList(_historyKey, updated);
  }
}
