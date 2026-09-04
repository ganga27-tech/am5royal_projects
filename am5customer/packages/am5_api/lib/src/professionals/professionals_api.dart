import 'package:dio/dio.dart';
import 'package:am5_core/am5_core.dart';

import '../client/api_client.dart';
import '../catalog/catalog_api.dart';

class ProfessionalsApi {
  ProfessionalsApi(this._client);

  final ApiClient _client;

  Future<List<Professional>> listProfessionals({
    String? q,
    String? city,
    String? pincode,
    String? categoryId,
    String? serviceId,
    double? latitude,
    double? longitude,
    bool verified = false,
    bool available = false,
    String sort = 'rating',
    int limit = 50,
  }) async {
    try {
      final parsedServiceId = int.tryParse(serviceId ?? '');
      final parsedCategoryId = int.tryParse(categoryId ?? '');

      final queryParams = <String, dynamic>{
        'limit': limit,
        if (parsedCategoryId != null) 'category_id': parsedCategoryId,
        if (parsedServiceId != null) 'subcategory_id': parsedServiceId,
        if (pincode != null && pincode.isNotEmpty) 'pincode': pincode,
        if (city != null && city.isNotEmpty && pincode == null) 'pincode': city,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };

      var response = await _client.dio.get(
        '/catalog/vendors',
        queryParameters: queryParams,
      );
      var list = (response.data as List<dynamic>);
      if (list.isEmpty && parsedServiceId != null) {
        queryParams.remove('subcategory_id');
        queryParams['service_id'] = parsedServiceId;
        response = await _client.dio.get(
          '/catalog/vendors',
          queryParameters: queryParams,
        );
        list = response.data as List<dynamic>;
      }

      var professionals = list
          .map((e) => Professional.fromAm5Vendor(e as Map<String, dynamic>))
          .toList();

      if (verified) {
        professionals = professionals.where((p) => p.isVerified).toList();
      }
      if (q != null && q.isNotEmpty) {
        final query = q.toLowerCase();
        professionals = professionals
            .where(
              (p) =>
                  p.displayName.toLowerCase().contains(query) ||
                  (p.city?.toLowerCase().contains(query) ?? false),
            )
            .toList();
      }
      if (sort == 'rating') {
        professionals.sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));
      }
      return professionals;
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<Professional> getProfessional(String id, {String? serviceId}) async {
    try {
      final direct = await _findVendorInList(id);
      if (direct != null) return direct;

      if (serviceId != null) {
        final parsed = int.tryParse(serviceId);
        if (parsed != null) {
          final match = await _findVendorInList(id, subcategoryId: parsed);
          if (match != null) return match;
          final match2 = await _findVendorInList(id, serviceId: parsed);
          if (match2 != null) return match2;
        }
      }

      final categories = await CatalogApi(_client).listCategories();
      for (final category in categories) {
        final parsedCategoryId = int.tryParse(category.id);
        if (parsedCategoryId == null) continue;
        final match = await _findVendorInList(id, categoryId: parsedCategoryId);
        if (match != null) return match;
      }

      throw const Failure('Professional not found');
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<Professional?> _findVendorInList(
    String vendorId, {
    int? categoryId,
    int? subcategoryId,
    int? serviceId,
  }) async {
    final response = await _client.dio.get(
      '/catalog/vendors',
      queryParameters: {
        if (categoryId != null) 'category_id': categoryId,
        if (subcategoryId != null) 'subcategory_id': subcategoryId,
        if (serviceId != null) 'service_id': serviceId,
      },
    );
    final list = response.data as List<dynamic>;
    for (final raw in list) {
      final map = raw as Map<String, dynamic>;
      if (map['id']?.toString() == vendorId) {
        return Professional.fromAm5Vendor(map);
      }
    }
    return null;
  }

  Future<List<ProfessionalReview>> listReviews(String professionalId) async {
    return const [];
  }

  Future<ProfessionalReview> createReview(
    String professionalId, {
    required int rating,
    String? title,
    String? body,
    String? serviceId,
  }) async {
    throw const Failure('Reviews are not available yet.');
  }

  Future<Professional> upsertMyProfile(Map<String, dynamic> body) async {
    throw const Failure('Partner profile is not available in the customer app.');
  }

  Future<Professional?> getMyProfile() async {
    return null;
  }
}
