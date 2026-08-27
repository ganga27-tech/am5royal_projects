import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/app_api_client.dart';
import '../models/auth_models.dart';

class AuthApi {
  AuthApi({ApiClient? client})
      : _client = client ?? AppApiClient.instance;

  final ApiClient _client;

  Future<Map<String, dynamic>> sendOtp({
    String? mobile,
    String? email,
  }) async {
    final Map<String, dynamic> body = {'platform': ApiConfig.platform};
    if (mobile != null && mobile.isNotEmpty) {
      body['mobile'] = mobile;
    }
    if (email != null && email.isNotEmpty) {
      body['email'] = email;
    }
    return _client.post('/auth/customer/send-otp', body: body);
  }

  Future<TokenResponse> verifyOtp({
    String? mobile,
    String? email,
    required String otp,
  }) async {
    final Map<String, dynamic> body = {
      'otp': otp,
      'platform': ApiConfig.platform,
    };
    if (mobile != null && mobile.isNotEmpty) {
      body['mobile'] = mobile;
    }
    if (email != null && email.isNotEmpty) {
      body['email'] = email;
    }
    final Map<String, dynamic> response =
        await _client.post('/auth/customer/verify-otp', body: body);
    return TokenResponse.fromJson(response);
  }

  Future<CustomerProfile> getProfile() async {
    final Map<String, dynamic> response =
        await _client.get('/auth/customer/me', authenticated: true);
    return CustomerProfile.fromJson(response);
  }

  Future<CustomerProfile> updateProfile({
    String? fullName,
    String? email,
  }) async {
    final Map<String, dynamic> body = {};
    if (fullName != null) {
      body['full_name'] = fullName;
    }
    if (email != null) {
      body['email'] = email;
    }
    final Map<String, dynamic> response = await _client.put(
      '/auth/customer/profile',
      body: body,
      authenticated: true,
    );
    return CustomerProfile.fromJson(response);
  }
}
