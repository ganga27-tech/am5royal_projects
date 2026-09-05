import 'package:dio/dio.dart';
import 'package:am5_core/am5_core.dart';

import '../client/api_client.dart';

class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  bool _isEmail(String value) => value.contains('@');

  Map<String, dynamic> _identifierBody(String identifier) {
    if (_isEmail(identifier)) {
      return {'email': identifier};
    }
    return {'mobile': identifier};
  }

  Future<void> requestOtp({
    required String identifier,
    String platform = 'mobile',
  }) async {
    try {
      await _client.dio.post(
        '/auth/customer/send-otp',
        data: {
          ..._identifierBody(identifier),
          'platform': platform,
        },
      );
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<void> requestPhoneOtp({
    required String phone,
    required DeviceInfo device,
  }) async {
    await requestOtp(identifier: phone, platform: device.platform ?? 'mobile');
  }

  Future<AuthTokens> verifyOtp({
    required String destination,
    required String code,
    required DeviceInfo device,
    String purpose = 'login',
  }) async {
    try {
      final response = await _client.dio.post(
        '/auth/customer/verify-otp',
        data: {
          ..._identifierBody(destination),
          'otp': code,
          'platform': device.platform ?? 'mobile',
        },
      );
      final data = response.data as Map<String, dynamic>;
      final tokens = AuthTokens.fromJson(data);
      await _client.tokenStorage.saveTokens(accessToken: tokens.accessToken);

      final user = await me();
      return tokens.copyWithUser(user);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<LivoraUser> me() async {
    try {
      final response = await _client.dio.get('/auth/customer/me');
      return LivoraUser.fromAm5CustomerProfile(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<void> logout() async {
    await _client.tokenStorage.clear();
  }

  Future<void> sendBookingSecurityOtp() async {
    try {
      await _client.dio.post('/auth/customer/booking-security/send-otp');
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<void> verifyBookingSecurityOtp({required String code}) async {
    try {
      await _client.dio.post(
        '/auth/customer/booking-security/verify-otp',
        data: {'otp': code},
      );
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }
}
