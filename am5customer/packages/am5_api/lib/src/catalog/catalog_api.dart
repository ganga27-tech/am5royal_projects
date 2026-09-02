import 'package:dio/dio.dart';
import 'package:am5_core/am5_core.dart';

import '../client/api_client.dart';

class CatalogApi {
  CatalogApi(this._client);

  final ApiClient _client;

  Future<List<CatalogCategory>> listCategories() async {
    try {
      final response = await _client.dio.get('/catalog/categories');
      final list = response.data as List<dynamic>;
      return list.map((e) => CatalogCategory.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<List<CatalogServiceItem>> listServices({
    String? categoryId,
    bool featured = false,
    String? q,
  }) async {
    try {
      final response = await _client.dio.get(
        '/catalog/services',
        queryParameters: {
          if (categoryId != null) 'main_category_id': categoryId,
          if (featured) 'featured': true,
          if (q != null && q.isNotEmpty) 'q': q,
        },
      );
      final list = response.data as List<dynamic>;
      return list.map((e) => CatalogServiceItem.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<CatalogServiceItem> getService(String id) async {
    try {
      final parsedId = int.tryParse(id);
      final services = await listServices();
      final match = services.where((s) => s.id == id).firstOrNull;
      if (match != null) return match;

      if (parsedId != null) {
        final bySubcategory = await _client.dio.get(
          '/catalog/services',
          queryParameters: {'subcategory_id': parsedId},
        );
        final list = bySubcategory.data as List<dynamic>;
        if (list.isNotEmpty) {
          return CatalogServiceItem.fromJson(list.first as Map<String, dynamic>);
        }
      }
      throw const Failure('Service not found');
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<List<CatalogBanner>> listBanners({String? placement, String? city}) async {
    try {
      final response = await _client.dio.get(
        '/images/themeImages',
        queryParameters: {
          if (city != null && city.isNotEmpty) 'city': city,
          'requestedBy': 'customer',
        },
      );
      final data = response.data as Map<String, dynamic>;
      final urls = data['imageUrls'] as List<dynamic>? ?? [];
      return urls.asMap().entries.map((entry) {
        return CatalogBanner(
          id: 'banner-${entry.key}',
          title: 'AM5 Royal',
          imageUrl: entry.value as String,
          placement: placement ?? 'home',
          sortOrder: entry.key,
          isActive: true,
          audience: 'customer',
        );
      }).toList();
    } on DioException {
      return const [];
    }
  }

  // Admin
  Future<CatalogCategory> adminCreateCategory(Map<String, dynamic> body) async {
    try {
      final response = await _client.dio.post('/admin/catalog/categories', data: body);
      return CatalogCategory.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<List<CatalogCategory>> adminListCategories() async {
    try {
      final response = await _client.dio.get('/admin/catalog/categories');
      final list = response.data as List<dynamic>;
      return list.map((e) => CatalogCategory.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<CatalogServiceItem> adminCreateService(Map<String, dynamic> body) async {
    try {
      final response = await _client.dio.post('/admin/catalog/services', data: body);
      return CatalogServiceItem.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<List<CatalogServiceItem>> adminListServices() async {
    try {
      final response = await _client.dio.get('/admin/catalog/services');
      final list = response.data as List<dynamic>;
      return list.map((e) => CatalogServiceItem.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<CatalogBanner> adminCreateBanner(Map<String, dynamic> body) async {
    try {
      final response = await _client.dio.post('/admin/catalog/banners', data: body);
      return CatalogBanner.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<List<CatalogBanner>> adminListBanners() async {
    try {
      final response = await _client.dio.get('/admin/catalog/banners');
      final list = response.data as List<dynamic>;
      return list.map((e) => CatalogBanner.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<CatalogCategory> adminUpdateCategory(String id, Map<String, dynamic> body) async {
    try {
      final response = await _client.dio.patch('/admin/catalog/categories/$id', data: body);
      return CatalogCategory.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<CatalogServiceItem> adminUpdateService(String id, Map<String, dynamic> body) async {
    try {
      final response = await _client.dio.patch('/admin/catalog/services/$id', data: body);
      return CatalogServiceItem.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<CatalogBanner> adminUpdateBanner(String id, Map<String, dynamic> body) async {
    try {
      final response = await _client.dio.patch('/admin/catalog/banners/$id', data: body);
      return CatalogBanner.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }
}
