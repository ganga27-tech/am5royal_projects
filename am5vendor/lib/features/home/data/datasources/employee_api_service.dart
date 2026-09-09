import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/employee_profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeApiService {
  final Dio dio;

  EmployeeApiService(this.dio);

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Map<String, String> _authHeaders(String? token) => {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  String _extractErrorMessage(DioException e) {
    if (e.response != null && e.response!.data != null) {
      final data = e.response!.data;
      if (data is Map) {
        if (data['detail'] != null) return data['detail'].toString();
        if (data['message'] != null) return data['message'].toString();
      } else if (data is String) {
        try {
          final parsed = jsonDecode(data);
          if (parsed is Map) {
            if (parsed['detail'] != null) return parsed['detail'].toString();
            if (parsed['message'] != null) return parsed['message'].toString();
          }
        } catch (_) {}
      }
    }
    return 'Server error: ${e.response?.statusCode ?? "Unknown"}';
  }

  Future<Map<String, dynamic>> _post(String path, {
    required Map<String, dynamic> queryParameters,
    Map<String, dynamic>? data,
  }) async {
    try {
      final token = await _getAuthToken();
      final response = await dio.post(
        path,
        queryParameters: queryParameters,
        data: data,
        options: Options(headers: _authHeaders(token)),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
      final message = response.data?['message'] ?? response.data?['detail'] ?? 'Request failed';
      throw ServerException(message.toString());
    } on DioException catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  Future<Map<String, dynamic>> _get(String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final token = await _getAuthToken();
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: _authHeaders(token)),
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      final message = response.data?['message'] ?? response.data?['detail'] ?? 'Request failed';
      throw ServerException(message.toString());
    } on DioException catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  Future<Map<String, dynamic>> approveVendor(int vendorId) async {
    try {
      final token = await _getAuthToken();
      final response = await dio.put(
        '/employees/vendors/$vendorId/approve',
        options: Options(headers: _authHeaders(token)),
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw ServerException('Request failed');
    } on DioException catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  Future<Map<String, dynamic>> rejectVendor(int vendorId) async {
    try {
      final token = await _getAuthToken();
      final response = await dio.put(
        '/employees/vendors/$vendorId/reject',
        options: Options(headers: _authHeaders(token)),
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw ServerException('Request failed');
    } on DioException catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  Future<EmployeeProfileModel> getEmployeeProfile() async {
    final response = await _get('/employees/me');
    return EmployeeProfileModel.fromJson(response);
  }

  Future<EmployeeProfileModel> updateEmployeeProfile(EmployeeProfileModel profile) async {
    final token = await _getAuthToken();
    try {
      final response = await dio.put(
        '/employees/me',
        data: profile.toJson(),
        options: Options(headers: _authHeaders(token)),
      );
      if (response.statusCode == 200) {
        return EmployeeProfileModel.fromJson(response.data as Map<String, dynamic>);
      }
      final message = response.data?['message'] ?? response.data?['detail'] ?? 'Request failed';
      throw ServerException(message.toString());
    } on DioException catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  Future<Map<String, dynamic>> sendWhatsAppInvite(String phone, String name) async {
    return _post(
      '/employees/vendors/send-whatsapp-invite',
      queryParameters: {},
      data: {
        'phone_number': phone,
        'vendor_name': name,
      },
    );
  }

  Future<Map<String, dynamic>> requestWithdrawal(double amount) async {
    return _post(
      '/employees/withdraw',
      queryParameters: {},
      data: {
        'amount': amount,
      },
    );
  }

  Future<List<dynamic>> getMyWithdrawals() async {
    try {
      final token = await _getAuthToken();
      final response = await dio.get(
        '/employees/withdrawals',
        options: Options(headers: _authHeaders(token)),
      );
      if (response.statusCode == 200) {
        return response.data as List;
      }
      throw ServerException('Request failed');
    } on DioException catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }
}


