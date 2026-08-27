import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/telecaller_vendor_onboard_request_model.dart';
import '../models/telecaller_dashboard_stats_model.dart';
import '../models/paginated_onboarded_vendors_response_model.dart';
import '../models/telecaller_leaderboard_model.dart';
import '../models/verification_incentive_model.dart';
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

  /// Step 1: Save vendor profile and create DB record.
  Future<Map<String, dynamic>> telecallerSaveProfile(
      String mobile, TelecallerVendorOnboardRequestModel request) async {
    return _post(
      '/employees/vendors/telecaller-onboard/profile',
      queryParameters: {'mobile': mobile},
      data: {
        'first_name': request.firstName,
        'last_name': request.lastName,
        'father_name': request.fatherName,
        'business_name': request.businessName,
        'aadhaar_number': request.aadhaarNumber,
        'address': request.address,
        'city': request.city,
        'state': request.state,
        'pincode': request.pincode,
        if (request.latitude != null) 'latitude': request.latitude,
        if (request.longitude != null) 'longitude': request.longitude,
        if (request.serviceRadiusKm != null) 'service_radius_km': request.serviceRadiusKm,
        if (request.profileImage != null) 'profile_image': request.profileImage,
      },
    );
  }

  /// Step 3: Append categories and services for the current category selection.
  Future<Map<String, dynamic>> telecallerSaveCategoryServices(
    String mobile, {
    required List<TelecallerCategoryRequest> categories,
    required List<TelecallerServiceRequest> services,
  }) async {
    return _post(
      '/employees/vendors/telecaller-onboard/category-services',
      queryParameters: {'mobile': mobile},
      data: {
        'categories': categories.map((e) => e.toJson()).toList(),
        'services': services.map((e) => e.toJson()).toList(),
      },
    );
  }

  /// Step 5: Finalize telecaller onboarding.
  Future<Map<String, dynamic>> telecallerCompleteOnboarding(String mobile) async {
    return _post(
      '/employees/vendors/telecaller-onboard/complete',
      queryParameters: {'mobile': mobile},
    );
  }

  /// Legacy: full onboard in one call.
  Future<Map<String, dynamic>> telecallerOnboardVendor(
      String mobile, TelecallerVendorOnboardRequestModel request) async {
    return _post(
      '/employees/vendors/telecaller-onboard',
      queryParameters: {'mobile': mobile},
      data: request.toJson(),
    );
  }

  Future<TelecallerDashboardStatsModel> telecallerDashboardStats() async {
    final response = await _get('/employees/telecaller-dashboard/stats');
    return TelecallerDashboardStatsModel.fromJson(response);
  }

  Future<PaginatedOnboardedVendorsResponseModel> telecallerDashboardOnboarded({
    String? startDate,
    String? endDate,
    int skip = 0,
    int limit = 50,
    String? leadSource,
  }) async {
    final queryParameters = <String, dynamic>{
      'skip': skip,
      'limit': limit,
    };
    if (startDate != null) {
      queryParameters['start_date'] = startDate;
    }
    if (endDate != null) {
      queryParameters['end_date'] = endDate;
    }
    if (leadSource != null && leadSource.isNotEmpty) {
      queryParameters['lead_source'] = leadSource;
    }
    final response = await _get(
      '/employees/telecaller-dashboard/onboarded',
      queryParameters: queryParameters,
    );
    return PaginatedOnboardedVendorsResponseModel.fromJson(response);
  }

  Future<Map<String, dynamic>> getVendorStepDetails(int vendorId) async {
    try {
      final token = await _getAuthToken();
      final response = await dio.get(
        '/employees/telecaller-dashboard/vendor-step-details/$vendorId',
        options: Options(headers: _authHeaders(token)),
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw ServerException('Failed to fetch step details');
    } on DioException catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  Future<List<VerificationIncentiveModel>> telecallerDashboardIncentives({
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final token = await _getAuthToken();
      final response = await dio.get(
        '/employees/telecaller-dashboard/incentives',
        queryParameters: {'skip': skip, 'limit': limit},
        options: Options(headers: _authHeaders(token)),
      );
      if (response.statusCode == 200) {
        final list = response.data as List;
        return list
            .map((e) =>
                VerificationIncentiveModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ServerException('Request failed');
    } on DioException catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  Future<List<TelecallerLeaderboardModel>> telecallerDashboardLeaderboard() async {
    try {
      final token = await _getAuthToken();
      final response = await dio.get(
        '/employees/telecaller-dashboard/leaderboard',
        options: Options(headers: _authHeaders(token)),
      );
      if (response.statusCode == 200) {
        final list = response.data as List;
        return list.map((e) => TelecallerLeaderboardModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw ServerException('Request failed');
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


