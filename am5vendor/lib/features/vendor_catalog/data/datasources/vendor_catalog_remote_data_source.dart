import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/vendor_catalog_models.dart';

class VendorCatalogRemoteDataSource {
  final Dio dio;

  VendorCatalogRemoteDataSource(this.dio);

  Future<VendorCatalogModel> fetchCatalog() async {
    try {
      final response = await dio.get('/vendors/me/catalog');
      return VendorCatalogModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      throw ServerException(_messageFromDio(e));
    }
  }

  Future<void> addCategories({
    required int mainCategoryId,
    required List<int> subCategoryIds,
  }) async {
    try {
      await dio.post(
        '/vendors/me/categories',
        data: {
          'main_category_id': mainCategoryId,
          'sub_category_ids': subCategoryIds,
        },
      );
    } on DioException catch (e) {
      throw ServerException(_messageFromDio(e));
    }
  }

  Future<void> removeSubCategory(int subCategoryId) async {
    try {
      await dio.delete('/vendors/me/categories/sub-categories/$subCategoryId');
    } on DioException catch (e) {
      throw ServerException(_messageFromDio(e));
    }
  }

  Future<void> updateService({
    required int vendorServiceId,
    required double price,
    String? description,
    required bool negotiable,
    List<Map<String, String>>? media,
  }) async {
    try {
      await dio.put(
        '/vendors/me/services/$vendorServiceId',
        data: {
          'price': price,
          'description': description,
          'negotiable': negotiable,
          if (media != null) 'media': media,
        },
      );
    } on DioException catch (e) {
      throw ServerException(_messageFromDio(e));
    }
  }

  Future<void> deleteService(int vendorServiceId) async {
    try {
      await dio.delete('/vendors/me/services/$vendorServiceId');
    } on DioException catch (e) {
      throw ServerException(_messageFromDio(e));
    }
  }

  Future<int> proceedToPayment() async {
    try {
      final response = await dio.post('/vendors/me/catalog/proceed');
      return response.data['active_services'] as int? ?? 0;
    } on DioException catch (e) {
      throw ServerException(_messageFromDio(e));
    }
  }

  String _messageFromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['detail'] != null) {
      return data['detail'].toString();
    }
    return e.message ?? 'Request failed';
  }
}
