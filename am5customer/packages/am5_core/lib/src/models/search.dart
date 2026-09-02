import 'package:equatable/equatable.dart';

import 'catalog.dart';

class PopularSearch extends Equatable {
  const PopularSearch({required this.query, required this.hitCount});

  final String query;
  final int hitCount;

  factory PopularSearch.fromJson(Map<String, dynamic> json) {
    return PopularSearch(
      query: json['query'] as String,
      hitCount: json['hit_count'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [query, hitCount];
}

class SearchHistoryItem extends Equatable {
  const SearchHistoryItem({
    required this.query,
    required this.resultCount,
    required this.createdAt,
  });

  final String query;
  final int resultCount;
  final String createdAt;

  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) {
    return SearchHistoryItem(
      query: json['query'] as String,
      resultCount: json['result_count'] as int? ?? 0,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [query, createdAt];
}

class SearchSuggest extends Equatable {
  const SearchSuggest({
    this.services = const [],
    this.categories = const [],
    this.queries = const [],
  });

  final List<CatalogServiceItem> services;
  final List<CatalogCategory> categories;
  final List<String> queries;

  factory SearchSuggest.fromJson(Map<String, dynamic> json) {
    return SearchSuggest(
      services: (json['services'] as List<dynamic>? ?? [])
          .map((e) => CatalogServiceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((e) => CatalogCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      queries: (json['queries'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
    );
  }

  @override
  List<Object?> get props => [services, categories, queries];
}

class SearchPageResult extends Equatable {
  const SearchPageResult({
    required this.total,
    required this.items,
    required this.sort,
    this.query,
  });

  final String? query;
  final int total;
  final List<CatalogServiceItem> items;
  final String sort;

  factory SearchPageResult.fromJson(Map<String, dynamic> json) {
    return SearchPageResult(
      query: json['query'] as String?,
      total: json['total'] as int? ?? 0,
      sort: json['sort'] as String? ?? 'relevance',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => CatalogServiceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [query, total, items, sort];
}

class DiscoverHome extends Equatable {
  const DiscoverHome({
    this.popularSearches = const [],
    this.trendingServices = const [],
    this.featuredServices = const [],
    this.recentlyViewed = const [],
  });

  final List<PopularSearch> popularSearches;
  final List<CatalogServiceItem> trendingServices;
  final List<CatalogServiceItem> featuredServices;
  final List<CatalogServiceItem> recentlyViewed;

  factory DiscoverHome.fromJson(Map<String, dynamic> json) {
    return DiscoverHome(
      popularSearches: (json['popular_searches'] as List<dynamic>? ?? [])
          .map((e) => PopularSearch.fromJson(e as Map<String, dynamic>))
          .toList(),
      trendingServices: (json['trending_services'] as List<dynamic>? ?? [])
          .map((e) => CatalogServiceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      featuredServices: (json['featured_services'] as List<dynamic>? ?? [])
          .map((e) => CatalogServiceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentlyViewed: (json['recently_viewed'] as List<dynamic>? ?? [])
          .map((e) => CatalogServiceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props =>
      [popularSearches, trendingServices, featuredServices, recentlyViewed];
}
