import 'package:dio/dio.dart';
import 'package:am5_core/am5_core.dart';

import '../client/api_client.dart';

class SystemApi {
  SystemApi(this._client);

  final ApiClient _client;

  Future<SystemHealth> adminSystemHealth() async {
    try {
      final response = await _client.dio.get('/admin/system/health');
      return SystemHealth.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }
}
