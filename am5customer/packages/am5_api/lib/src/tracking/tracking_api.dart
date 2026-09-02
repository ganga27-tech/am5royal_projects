import 'package:dio/dio.dart';
import 'package:am5_core/am5_core.dart';

import '../client/api_client.dart';

class TrackingApi {
  TrackingApi(this._client);

  final ApiClient _client;

  Future<TrackingSnapshot> getTracking(String bookingId) async {
    try {
      final response = await _client.dio.get('/orders/');
      final list = response.data as List<dynamic>;
      Map<String, dynamic>? match;
      for (final entry in list) {
        final json = entry as Map<String, dynamic>;
        final orderId = json['orderId']?.toString() ?? '';
        if (orderId == bookingId) {
          match = json;
          break;
        }
      }

      final status = (match?['status'] as String? ?? 'pending').toLowerCase();
      return TrackingSnapshot(
        bookingId: bookingId,
        bookingCode: match?['orderId']?.toString() ?? bookingId,
        bookingStatus: status,
        trackingStatus: 'unavailable',
        isLive: false,
        destinationLabel: match?['service_name'] as String?,
      );
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<List<LocationPing>> getPings(String bookingId, {int limit = 50}) async {
    return const [];
  }

  Future<RouteEstimate> estimateRoute({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    throw const Failure('Route estimation is not available yet.');
  }

  Future<TrackingSnapshot> partnerStart(String bookingId) async {
    throw const Failure('Partner tracking is not available in the customer app.');
  }

  Future<TrackingSnapshot> partnerPing(
    String bookingId, {
    required double latitude,
    required double longitude,
    double? accuracyM,
    double? heading,
    double? speedKmh,
    String source = 'gps',
  }) async {
    throw const Failure('Partner tracking is not available in the customer app.');
  }

  Future<TrackingSnapshot> partnerArrive(String bookingId) async {
    throw const Failure('Partner tracking is not available in the customer app.');
  }

  Future<TrackingSnapshot> partnerEnd(String bookingId) async {
    throw const Failure('Partner tracking is not available in the customer app.');
  }
}
