import 'package:dio/dio.dart';
import 'package:am5_core/am5_core.dart';

import '../client/api_client.dart';

class PartnerOpsApi {
  PartnerOpsApi(this._client);

  final ApiClient _client;

  Future<PartnerWallet> getWallet() async {
    try {
      final response = await _client.dio.get('/partner/wallet');
      return PartnerWallet.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<List<PartnerLedgerEntry>> getLedger() async {
    try {
      final response = await _client.dio.get('/partner/wallet/ledger');
      final list = response.data as List<dynamic>;
      return list.map((e) => PartnerLedgerEntry.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<PartnerWithdrawal> requestWithdrawal({
    required double amount,
    String payoutMethod = 'upi',
    String? payoutDetails,
  }) async {
    try {
      final response = await _client.dio.post(
        '/partner/wallet/withdrawals',
        data: {
          'amount': amount,
          'payout_method': payoutMethod,
          if (payoutDetails != null) 'payout_details': payoutDetails,
        },
      );
      return PartnerWithdrawal.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<List<PartnerWithdrawal>> listWithdrawals() async {
    try {
      final response = await _client.dio.get('/partner/wallet/withdrawals');
      final list = response.data as List<dynamic>;
      return list.map((e) => PartnerWithdrawal.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<PartnerAttendance> checkIn({String? notes}) async {
    try {
      final response = await _client.dio.post(
        '/partner/attendance/check-in',
        data: {if (notes != null) 'notes': notes},
      );
      return PartnerAttendance.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<PartnerAttendance> checkOut() async {
    try {
      final response = await _client.dio.post('/partner/attendance/check-out');
      return PartnerAttendance.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<List<PartnerAttendance>> listAttendance() async {
    try {
      final response = await _client.dio.get('/partner/attendance');
      final list = response.data as List<dynamic>;
      return list.map((e) => PartnerAttendance.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<PartnerPerformance> getPerformance() async {
    try {
      final response = await _client.dio.get('/partner/performance');
      return PartnerPerformance.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }
}
