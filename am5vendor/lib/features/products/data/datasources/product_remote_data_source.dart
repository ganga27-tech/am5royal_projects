import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({String? search});
  Future<ProductModel> getProduct(String id);
  Future<ProductModel> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required String imageUrl,
    required String category,
  });
  Future<ProductModel> updateProduct({
    required String id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? imageUrl,
    String? category,
  });
  Future<ProductModel> deleteProduct(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<ProductModel>> getProducts({String? search}) async {
    try {
      final response = await apiClient.dio.get(
        '/products',
        queryParameters: search != null ? {'search': search} : null,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to load products');
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = (data is Map ? (data['message'] ?? data['detail']) : null)
          ?.toString();
      throw ServerException(message ?? e.message ?? 'Network request failed');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ProductModel> getProduct(String id) async {
    try {
      final response = await apiClient.dio.get('/products/$id');

      if (response.statusCode == 200) {
        return ProductModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to load product details');
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = (data is Map ? (data['message'] ?? data['detail']) : null)
          ?.toString();
      throw ServerException(message ?? e.message ?? 'Network request failed');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ProductModel> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required String imageUrl,
    required String category,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/products',
        data: {
          'name': name,
          'description': description,
          'price': price,
          'stock': stock,
          'imageUrl': imageUrl,
          'category': category,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ProductModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to create product');
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = (data is Map ? (data['message'] ?? data['detail']) : null)
          ?.toString();
      throw ServerException(message ?? e.message ?? 'Network request failed');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ProductModel> updateProduct({
    required String id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? imageUrl,
    String? category,
  }) async {
    try {
      final response = await apiClient.dio.put(
        '/products/$id',
        data: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
          if (price != null) 'price': price,
          if (stock != null) 'stock': stock,
          if (imageUrl != null) 'imageUrl': imageUrl,
          if (category != null) 'category': category,
        },
      );

      if (response.statusCode == 200) {
        return ProductModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to update product');
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = (data is Map ? (data['message'] ?? data['detail']) : null)
          ?.toString();
      throw ServerException(message ?? e.message ?? 'Network request failed');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ProductModel> deleteProduct(String id) async {
    try {
      final response = await apiClient.dio.delete('/products/$id');

      if (response.statusCode == 200) {
        return ProductModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to delete product');
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = (data is Map ? (data['message'] ?? data['detail']) : null)
          ?.toString();
      throw ServerException(message ?? e.message ?? 'Network request failed');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
