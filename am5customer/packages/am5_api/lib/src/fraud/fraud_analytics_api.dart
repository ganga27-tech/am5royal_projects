import 'package:dio/dio.dart';
import 'package:am5_core/am5_core.dart';

import '../client/api_client.dart';

class FraudAnalyticsApi {
  FraudAnalyticsApi(this._client);

  final ApiClient _client;

  Future<AnalyticsSummary> analyticsSummary({int days = 30}) async {
    try {
      final response = await _client.dio.get(
        '/admin/analytics/summary',
        queryParameters: {'days': days},
      );
      return AnalyticsSummary.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<List<AuditLogEntry>> auditLogs({String? eventType, int limit = 50}) async {
    try {
      final response = await _client.dio.get(
        '/admin/audit/logs',
        queryParameters: {
          if (eventType != null) 'event_type': eventType,
          'limit': limit,
        },
      );
      final list = response.data as List<dynamic>;
      return list.map((e) => AuditLogEntry.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<List<FraudSignal>> fraudSignals({String status = 'open'}) async {
    try {
      final response = await _client.dio.get(
        '/admin/fraud/signals',
        queryParameters: {'status': status},
      );
      final list = response.data as List<dynamic>;
      return list.map((e) => FraudSignal.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<FraudSignal> reviewSignal(String id, {required String status, String? notes}) async {
    try {
      final response = await _client.dio.post(
        '/admin/fraud/signals/$id/review',
        data: {
          'status': status,
          if (notes != null) 'resolution_notes': notes,
        },
      );
      return FraudSignal.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }
}
