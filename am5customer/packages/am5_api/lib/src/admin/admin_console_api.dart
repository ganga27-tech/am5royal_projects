import 'package:dio/dio.dart';
import 'package:am5_core/am5_core.dart';

import '../client/api_client.dart';

class AdminConsoleApi {
  AdminConsoleApi(this._client);

  final ApiClient _client;

  Future<List<AdminCoupon>> listCoupons() async {
    try {
      final response = await _client.dio.get('/admin/coupons');
      final list = response.data as List<dynamic>;
      return list.map((e) => AdminCoupon.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<AdminCoupon> createCoupon(Map<String, dynamic> body) async {
    try {
      final response = await _client.dio.post('/admin/coupons', data: body);
      return AdminCoupon.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<AdminCoupon> updateCoupon(String id, Map<String, dynamic> body) async {
    try {
      final response = await _client.dio.patch('/admin/coupons/$id', data: body);
      return AdminCoupon.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<AdminCoupon> deactivateCoupon(String id) async {
    try {
      final response = await _client.dio.post('/admin/coupons/$id/deactivate');
      return AdminCoupon.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<List<PriceOverride>> listPriceOverrides({String? serviceId}) async {
    try {
      final response = await _client.dio.get(
        '/admin/pricing/overrides',
        queryParameters: {if (serviceId != null) 'service_id': serviceId},
      );
      final list = response.data as List<dynamic>;
      return list.map((e) => PriceOverride.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<PriceOverride> createPriceOverride(Map<String, dynamic> body) async {
    try {
      final response = await _client.dio.post('/admin/pricing/overrides', data: body);
      return PriceOverride.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<void> deletePriceOverride(String id) async {
    try {
      await _client.dio.delete('/admin/pricing/overrides/$id');
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<List<AdminRole>> listRoles() async {
    try {
      final response = await _client.dio.get('/admin/roles');
      final list = response.data as List<dynamic>;
      return list.map((e) => AdminRole.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<List<AdminUserSummary>> searchUsers({String? q}) async {
    try {
      final response = await _client.dio.get(
        '/admin/users',
        queryParameters: {if (q != null && q.isNotEmpty) 'q': q},
      );
      final list = response.data as List<dynamic>;
      return list.map((e) => AdminUserSummary.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<AdminUserSummary> assignRole(String userId, String roleCode) async {
    try {
      final response = await _client.dio.post(
        '/admin/users/$userId/roles',
        data: {'role_code': roleCode},
      );
      final data = response.data as Map<String, dynamic>;
      return AdminUserSummary(
        id: data['user_id'] as String,
        email: data['email'] as String?,
        fullName: data['full_name'] as String?,
        status: 'active',
        roles: (data['roles'] as List<dynamic>).map((e) => e.toString()).toList(),
      );
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<AdminUserSummary> revokeRole(String userId, String roleCode) async {
    try {
      final response = await _client.dio.delete('/admin/users/$userId/roles/$roleCode');
      final data = response.data as Map<String, dynamic>;
      return AdminUserSummary(
        id: data['user_id'] as String,
        email: data['email'] as String?,
        fullName: data['full_name'] as String?,
        status: 'active',
        roles: (data['roles'] as List<dynamic>).map((e) => e.toString()).toList(),
      );
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }
}
