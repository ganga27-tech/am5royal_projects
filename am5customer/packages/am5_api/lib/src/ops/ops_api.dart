import 'package:dio/dio.dart';
import 'package:am5_core/am5_core.dart';

import '../client/api_client.dart';

class OpsApi {
  OpsApi(this._client);

  final ApiClient _client;

  Future<VerificationSummary> verificationSummary() async {
    try {
      final response = await _client.dio.get('/ops/verification/summary');
      return VerificationSummary.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<List<KycStatus>> kycQueue() async {
    try {
      final response = await _client.dio.get('/admin/kyc/queue');
      final list = response.data as List<dynamic>;
      return list.map((e) => KycStatus.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<KycStatus> reviewKyc(String professionalId, {required String status, String? reason}) async {
    try {
      final response = await _client.dio.post(
        '/admin/kyc/professionals/$professionalId/review',
        data: {
          'status': status,
          if (reason != null) 'rejection_reason': reason,
        },
      );
      return KycStatus.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<List<PartnerWithdrawalOps>> pendingWithdrawals() async {
    try {
      final response = await _client.dio.get('/admin/partner/withdrawals/pending');
      final list = response.data as List<dynamic>;
      return list.map((e) => PartnerWithdrawalOps.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<PartnerWithdrawalOps> reviewWithdrawal(String id, {required String status, String? reason}) async {
    try {
      final response = await _client.dio.post(
        '/admin/partner/withdrawals/$id/review',
        data: {
          'status': status,
          if (reason != null) 'rejection_reason': reason,
        },
      );
      return PartnerWithdrawalOps.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<List<Booking>> dispatchBoard({String status = 'pending'}) async {
    try {
      final response = await _client.dio.get(
        '/ops/bookings/dispatch',
        queryParameters: {'status': status},
      );
      final list = response.data as List<dynamic>;
      return list.map((e) => Booking.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<List<AssignmentCandidate>> candidates(String bookingId) async {
    try {
      final response = await _client.dio.get('/ops/bookings/$bookingId/candidates');
      final list = response.data as List<dynamic>;
      return list.map((e) => AssignmentCandidate.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<Booking> reassign(String bookingId, {required String professionalId, String? reason}) async {
    try {
      final response = await _client.dio.post(
        '/ops/bookings/$bookingId/reassign',
        data: {
          'professional_id': professionalId,
          if (reason != null) 'reason': reason,
        },
      );
      return Booking.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<Booking> autoAssign(String bookingId) async {
    try {
      final response = await _client.dio.post('/ops/bookings/$bookingId/auto-assign');
      return Booking.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<List<OpsEscalation>> listEscalations({String? status}) async {
    try {
      final response = await _client.dio.get(
        '/ops/escalations',
        queryParameters: {if (status != null) 'status': status},
      );
      final list = response.data as List<dynamic>;
      return list.map((e) => OpsEscalation.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<OpsEscalation> createEscalation({
    required String title,
    String? description,
    String category = 'booking',
    String priority = 'medium',
    String? bookingId,
  }) async {
    try {
      final response = await _client.dio.post(
        '/ops/escalations',
        data: {
          'title': title,
          if (description != null) 'description': description,
          'category': category,
          'priority': priority,
          if (bookingId != null) 'booking_id': bookingId,
        },
      );
      return OpsEscalation.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<OpsEscalation> updateEscalation(String id, Map<String, dynamic> body) async {
    try {
      final response = await _client.dio.patch('/ops/escalations/$id', data: body);
      return OpsEscalation.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }
}
